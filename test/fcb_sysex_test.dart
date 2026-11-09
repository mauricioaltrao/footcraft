import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:footcraft/fcb/fcb_sysex.dart';

/// Os valores esperados vêm do parser em Python validado com uma FCB1010 real
/// (dump recebido dela e arquivo gravado nela, conferidos pelo MIDI).
void main() {
  final expected = jsonDecode(File('test/fixtures/expected.json').readAsStringSync()) as Map<String, dynamic>;

  for (final name in expected.keys) {
    group(name, () {
      final raw = File('test/fixtures/$name').readAsBytesSync();

      test('desempacotar e empacotar devolve os mesmos bytes', () {
        expect(FcbSysex.isDump(raw), isTrue);
        expect(FcbSetup.fromSysex(raw).toSysex(), raw);
      });

      test('presets iguais aos do parser validado', () {
        final setup = FcbSetup.fromSysex(raw);
        final list = expected[name] as List;
        for (var i = 0; i < 100; i++) {
          final e = list[i] as Map<String, dynamic>;
          final p = setup.preset(i);
          for (var k = 0; k < 5; k++) {
            expect(p.programs[k].enabled, e['pc${k + 1}_on'], reason: 'preset $i pc${k + 1}');
            expect(p.programs[k].program, e['pc${k + 1}'], reason: 'preset $i pc${k + 1}');
          }
          expect((p.cc1.enabled, p.cc1.controller, p.cc1.value), (e['cc1_on'], e['cc1_ctl'], e['cc1_val']));
          expect((p.cc2.enabled, p.cc2.controller, p.cc2.value), (e['cc2_on'], e['cc2_ctl'], e['cc2_val']));
          expect((p.relay1, p.relay2), (e['sw1_on'], e['sw2_on']), reason: 'preset $i relés');
          expect((p.expA.enabled, p.expA.controller, p.expA.min, p.expA.max),
              (e['expA_on'], e['expA_ctl'], e['expA_min'], e['expA_max']));
          expect((p.expB.enabled, p.expB.controller, p.expB.min, p.expB.max),
              (e['expB_on'], e['expB_ctl'], e['expB_min'], e['expB_max']));
          expect((p.note.enabled, p.note.note), (e['note_on'], e['note']));
        }
      });

      test('regravar cada preset sem mudança não altera nada', () {
        final setup = FcbSetup.fromSysex(raw);
        for (var i = 0; i < 100; i++) {
          setup.setPreset(i, setup.preset(i));
        }
        setup.globals = setup.globals;
        expect(setup.toSysex(), raw);
      });
    });
  }

  test('o backup tem o merge e o running status ligados (conferido na FCB)', () {
    final g = FcbSetup.fromSysex(File('test/fixtures/backup.syx').readAsBytesSync()).globals;
    expect(g.merge, isTrue);
    expect(g.runningStatus, isTrue);
    expect(g.channels, everyElement(0));
  });

  test('editar um preset muda só ele', () {
    final raw = File('test/fixtures/backup.syx').readAsBytesSync();
    final setup = FcbSetup.fromSysex(raw);
    final p = setup.preset(42);
    setup.setPreset(42, p.copyWith(cc1: p.cc1.copyWith(enabled: true, controller: 102, value: 43)));
    final again = FcbSetup.fromSysex(setup.toSysex());
    expect(again.preset(42).cc1, const FcbControl(enabled: true, controller: 102, value: 43));
    for (var i = 0; i < 100; i++) {
      if (i != 42) expect(again.preset(i), FcbSetup.fromSysex(raw).preset(i));
    }
  });
}
