import 'dart:async';

import 'package:flutter/foundation.dart';

import '../midi/midi_link.dart';
import 'fcb_document.dart';
import 'fcb_sysex.dart';
import 'pedal_matcher.dart';

/// Modo de teste: escuta a FCB e mostra na tela qual pedal foi pisado,
/// reconhecendo-o pelas mensagens que chegam (com a configuração aberta).
class TestMode extends ChangeNotifier {
  TestMode._();
  static final TestMode instance = TestMode._();

  bool active = false;

  /// Último pedal reconhecido e quando (para o destaque sumir depois).
  int? pressed;
  DateTime? pressedAt;

  /// Mais de um pedal manda a mesma coisa.
  int ambiguous = 0;

  /// O que chegou no último aperto que não bate com nenhum pedal.
  Set<MidiKey>? unmatched;

  /// Posição dos pedais de expressão (0–127), conforme o CC de cada um no
  /// preset ativo; nulo até mexer.
  int? expA;
  int? expB;

  StreamSubscription<Uint8List>? _sub;
  final List<Uint8List> _burst = [];
  Timer? _burstTimer;
  Timer? _fade;

  /// Mensagens que chegam juntas ao pisar: espera este tempo sem nada novo.
  static const _burstWindow = Duration(milliseconds: 80);
  static const highlight = Duration(milliseconds: 1500);

  void toggle() => active ? stop() : start();

  void start() {
    active = true;
    pressed = null;
    unmatched = null;
    expA = expB = null;
    _sub ??= MidiLink.instance.messages.stream.listen(_onMessage);
    notifyListeners();
  }

  void stop() {
    active = false;
    _sub?.cancel();
    _sub = null;
    _burstTimer?.cancel();
    _fade?.cancel();
    _burst.clear();
    pressed = null;
    notifyListeners();
  }

  /// Destaque ainda visível para o pedal [index].
  bool isLit(int index) =>
      active &&
      pressed == index &&
      pressedAt != null &&
      DateTime.now().difference(pressedAt!) < highlight;

  void _onMessage(Uint8List m) {
    if (!active || m.isEmpty) return;
    final doc = FcbDocument.instance;
    final current = doc.setup.preset(doc.selected);
    final g = doc.setup.globals;
    // Pedal de expressão mexendo sozinho (fora de um aperto): só atualiza a barra.
    if (_burst.isEmpty && (m[0] & 0xF0) == 0xB0 && m.length >= 3) {
      final ch = m[0] & 0x0F;
      if (current.expA.enabled &&
          m[1] == current.expA.controller &&
          ch == g.channels[FcbChannel.expressionA.index]) {
        expA = _scale(m[2], current.expA);
        notifyListeners();
        return;
      }
      if (current.expB.enabled &&
          m[1] == current.expB.controller &&
          ch == g.channels[FcbChannel.expressionB.index]) {
        expB = _scale(m[2], current.expB);
        notifyListeners();
        return;
      }
    }
    if (keyOf(m) == null) return;
    _burst.add(m);
    _burstTimer?.cancel();
    _burstTimer = Timer(_burstWindow, _resolve);
  }

  /// Posição do pedal na faixa mín–máx configurada (0–127 na barra; com o
  /// mínimo maior que o máximo, o pedal é invertido e a conta também).
  static int _scale(int value, FcbExpression e) {
    if (e.max == e.min) return 127;
    return (((value - e.min) / (e.max - e.min)).clamp(0.0, 1.0) * 127).round();
  }

  void _resolve() {
    final doc = FcbDocument.instance;
    final received = {for (final m in _burst) keyOf(m)!};
    _burst.clear();
    final found = matchPedals(doc.setup, received, preferBank: doc.bank);
    if (found.isEmpty) {
      unmatched = received;
      pressed = null;
      notifyListeners();
      return;
    }
    final i = found.first;
    unmatched = null;
    ambiguous = found.length - 1;
    pressed = i;
    pressedAt = DateTime.now();
    doc.select(i ~/ FcbSetup.pedalsPerBank, i % FcbSetup.pedalsPerBank);
    notifyListeners();
    _fade?.cancel();
    _fade = Timer(highlight, notifyListeners);
  }
}
