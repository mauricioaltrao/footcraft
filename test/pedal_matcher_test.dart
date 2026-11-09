import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:footcraft/fcb/fcb_sysex.dart';
import 'package:footcraft/fcb/pedal_matcher.dart';

void main() {
  test('CC 102: cada valor aponta para o seu pedal', () {
    final setup = FcbSetup.fromSysex(File('test/fixtures/cc102.syx').readAsBytesSync());
    for (final i in [0, 9, 37, 99]) {
      final got = matchPedals(setup, {keyOf([0xB0, 102, i + 1])!});
      expect(got, [i]);
    }
  });

  test('as mensagens que cada preset manda são reconhecidas de volta', () {
    final setup = FcbSetup.fromSysex(File('test/fixtures/backup.syx').readAsBytesSync());
    for (var i = 0; i < 100; i++) {
      final expected = expectedMessages(setup.preset(i), setup.globals);
      if (expected.isEmpty) continue;
      expect(matchPedals(setup, expected, preferBank: i ~/ 10), contains(i), reason: 'preset $i');
    }
  });

  test('presets iguais: os do banco atual primeiro; nada bate → vazio', () {
    final setup = FcbSetup.fromSysex(File('test/fixtures/cc102.syx').readAsBytesSync());
    final p = setup.preset(3);
    setup.setPreset(25, p);
    expect(matchPedals(setup, {keyOf([0xB0, 102, 4])!}, preferBank: 2), [25, 3]);
    expect(matchPedals(setup, {keyOf([0xB0, 5, 1])!}), isEmpty);
  });

  test('nota desligada e velocidade zero não contam', () {
    expect(keyOf([0x80, 60, 0]), isNull);
    expect(keyOf([0x90, 60, 0]), isNull);
    expect(keyOf([0x90, 60, 100]), noteKey(0, 60));
  });
}
