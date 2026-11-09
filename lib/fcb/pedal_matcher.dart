import 'fcb_sysex.dart';

/// Uma mensagem MIDI reduzida ao que identifica o pedal: tipo, canal e
/// números (a velocidade da nota não importa).
typedef MidiKey = String;

/// Mensagens que o [preset] manda ao ser pisado, com os canais de [globals].
/// Relés não passam pelo MIDI; pedais de expressão mandam só ao mexer.
Set<MidiKey> expectedMessages(FcbPreset preset, FcbGlobals globals) {
  int ch(FcbChannel c) => globals.channels[c.index];
  final programChannels = [
    FcbChannel.program1,
    FcbChannel.program2,
    FcbChannel.program3,
    FcbChannel.program4,
    FcbChannel.program5,
  ];
  return {
    for (final (k, p) in preset.programs.indexed)
      if (p.enabled) pcKey(ch(programChannels[k]), p.program),
    if (preset.cc1.enabled)
      ccKey(ch(FcbChannel.control1), preset.cc1.controller, preset.cc1.value),
    if (preset.cc2.enabled)
      ccKey(ch(FcbChannel.control2), preset.cc2.controller, preset.cc2.value),
    if (preset.note.enabled) noteKey(ch(FcbChannel.note), preset.note.note),
  };
}

MidiKey pcKey(int channel, int program) => 'PC $channel:$program';
MidiKey ccKey(int channel, int controller, int value) =>
    'CC $channel:$controller=$value';
MidiKey noteKey(int channel, int note) => 'NOTE $channel:$note';

/// Chave de uma mensagem recebida; nulo para o que não identifica pedal
/// (nota desligada, pitch bend...).
MidiKey? keyOf(List<int> m) {
  if (m.isEmpty) return null;
  final ch = m[0] & 0x0F;
  return switch (m[0] & 0xF0) {
    0xC0 when m.length >= 2 => pcKey(ch, m[1]),
    0xB0 when m.length >= 3 => ccKey(ch, m[1], m[2]),
    0x90 when m.length >= 3 && m[2] > 0 => noteKey(ch, m[1]),
    _ => null,
  };
}

/// Quais presets mandam exatamente as [received] (na configuração [setup]).
/// Se vários mandam a mesma coisa, os do [preferBank] vêm primeiro.
List<int> matchPedals(
  FcbSetup setup,
  Set<MidiKey> received, {
  int preferBank = 0,
}) {
  if (received.isEmpty) return const [];
  final g = setup.globals;
  final found = [
    for (var i = 0; i < FcbSetup.presetCount; i++)
      if (_sameSet(expectedMessages(setup.preset(i), g), received)) i,
  ];
  found.sort((a, b) {
    final ab = a ~/ FcbSetup.pedalsPerBank == preferBank ? 0 : 1;
    final bb = b ~/ FcbSetup.pedalsPerBank == preferBank ? 0 : 1;
    return ab != bb ? ab - bb : a - b;
  });
  return found;
}

bool _sameSet(Set<MidiKey> a, Set<MidiKey> b) =>
    a.length == b.length && a.containsAll(b);
