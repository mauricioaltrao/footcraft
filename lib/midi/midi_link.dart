import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart' show AnyhowException;
import 'package:shared_preferences/shared_preferences.dart';

import '../src/rust/api/midi.dart' as midi;

/// Uma mensagem vista no monitor MIDI.
class MidiEvent {
  MidiEvent(this.bytes) : time = DateTime.now();
  final Uint8List bytes;
  final DateTime time;

  int get status => bytes.isEmpty ? 0 : bytes[0];
  int get channel => (status & 0x0F) + 1;
}

/// Ligação com a controladora: escolhe e abre as portas MIDI, monta os SysEx
/// que chegam em pedaços e guarda as últimas mensagens para o monitor.
class MidiLink extends ChangeNotifier {
  MidiLink._();
  static final MidiLink instance = MidiLink._();

  List<String> inputs = [];
  List<String> outputs = [];
  String? input;
  String? output;
  String? error;

  bool get connected => input != null && output != null;

  /// Bytes do SysEx que está chegando agora (para a barra de progresso).
  int incomingSysex = 0;

  /// SysEx completos recebidos.
  final StreamController<Uint8List> sysex = StreamController.broadcast();

  /// Últimas mensagens comuns (CC, PC, notas), a mais nova no fim.
  final List<MidiEvent> recent = [];
  static const _recentLimit = 200;

  List<int>? _sysexBuffer;
  Timer? _poll;
  static const _inputKey = 'midi_input';
  static const _outputKey = 'midi_output';

  Future<void> init() async {
    midi.midiInputStream().listen(_onBytes);
    await refresh(autoOpen: true);
    // Interface ligada depois do app: procura de tempos em tempos.
    _poll = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!connected) refresh(autoOpen: true);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  /// No Linux o nome da porta termina com "cliente:porta" (ex.: "36:0"), que
  /// muda ao religar a interface; a escolha é lembrada sem isso.
  static String _stable(String name) => name.replaceFirst(RegExp(r'\s+\d+:\d+$'), '');

  static bool _isSystem(String name) {
    final n = name.toLowerCase();
    return n.contains('midi through') || n.contains('pipewire') || n.startsWith('system');
  }

  Future<void> refresh({bool autoOpen = false}) async {
    try {
      final ports = await midi.midiListPorts();
      inputs = ports.inputs;
      outputs = ports.outputs;
      // A porta aberta sumiu (interface desligada).
      if (connected && (!inputs.contains(input) || !outputs.contains(output))) {
        await close();
      }
      if (autoOpen && !connected) await _autoOpen();
    } catch (e) {
      error = _message(e);
    }
    notifyListeners();
  }

  Future<void> _autoOpen() async {
    final prefs = await SharedPreferences.getInstance();
    String? pick(List<String> ports, String key) {
      final saved = prefs.getString(key);
      final match = ports.where((p) => saved != null && _stable(p) == saved).firstOrNull;
      if (match != null) return match;
      // Sem escolha guardada: se só há uma porta de verdade, é ela.
      final real = ports.where((p) => !_isSystem(p)).toList();
      return saved == null && real.length == 1 ? real.first : null;
    }

    final i = pick(inputs, _inputKey), o = pick(outputs, _outputKey);
    if (i != null && o != null) await open(i, o, remember: false);
  }

  Future<bool> open(String input, String output, {bool remember = true}) async {
    try {
      await midi.midiOpen(input: input, output: output);
      this.input = input;
      this.output = output;
      error = null;
      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_inputKey, _stable(input));
        await prefs.setString(_outputKey, _stable(output));
      }
      notifyListeners();
      return true;
    } catch (e) {
      this.input = null;
      this.output = null;
      error = _message(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> close() async {
    await midi.midiClose();
    input = null;
    output = null;
    _sysexBuffer = null;
    incomingSysex = 0;
    notifyListeners();
  }

  /// Manda um SysEx (ou qualquer mensagem completa).
  Future<void> send(Uint8List bytes) async {
    if (!connected) throw StateError('MIDI não conectado');
    await midi.midiSend(bytes: bytes);
  }

  void clearRecent() {
    recent.clear();
    notifyListeners();
  }

  void _onBytes(Uint8List chunk) {
    final short = <int>[];
    for (final b in chunk) {
      if (b == 0xF0) {
        _sysexBuffer = [b];
      } else if (_sysexBuffer != null) {
        if (b >= 0xF8) continue; // tempo real pode chegar no meio do SysEx
        _sysexBuffer!.add(b);
        if (b == 0xF7) {
          final done = Uint8List.fromList(_sysexBuffer!);
          _sysexBuffer = null;
          incomingSysex = 0;
          sysex.add(done);
          _log(done);
        } else if (b >= 0x80) {
          // Outro status no meio: o SysEx veio quebrado.
          _sysexBuffer = null;
          incomingSysex = 0;
          short.add(b);
        }
      } else {
        short.add(b);
      }
    }
    if (_sysexBuffer != null) incomingSysex = _sysexBuffer!.length;
    // Um pedaço pode trazer várias mensagens curtas: separa pelo status.
    var start = 0;
    for (var i = 1; i <= short.length; i++) {
      if (i == short.length || short[i] >= 0x80) {
        _log(Uint8List.fromList(short.sublist(start, i)));
        start = i;
      }
    }
    notifyListeners();
  }

  void _log(Uint8List bytes) {
    recent.add(MidiEvent(bytes));
    if (recent.length > _recentLimit) recent.removeRange(0, recent.length - _recentLimit);
  }

  static String _message(Object e) => e is AnyhowException ? e.message.split('\n').first : e.toString();
}
