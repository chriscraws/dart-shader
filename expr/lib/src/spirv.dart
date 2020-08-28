// This file contains spir-v constants, adapted from the SPIR-V
// specification at version 1.5. It also contains contants from
// the OpenGL Extended Instruction Set. This file only contains constants
// used in this package, it can be extended as necessary.

import 'dart:convert';

final _magicNumber = 0x07230203;

final _version = 0x00010500;

final _utf8Encoder = Utf8Encoder();

class _SourceLanguage {
  static const unknown = 0;
}

class _Capability {
  static const matrix = OpCapability._(0);
  static const linkage = OpCapability._(5);
}

class _GLInstructionID {
  static const trunc = 3;
  static const fabs = 4;
  static const fsign = 6;
  static const floor = 8;
  static const ceil = 9;
  static const fract = 10;
  static const radians = 11;
  static const degrees = 12;
  static const sin = 13;
  static const cos = 14;
  static const tan = 15;
  static const asin = 16;
  static const acos = 17;
  static const atan = 18;
  static const atan2 = 25;
  static const pow = 26;
  static const exp = 27;
  static const log = 28;
  static const exp2 = 29;
  static const log2 = 30;
  static const sqrt = 31;
  static const inverseSqrt = 32;
  static const modf = 35;
  static const fmin = 37;
  static const fmax = 40;
  static const fclamp = 43;
  static const fmix = 46;
  static const step = 48;
  static const smoothstep = 49;
  static const length = 66;
  static const distance = 67;
  static const cross = 68;
  static const normalize = 69;
  static const faceforward = 70;
  static const reflect = 71;
}

abstract class Identifier {
  int identify(Instruction inst);
}

class Module extends Identifier {
  int _bound = 0;
  Map<Instruction, int> _ids;

  int identify(Instruction inst) {
    if (_ids.containsKey(inst)) {
      return _ids[inst];
    }

    if (_bound == 0) {
      _bound++;
    }

    int id = _bound;
    _ids[inst] = _bound;
    _bound++;
    return id;
  }
}

abstract class Instruction {
  final Type type;
  final int opCode;
  final bool result;

  const Instruction._({
    this.opCode,
    this.type,
    this.result = false,
  });

  List<int> operands(Identifier i) => [];

  List<int> encode(Identifier i) {
    final ops = operands(i);
    return <int>[
      ops.length << 16 | opCode,
      if (type != null) i.identify(type),
      if (result) i.identify(this),
      ...ops,
    ];
  }
}

class OpCapability extends Instruction {
  final int capability;

  const OpCapability._(this.capability)
      : super._(
          opCode: 17,
        );

  List<int> operands(Identifier i) => [capability];
}

class OpExtInstImport extends Instruction {
  final String name;

  const OpExtInstImport._(this.name)
      : super._(
          opCode: 10,
        );

  List<int> operands(Identifier i) => _utf8Encoder.convert(name);
}

class OpMemoryModel extends Instruction {
  const OpMemoryModel._()
      : super._(
          opCode: 14,
        );

  List<int> operands(Identifier i) => [0, 0];
}

mixin Type on Instruction {}

class OpTypeFloat extends Instruction with Type {
  final int bitWidth;

  const OpTypeFloat._(this.bitWidth)
      : super._(
          opCode: 22,
        );

  List<int> operands(Identifier i) => [bitWidth];
}

class Precision {
  final int bitWidth;
  const Precision._(this.bitWidth);
}

final lowP = Precision._(8);
final mediumP = Precision._(12);
final highP = Precision._(16);

final floatT = OpTypeFloat._(highP.bitWidth);

const _opFunctionEnd = 1 << 16 | 56;

class OpFunction extends Instruction {
  final List<OpFunctionParameter> params;
  final List<Block> blocks;

  const OpFunction._({
    Type type,
    this.params,
    this.blocks,
  }) : super._(
          type: type,
          opCode: 54,
        );

  List<int> operands(Identifier i) =>
      params.map((p) => p.encode(i)).expand((words) => words).toList()
        ..addAll(blocks.map((b) => b.encode(i)).expand((words) => words))
        ..add(_opFunctionEnd);
}

class OpFunctionParameter extends Instruction {
  const OpFunctionParameter(Type type)
      : super._(
          type: type,
          opCode: 55,
          result: true,
        );
}

class OpLabel extends Instruction {
  const OpLabel._()
      : super._(
          opCode: 248,
          result: true,
        );
}

mixin Branch on Instruction {}

class OpReturnValue extends Instruction with Branch {
  final Instruction value;

  const OpReturnValue._(this.value)
      : super._(
          opCode: 254,
        );

  List<int> operands(Identifier i) => [i.identify(value)];
}

class Block {
  final OpLabel label = OpLabel._();
  final Branch termination;

  Block._({
    this.termination,
  });

  List<int> encode(Identifier i) => [
        ...label.encode(i),
        ...termination.encode(i),
      ];
}
