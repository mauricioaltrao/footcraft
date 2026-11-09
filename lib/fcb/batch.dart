import 'fcb_sysex.dart';

/// O que fazer com um item ao programar vários pedais de uma vez.
enum BatchMode {
  /// Deixa como está em cada pedal.
  keep,

  /// Desliga o item.
  off,

  /// Liga com o mesmo valor em todos.
  fixed,

  /// Liga com um valor que anda a cada pedal: início, início + passo...
  sequence,
}

/// Valor fixo ou em sequência (0–127; passa de 127 → fica em 127).
class BatchNumber {
  const BatchNumber({this.mode = BatchMode.keep, this.value = 0, this.step = 1});
  final BatchMode mode;

  /// Valor fixo, ou o primeiro da sequência.
  final int value;
  final int step;

  int at(int n) => mode == BatchMode.sequence ? (value + step * n).clamp(0, 127) : value;

  BatchNumber copyWith({BatchMode? mode, int? value, int? step}) =>
      BatchNumber(mode: mode ?? this.mode, value: value ?? this.value, step: step ?? this.step);
}

/// Control Change: o número do controle é sempre fixo; o valor pode andar.
class BatchControl {
  const BatchControl({this.mode = BatchMode.keep, this.controller = 0, this.value = const BatchNumber(mode: BatchMode.fixed, value: 127)});
  final BatchMode mode; // keep, off ou fixed (= ligar)
  final int controller;
  final BatchNumber value;

  BatchControl copyWith({BatchMode? mode, int? controller, BatchNumber? value}) =>
      BatchControl(mode: mode ?? this.mode, controller: controller ?? this.controller, value: value ?? this.value);
}

class BatchExpression {
  const BatchExpression({this.mode = BatchMode.keep, this.controller = 7, this.min = 0, this.max = 127});
  final BatchMode mode; // keep, off ou fixed (= ligar)
  final int controller;
  final int min;
  final int max;

  BatchExpression copyWith({BatchMode? mode, int? controller, int? min, int? max}) => BatchExpression(
    mode: mode ?? this.mode,
    controller: controller ?? this.controller,
    min: min ?? this.min,
    max: max ?? this.max,
  );
}

/// Liga, desliga ou deixa como está (relés).
enum BatchSwitch { keep, on, off }

/// Plano de programação em lote. A sequência conta a partir de 0 no primeiro
/// pedal escolhido, na ordem banco 0 pedal 1, banco 0 pedal 2...
class BatchPlan {
  const BatchPlan({
    this.programs = const [BatchNumber(), BatchNumber(), BatchNumber(), BatchNumber(), BatchNumber()],
    this.cc1 = const BatchControl(),
    this.cc2 = const BatchControl(),
    this.expA = const BatchExpression(controller: 7),
    this.expB = const BatchExpression(controller: 11),
    this.note = const BatchNumber(),
    this.relay1 = BatchSwitch.keep,
    this.relay2 = BatchSwitch.keep,
  });

  final List<BatchNumber> programs;
  final BatchControl cc1;
  final BatchControl cc2;
  final BatchExpression expA;
  final BatchExpression expB;
  final BatchNumber note;
  final BatchSwitch relay1;
  final BatchSwitch relay2;

  /// Receita pronta: cada pedal manda só o CC [controller] com um valor
  /// próprio (1, 2, 3...), sem trocas de programa, nota ou relés.
  factory BatchPlan.oneCcPerPedal({int controller = 102, int first = 1}) => BatchPlan(
    programs: const [
      BatchNumber(mode: BatchMode.off),
      BatchNumber(mode: BatchMode.off),
      BatchNumber(mode: BatchMode.off),
      BatchNumber(mode: BatchMode.off),
      BatchNumber(mode: BatchMode.off),
    ],
    cc1: BatchControl(mode: BatchMode.fixed, controller: controller, value: BatchNumber(mode: BatchMode.sequence, value: first)),
    cc2: const BatchControl(mode: BatchMode.off),
    note: const BatchNumber(mode: BatchMode.off),
    relay1: BatchSwitch.off,
    relay2: BatchSwitch.off,
  );

