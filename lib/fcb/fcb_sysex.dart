import 'dart:typed_data';

/// Dump SysEx completo da Behringer FCB1010 (firmware original).
///
/// Formato (engenharia reversa da comunidade: fcbtool de Jason March, a partir
/// do trabalho de Brian Walton, e o editor fcb1010.online):
/// - 2352 bytes: `F0 00 20 32 01 0C 0F`, 2344 bytes de dados e `F7`.
/// - Os dados vêm em grupos de 8 bytes: 7 bytes com os 7 bits baixos e um 8º
///   com o bit alto de cada um (bit y = byte y do grupo). Desempacotados, dão
///   2051 bytes de 8 bits.
/// - 100 presets de 16 bytes (banco 0 pedal 1 primeiro). Em cada byte, os 7
///   bits baixos são o valor e o bit alto é o "desligado" (ou, nos bytes 6 e 8,
///   o relé ligado).
/// - Configurações globais a partir do byte 2016.
///
/// O que o app não entende é preservado: as edições mexem só nos bytes
/// conhecidos do dump de base.
abstract final class FcbSysex {
  static const length = 2352;
  static const header = [0xF0, 0x00, 0x20, 0x32, 0x01, 0x0C, 0x0F];
  static const groups = (length - 7 - 1) ~/ 8; // 293 (cabeçalho de 7 bytes e F7)
  static const decodedLength = groups * 7; // 2051

  /// Se [raw] é um dump completo da FCB1010.
  static bool isDump(List<int> raw) {
    if (raw.length != length || raw.last != 0xF7) return false;
    for (var i = 0; i < header.length; i++) {
      if (raw[i] != header[i]) return false;
    }
    for (var i = 1; i < length - 1; i++) {
      if (raw[i] > 0x7F) return false;
    }
    return true;
  }

  static Uint8List unpack(List<int> raw) {
    final out = Uint8List(decodedLength);
    for (var g = 0; g < groups; g++) {
      final base = header.length + g * 8;
      final msb = raw[base + 7];
      for (var y = 0; y < 7; y++) {
        out[g * 7 + y] = raw[base + y] | (((msb >> y) & 1) << 7);
      }
    }
    return out;
  }

  static Uint8List pack(Uint8List decoded) {
    final out = Uint8List(length);
    out.setAll(0, header);
    for (var g = 0; g < groups; g++) {
      final base = header.length + g * 8;
      var msb = 0;
      for (var y = 0; y < 7; y++) {
        final b = decoded[g * 7 + y];
        out[base + y] = b & 0x7F;
        msb |= ((b >> 7) & 1) << y;
      }
      out[base + 7] = msb;
    }
    out[length - 1] = 0xF7;
    return out;
  }
}

/// Uma das 5 trocas de programa (Program Change) do preset.
class FcbProgram {
  const FcbProgram({required this.enabled, required this.program});
  final bool enabled;
  final int program;

  FcbProgram copyWith({bool? enabled, int? program}) =>
      FcbProgram(enabled: enabled ?? this.enabled, program: program ?? this.program);

  @override
  bool operator ==(Object other) => other is FcbProgram && other.enabled == enabled && other.program == program;
  @override
  int get hashCode => Object.hash(enabled, program);
}

/// Control Change fixo mandado ao pisar no pedal.
class FcbControl {
  const FcbControl({required this.enabled, required this.controller, required this.value});
  final bool enabled;
  final int controller;
  final int value;

  FcbControl copyWith({bool? enabled, int? controller, int? value}) => FcbControl(
    enabled: enabled ?? this.enabled,
    controller: controller ?? this.controller,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      other is FcbControl && other.enabled == enabled && other.controller == controller && other.value == value;
  @override
  int get hashCode => Object.hash(enabled, controller, value);
}

/// Pedal de expressão (A ou B): manda o CC entre [min] e [max].
class FcbExpression {
  const FcbExpression({required this.enabled, required this.controller, required this.min, required this.max});
  final bool enabled;
  final int controller;
  final int min;
  final int max;

  FcbExpression copyWith({bool? enabled, int? controller, int? min, int? max}) => FcbExpression(
    enabled: enabled ?? this.enabled,
    controller: controller ?? this.controller,
    min: min ?? this.min,
    max: max ?? this.max,
  );

