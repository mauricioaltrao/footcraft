import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'fcb_sysex.dart';

/// Configurações de fábrica que vêm com o app (dumps originais da Behringer).
enum FactorySetup {
  vAmp('assets/factory/v-amp.syx'),
  guitarAmps('assets/factory/b-guitar-amps.syx'),
  bassVAmp('assets/factory/bass-v-amp.syx');

  const FactorySetup(this.asset);
  final String asset;
}

/// De onde veio a configuração aberta.
enum SetupSource { factory, device, file }

/// A configuração em edição: desfazer/refazer, pedal escolhido, área de
/// transferência e cópia automática no disco (nada se perde ao fechar o app).
class FcbDocument extends ChangeNotifier {
  FcbDocument._();
  static final FcbDocument instance = FcbDocument._();

  late FcbSetup setup;
  SetupSource source = SetupSource.factory;

  /// Nome do arquivo ou da configuração de fábrica; para o que veio da FCB, a data.
  String sourceName = '';

  /// Mudou desde que foi aberto, recebido da FCB ou enviado para ela.
  bool dirty = false;

  int bank = 0;
  int pedal = 0;
  int get selected => FcbSetup.indexOf(bank, pedal);

  FcbPreset? clipboard;

  final List<Uint8List> _undo = [];
  final List<Uint8List> _redo = [];
  static const _historyLimit = 100;

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  Future<void> init() async {
    if (await _restore()) return;
    await loadFactory(FactorySetup.vAmp);
  }

  // ------------------------------------------------------------ edição

  /// Altera a configuração com um passo de desfazer.
  void edit(void Function(FcbSetup s) change) {
    final before = Uint8List.fromList(setup.data);
    change(setup);
    if (listEquals(before, setup.data)) return;
    _undo.add(before);
    if (_undo.length > _historyLimit) _undo.removeAt(0);
    _redo.clear();
    _changed();
  }

  void setPreset(int index, FcbPreset preset) => edit((s) => s.setPreset(index, preset));

  void undo() {
    if (!canUndo) return;
    _redo.add(Uint8List.fromList(setup.data));
    setup.data.setAll(0, _undo.removeLast());
    _changed();
  }

  void redo() {
    if (!canRedo) return;
    _undo.add(Uint8List.fromList(setup.data));
    setup.data.setAll(0, _redo.removeLast());
    _changed();
  }

  void select(int bank, int pedal) {
    this.bank = bank;
    this.pedal = pedal;
    notifyListeners();
  }

  void selectBank(int bank) {
    this.bank = bank;
    notifyListeners();
  }

  void copyPreset(int index) {
    clipboard = setup.preset(index);
    notifyListeners();
  }

  void pastePreset(int index) {
    final c = clipboard;
    if (c != null) setPreset(index, c);
  }

  /// Copia o banco [from] inteiro sobre o banco [to].
  void copyBank(int from, int to) => edit((s) {
    for (var k = 0; k < FcbSetup.pedalsPerBank; k++) {
      s.setPreset(FcbSetup.indexOf(to, k), s.preset(FcbSetup.indexOf(from, k)));
    }
  });

  // ------------------------------------------------------------ abrir

  Future<void> loadFactory(FactorySetup f) async {
    final data = await rootBundle.load(f.asset);
    _open(data.buffer.asUint8List(), SetupSource.factory, f.name);
  }

  /// Abre um dump; lança [FormatException] se não for da FCB1010.
  void loadSysex(List<int> raw, SetupSource source, String name) => _open(raw, source, name);

  void _open(List<int> raw, SetupSource source, String name) {
    final next = FcbSetup.fromSysex(raw);
    if (_initialized) {
      // Abrir outra configuração também pode ser desfeito.
      _undo.add(Uint8List.fromList(setup.data));
      _redo.clear();
    }
    setup = next;
    _initialized = true;
    this.source = source;
    sourceName = name;
    dirty = false;
    _changed(markDirty: false);
  }

  bool _initialized = false;

  /// A configuração foi gravada na FCB ou num arquivo.
  void markSaved({String? name, SetupSource? source}) {
    dirty = false;
    if (name != null) sourceName = name;
    if (source != null) this.source = source;
    _changed(markDirty: false);
  }

  void _changed({bool markDirty = true}) {
    if (markDirty) dirty = true;
    notifyListeners();
    _scheduleSave();
  }

  // ------------------------------------------------------------ cópia no disco

  bool _saving = false;
  bool _pendingSave = false;

  static Future<Directory> _dir() async {
    final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'current'));
    await dir.create(recursive: true);
    return dir;
  }

  void _scheduleSave() {
    if (_saving) {
      _pendingSave = true;
      return;
    }
    _saving = true;
    Future(() async {
      do {
        _pendingSave = false;
        try {
          final dir = await _dir();
          await File(p.join(dir.path, 'setup.syx')).writeAsBytes(setup.toSysex());
          await File(p.join(dir.path, 'setup.json')).writeAsString(jsonEncode({
            'source': source.name,
            'name': sourceName,
            'dirty': dirty,
            'bank': bank,
            'pedal': pedal,
          }));
        } catch (e) {
          debugPrint('[footcraft] não deu para guardar a configuração: $e');
        }
      } while (_pendingSave);
      _saving = false;
    });
  }

  Future<bool> _restore() async {
    try {
      final dir = await _dir();
      final file = File(p.join(dir.path, 'setup.syx'));
      if (!file.existsSync()) return false;
      final meta = jsonDecode(await File(p.join(dir.path, 'setup.json')).readAsString()) as Map<String, dynamic>;
      setup = FcbSetup.fromSysex(await file.readAsBytes());
      _initialized = true;
      source = SetupSource.values.byName(meta['source'] as String);
      sourceName = meta['name'] as String;
      dirty = meta['dirty'] as bool;
      bank = meta['bank'] as int;
      pedal = meta['pedal'] as int;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[footcraft] configuração guardada ilegível: $e');
      return false;
    }
  }

  /// Guarda uma cópia do que veio da FCB (backups/fcb-AAAAMMDD-HHMMSS.syx).
  static Future<File> saveDeviceBackup(List<int> raw) async {
    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'FootCraft', 'backups'));
    await dir.create(recursive: true);
    final t = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final name = 'fcb-${t.year}${two(t.month)}${two(t.day)}-${two(t.hour)}${two(t.minute)}${two(t.second)}.syx';
    return File(p.join(dir.path, name)).writeAsBytes(raw);
  }
}