  /// Receita pronta: cada pedal troca para o programa de mesmo número
  /// (Program Change 0, 1, 2...), sem os demais itens.
  factory BatchPlan.programPerPedal({int first = 0}) => BatchPlan(
    programs: [
      BatchNumber(mode: BatchMode.sequence, value: first),
      const BatchNumber(mode: BatchMode.off),
      const BatchNumber(mode: BatchMode.off),
      const BatchNumber(mode: BatchMode.off),
      const BatchNumber(mode: BatchMode.off),
    ],
    cc1: const BatchControl(mode: BatchMode.off),
    cc2: const BatchControl(mode: BatchMode.off),
    note: const BatchNumber(mode: BatchMode.off),
    relay1: BatchSwitch.off,
    relay2: BatchSwitch.off,
  );

  BatchPlan copyWith({
    List<BatchNumber>? programs,
    BatchControl? cc1,
    BatchControl? cc2,
    BatchExpression? expA,
    BatchExpression? expB,
    BatchNumber? note,
    BatchSwitch? relay1,
    BatchSwitch? relay2,
  }) => BatchPlan(
    programs: programs ?? this.programs,
    cc1: cc1 ?? this.cc1,
    cc2: cc2 ?? this.cc2,
    expA: expA ?? this.expA,
    expB: expB ?? this.expB,
    note: note ?? this.note,
    relay1: relay1 ?? this.relay1,
    relay2: relay2 ?? this.relay2,
  );

  /// Se o plano muda alguma coisa.
  bool get changesSomething =>
      programs.any((p) => p.mode != BatchMode.keep) ||
      cc1.mode != BatchMode.keep ||
      cc2.mode != BatchMode.keep ||
      expA.mode != BatchMode.keep ||
      expB.mode != BatchMode.keep ||
      note.mode != BatchMode.keep ||
      relay1 != BatchSwitch.keep ||
      relay2 != BatchSwitch.keep;

  /// Como fica o [preset], que é o [n]-ésimo pedal escolhido (a partir de 0).
  FcbPreset applyTo(FcbPreset preset, int n) {
    FcbProgram program(FcbProgram p, BatchNumber rule) => switch (rule.mode) {
      BatchMode.keep => p,
      BatchMode.off => p.copyWith(enabled: false),
      _ => FcbProgram(enabled: true, program: rule.at(n)),
    };
    FcbControl control(FcbControl c, BatchControl rule) => switch (rule.mode) {
      BatchMode.keep => c,
      BatchMode.off => c.copyWith(enabled: false),
      _ => FcbControl(enabled: true, controller: rule.controller, value: rule.value.at(n)),
    };
    FcbExpression expression(FcbExpression e, BatchExpression rule) => switch (rule.mode) {
      BatchMode.keep => e,
      BatchMode.off => e.copyWith(enabled: false),
      _ => FcbExpression(enabled: true, controller: rule.controller, min: rule.min, max: rule.max),
    };
    bool relay(bool on, BatchSwitch rule) => switch (rule) {
      BatchSwitch.keep => on,
      BatchSwitch.on => true,
      BatchSwitch.off => false,
    };
    return FcbPreset(
      programs: [for (var k = 0; k < 5; k++) program(preset.programs[k], programs[k])],
      cc1: control(preset.cc1, cc1),
      cc2: control(preset.cc2, cc2),
      relay1: relay(preset.relay1, relay1),
      relay2: relay(preset.relay2, relay2),
      expA: expression(preset.expA, expA),
      expB: expression(preset.expB, expB),
      note: switch (note.mode) {
        BatchMode.keep => preset.note,
        BatchMode.off => preset.note.copyWith(enabled: false),
        _ => FcbNote(enabled: true, note: note.at(n)),
      },
    );
  }

  /// Aplica nos presets [indexes] (em ordem crescente).
  void apply(FcbSetup setup, Iterable<int> indexes) {
    final sorted = indexes.toList()..sort();
    for (final (n, i) in sorted.indexed) {
      setup.setPreset(i, applyTo(setup.preset(i), n));
    }
  }
}