  @override
  bool operator ==(Object other) =>
      other is FcbExpression &&
      other.enabled == enabled &&
      other.controller == controller &&
      other.min == min &&
      other.max == max;
  @override
  int get hashCode => Object.hash(enabled, controller, min, max);
}

/// Nota MIDI mandada ao pisar no pedal.
class FcbNote {
  const FcbNote({required this.enabled, required this.note});
  final bool enabled;
  final int note;

  FcbNote copyWith({bool? enabled, int? note}) => FcbNote(enabled: enabled ?? this.enabled, note: note ?? this.note);

  @override
  bool operator ==(Object other) => other is FcbNote && other.enabled == enabled && other.note == note;
  @override
  int get hashCode => Object.hash(enabled, note);
}

/// Tudo o que um pedal (preset) manda.
class FcbPreset {
  const FcbPreset({
    required this.programs,
    required this.cc1,
    required this.cc2,
    required this.relay1,
    required this.relay2,
    required this.expA,
    required this.expB,
    required this.note,
  });

  final List<FcbProgram> programs;
  final FcbControl cc1;
  final FcbControl cc2;
  final bool relay1;
  final bool relay2;
  final FcbExpression expA;
  final FcbExpression expB;
  final FcbNote note;

  FcbPreset copyWith({
    List<FcbProgram>? programs,
    FcbControl? cc1,
    FcbControl? cc2,
    bool? relay1,
    bool? relay2,
    FcbExpression? expA,
    FcbExpression? expB,
    FcbNote? note,
  }) => FcbPreset(
    programs: programs ?? this.programs,
    cc1: cc1 ?? this.cc1,
    cc2: cc2 ?? this.cc2,
    relay1: relay1 ?? this.relay1,
    relay2: relay2 ?? this.relay2,
    expA: expA ?? this.expA,
    expB: expB ?? this.expB,
    note: note ?? this.note,
  );

  FcbPreset withProgram(int i, FcbProgram p) => copyWith(programs: [...programs]..[i] = p);

  /// Nada ligado: o pedal não manda nada (fora os pedais de expressão).
  bool get silent =>
      programs.every((p) => !p.enabled) && !cc1.enabled && !cc2.enabled && !note.enabled && !relay1 && !relay2;

  @override
  bool operator ==(Object other) =>
      other is FcbPreset &&
      _listEq(other.programs, programs) &&
      other.cc1 == cc1 &&
      other.cc2 == cc2 &&
      other.relay1 == relay1 &&
      other.relay2 == relay2 &&
      other.expA == expA &&
      other.expB == expB &&
      other.note == note;
  @override
  int get hashCode => Object.hash(Object.hashAll(programs), cc1, cc2, relay1, relay2, expA, expB, note);
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Tipos de mensagem com canal MIDI próprio (configuração global).
enum FcbChannel { program1, program2, program3, program4, program5, control1, control2, expressionA, expressionB, note }

/// Configurações globais.
class FcbGlobals {
  const FcbGlobals({
    required this.channels,
    required this.directSelect,
    required this.runningStatus,
    required this.merge,
    required this.upTogglesRelay1,
    required this.downTogglesRelay2,
  });

  /// Canal de cada tipo de mensagem, 0–15 (= canais 1–16), na ordem de [FcbChannel].
  final List<int> channels;
  final bool directSelect;
  final bool runningStatus;
  final bool merge;

  /// Com a seleção direta ligada, UP liga/desliga o relé 1 e DOWN o relé 2.
  final bool upTogglesRelay1;
  final bool downTogglesRelay2;

  FcbGlobals copyWith({
    List<int>? channels,
    bool? directSelect,
    bool? runningStatus,
    bool? merge,
    bool? upTogglesRelay1,
    bool? downTogglesRelay2,
  }) => FcbGlobals(
    channels: channels ?? this.channels,
    directSelect: directSelect ?? this.directSelect,
    runningStatus: runningStatus ?? this.runningStatus,
    merge: merge ?? this.merge,
    upTogglesRelay1: upTogglesRelay1 ?? this.upTogglesRelay1,
    downTogglesRelay2: downTogglesRelay2 ?? this.downTogglesRelay2,
  );

  @override
  bool operator ==(Object other) =>
      other is FcbGlobals &&
      _listEq(other.channels, channels) &&
      other.directSelect == directSelect &&
      other.runningStatus == runningStatus &&
      other.merge == merge &&
      other.upTogglesRelay1 == upTogglesRelay1 &&
      other.downTogglesRelay2 == downTogglesRelay2;
  @override
  int get hashCode =>
      Object.hash(Object.hashAll(channels), directSelect, runningStatus, merge, upTogglesRelay1, downTogglesRelay2);
}

/// Configuração completa da FCB1010: os bytes desempacotados do dump.
class FcbSetup {
  FcbSetup._(this.data);

