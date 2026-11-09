import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:footcraft/fcb/batch.dart';
import 'package:footcraft/fcb/fcb_sysex.dart';

void main() {
  test('a receita "um CC por pedal" gera o mesmo arquivo gravado na FCB real', () {
    // cc102.syx: backup + CC 102 = 1..100, expressão A = CC 7 e B = CC 11
    // (gerado pelo script em Python e conferido pisando nos pedais).
    final setup = FcbSetup.fromSysex(File('test/fixtures/backup.syx').readAsBytesSync());
    BatchPlan.oneCcPerPedal(controller: 102).copyWith(
      expA: const BatchExpression(mode: BatchMode.fixed, controller: 7, min: 0, max: 127),
      expB: const BatchExpression(mode: BatchMode.fixed, controller: 11, min: 0, max: 127),
    ).apply(setup, List.generate(100, (i) => i));
    expect(setup.toSysex(), File('test/fixtures/cc102.syx').readAsBytesSync());
  });

  test('sequência conta só os pedais escolhidos e para em 127', () {
    final setup = FcbSetup.fromSysex(File('test/fixtures/v-amp.syx').readAsBytesSync());
    const plan = BatchPlan(note: BatchNumber(mode: BatchMode.sequence, value: 120, step: 5));
    plan.apply(setup, [30, 10, 20]);
    expect(setup.preset(10).note, const FcbNote(enabled: true, note: 120));
    expect(setup.preset(20).note, const FcbNote(enabled: true, note: 125));
    expect(setup.preset(30).note, const FcbNote(enabled: true, note: 127));
  });

  test('"deixar como está" não muda nada', () {
    final raw = File('test/fixtures/backup.syx').readAsBytesSync();
    final setup = FcbSetup.fromSysex(raw);
    const BatchPlan().apply(setup, List.generate(100, (i) => i));
    expect(setup.toSysex(), raw);
    expect(const BatchPlan().changesSomething, isFalse);
  });
}
