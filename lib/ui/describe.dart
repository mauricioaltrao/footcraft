import '../fcb/fcb_sysex.dart';
import '../l10n/app_localizations.dart';

const _noteNames = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

/// Nome da nota MIDI (60 = C4).
String noteName(int note) => '${_noteNames[note % 12]}${note ~/ 12 - 1}';

/// "Banco 0 · Pedal 1".
String pedalLabel(AppLocalizations l, int index) => l.bankPedal(
  index ~/ FcbSetup.pedalsPerBank,
  index % FcbSetup.pedalsPerBank + 1,
);

/// Linhas curtas do que o pedal manda, para o resumo no pedal. [compact]
/// para pedais estreitos (celular): "P1:10", "102=1".
List<(PedalPart, String)> summarize(FcbPreset p, {bool compact = false}) => [
  for (final (k, prog) in p.programs.indexed)
    if (prog.enabled)
      (
        PedalPart.program,
        compact ? 'P${k + 1}:${prog.program}' : 'PC${k + 1} ${prog.program}',
      ),
  for (final c in [p.cc1, p.cc2])
    if (c.enabled)
      (
        PedalPart.control,
        compact
            ? '${c.controller}=${c.value}'
            : 'CC ${c.controller}=${c.value}',
      ),
  if (p.note.enabled) (PedalPart.note, noteName(p.note.note)),
  if (p.relay1) (PedalPart.relay, 'SW1'),
  if (p.relay2) (PedalPart.relay, 'SW2'),
];

enum PedalPart { program, control, note, relay, expression }