  static const presetCount = 100;
  static const banks = 10;
  static const pedalsPerBank = 10;
  static const _presetSize = 16;
  static const _channels = 2016;
  static const _relayKeys = 2032;
  static const _flags = 2033;

  /// Bytes de 8 bits desempacotados (2051).
  final Uint8List data;

  factory FcbSetup.fromSysex(List<int> raw) {
    if (!FcbSysex.isDump(raw)) throw const FormatException('não é um dump da FCB1010');
    return FcbSetup._(FcbSysex.unpack(raw));
  }

  FcbSetup copy() => FcbSetup._(Uint8List.fromList(data));

  Uint8List toSysex() => FcbSysex.pack(data);

  static int indexOf(int bank, int pedal) => bank * pedalsPerBank + pedal;

  int _v(int i) => data[i] & 0x7F;
  bool _hi(int i) => data[i] & 0x80 != 0;
  void _set(int i, int value, bool hi) => data[i] = (value.clamp(0, 127)) | (hi ? 0x80 : 0);

  FcbPreset preset(int index) {
    final o = index * _presetSize;
    return FcbPreset(
      programs: [for (var k = 0; k < 5; k++) FcbProgram(enabled: !_hi(o + k), program: _v(o + k))],
      cc1: FcbControl(enabled: !_hi(o + 5), controller: _v(o + 5), value: _v(o + 6)),
      relay1: _hi(o + 6),
      cc2: FcbControl(enabled: !_hi(o + 7), controller: _v(o + 7), value: _v(o + 8)),
      relay2: _hi(o + 8),
      expA: FcbExpression(enabled: !_hi(o + 9), controller: _v(o + 9), min: data[o + 10], max: data[o + 11]),
      expB: FcbExpression(enabled: !_hi(o + 12), controller: _v(o + 12), min: data[o + 13], max: data[o + 14]),
      note: FcbNote(enabled: !_hi(o + 15), note: _v(o + 15)),
    );
  }

  void setPreset(int index, FcbPreset p) {
    final o = index * _presetSize;
    for (var k = 0; k < 5; k++) {
      _set(o + k, p.programs[k].program, !p.programs[k].enabled);
    }
    _set(o + 5, p.cc1.controller, !p.cc1.enabled);
    _set(o + 6, p.cc1.value, p.relay1);
    _set(o + 7, p.cc2.controller, !p.cc2.enabled);
    _set(o + 8, p.cc2.value, p.relay2);
    _set(o + 9, p.expA.controller, !p.expA.enabled);
    data[o + 10] = p.expA.min.clamp(0, 127);
    data[o + 11] = p.expA.max.clamp(0, 127);
    _set(o + 12, p.expB.controller, !p.expB.enabled);
    data[o + 13] = p.expB.min.clamp(0, 127);
    data[o + 14] = p.expB.max.clamp(0, 127);
    _set(o + 15, p.note.note, !p.note.enabled);
  }

  FcbGlobals get globals => FcbGlobals(
    channels: [for (var k = 0; k < FcbChannel.values.length; k++) data[_channels + k] & 0x0F],
    directSelect: data[_flags] & 0x02 != 0,
    runningStatus: data[_flags] & 0x04 != 0,
    merge: data[_flags] & 0x10 != 0,
    upTogglesRelay1: data[_relayKeys] & 0x80 != 0,
    downTogglesRelay2: data[_relayKeys] & 0x40 != 0,
  );

  set globals(FcbGlobals g) {
    for (var k = 0; k < FcbChannel.values.length; k++) {
      data[_channels + k] = g.channels[k].clamp(0, 15);
    }
    int bit(int byte, int mask, bool on) => on ? byte | mask : byte & ~mask;
    var f = data[_flags];
    f = bit(f, 0x02, g.directSelect);
    f = bit(f, 0x04, g.runningStatus);
    f = bit(f, 0x10, g.merge);
    data[_flags] = f;
    var r = data[_relayKeys];
    r = bit(r, 0x80, g.upTogglesRelay1);
    r = bit(r, 0x40, g.downTogglesRelay2);
    data[_relayKeys] = r;
  }
}
