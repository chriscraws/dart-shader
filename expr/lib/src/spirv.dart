// This file contains spir-v constants, adapted from the SPIR-V
// specification at version 1.5. It also contains contants from
// the OpenGL Extended Instruction Set. This file only contains constants
// used in this package, it can be extended as necessary.

import 'dart:convert';
import 'dart:typed_data';

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
          result: true,
          opCode: 22,
        );

  List<int> operands(Identifier i) => [bitWidth];
}

class OpTypeVec extends Instruction with Type {
  final Type componentType;
  final int dimensions;

  const OpTypeVec._(this.componentType, this.dimensions)
      : assert(componentType != null),
        assert(dimensions > 1),
        super._(
          result: true,
          opCode: 23,
        );

  List<int> operands(Identifier i) => [
        i.identify(componentType),
        dimensions,
      ];
}

class Precision {
  final int bitWidth;
  const Precision._(this.bitWidth);
}

final mediumP = Precision._(32);

final floatT = const OpTypeFloat._(32);
final vec2T = OpTypeVec._(floatT, 2);
final vec3T = OpTypeVec._(floatT, 3);
final vec4T = OpTypeVec._(floatT, 4);

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

class OpConstant extends Instruction {
  final double value;

  OpConstant(this.value)
      : super._(
          type: floatT,
          result: true,
          opCode: 43,
        );

  List<int> operands(Identifier i) =>
      Float32List.fromList([value]).buffer.asInt32List();
}

class OpConstantComposite extends Instruction {
  final List<OpConstant> constituants;

  OpConstantComposite._(Type type, List<double> constituants)
      : assert(constituants != null),
        assert(constituants.length > 1),
        assert(constituants.every((c) => c != null)),
        constituants = constituants.map((v) => OpConstant(v)).toList(),
        super._(
          type: type,
          result: true,
          opCode: 44,
        );

  OpConstantComposite.vec4(double x, double y, double z, double w)
      : this._(vec4T, [x, y, z, w]);

  List<int> operands(Identifier i) =>
      constituants.map((op) => i.identify(op)).toList();
}

// Numerical operation with one arguments.
class UniOp extends Instruction {
  final Instruction a;

  UniOp(int opCode, this.a)
      : super._(
          type: a.type,
          result: true,
          opCode: opCode,
        );
}

// Numerical operation with two arguments.
class BinOp extends Instruction {
  final Instruction a;
  final Instruction b;

  BinOp(int opCode, this.a, this.b)
      : assert(a.type == b.type),
        super._(
          type: a.type,
          result: true,
          opCode: opCode,
        );
}

class OpFAdd extends BinOp {
  OpFAdd(Instruction a, Instruction b) : super(129, a, b);
}

class OpFSub extends BinOp {
  OpFSub(Instruction a, Instruction b) : super(131, a, b);
}

class OpFMul extends BinOp {
  OpFMul(Instruction a, Instruction b) : super(133, a, b);
}

class OpFDiv extends BinOp {
  OpFDiv(Instruction a, Instruction b) : super(136, a, b);
}
