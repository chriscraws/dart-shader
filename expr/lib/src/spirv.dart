// This file contains spir-v constants, adapted from the SPIR-V
// specification at version 1.5. It also contains contants from
// the OpenGL Extended Instruction Set. This file only contains constants
// used in this package, it can be extended as necessary.

import 'dart:convert';
import 'dart:collection';
import 'dart:typed_data';

final _magicNumber = 0x07230203;

final _version = 0x00010500;

final _utf8Encoder = Utf8Encoder();

final _matrixCapability = const OpCapability._(0);
final _linkageCapability = const OpCapability._(5);
final _shaderCapability = const OpCapability._(1);

final _glslExtInstImport = const OpExtInstImport._('GLSL.std.450');

final _memoryModel = const OpMemoryModel._();

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
  final _ids = <Instruction, int>{};

  int _bound = 0;
  List<Instruction> _main;

  int identify(Instruction inst) {
    if (_ids.containsKey(inst)) {
      return _ids[inst];
    }

    int id = ++_bound;
    _ids[inst] = id;
    return id;
  }

  set main(Instruction fragColor) {
    assert(fragColor.type == vec4T);
    final pos = OpFunctionParameter(vec2T);
    final fnType = OpTypeFunction._(
      returnType: vec4T,
      paramTypes: [vec2T],
    );
    final fun = OpFunction._(fnType);
    _main = [
      fun,
      pos,
      OpLabel._(),
      OpReturnValue._(fragColor),
      _opFunctionEnd,
    ];
  }

  ByteBuffer encode() {
    _ids.clear();

    final instructions = <Instruction>[
      // capabilities
      _matrixCapability,
      _shaderCapability,
      _linkageCapability,

      // extension instruction imports
      _glslExtInstImport,

      // memory model
      _memoryModel,

      // type delcarations
      floatT,
      vec2T,
      vec3T,
      vec4T,
    ];

    // get main definition, and identify all dependent instructions.
    for (final inst in _main) {
      inst.resolve(this);
    }

    // insert all instruction/id pairs into a sorted map
    final sortedMap = SplayTreeMap.fromIterables(
      _ids.values, // ids as keys
      _ids.keys, // instructions as values
    );

    // add all instructions required by main, in order
    instructions.addAll(sortedMap.values
        .where((i) => !instructions.contains(i) && !_main.contains(i)));

    final words = <int>[
      _magicNumber,
      _version,
      0, // generator's magic number
      0, // bound
      0, // reserved.
    ];

    for (final instruction in instructions) {
      words.addAll(instruction.encode(this));
    }

    words.addAll(_main.map((i) => i.encode(this)).expand((words) => words));

    words[3] = _bound + 1;

    return Int32List.fromList(words).buffer;
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

  void resolve(Identifier i) {
    for (final dep in deps) {
      dep.resolve(i);
    }
    if (result) {
      i.identify(this);
    }
  }

  List<int> operands(Identifier i) => [];

  List<int> encode(Identifier i) {
    final ops = operands(i);
    int wordCount = ops.length + 1;
    if (type != null) wordCount++;
    if (result) wordCount++;
    return <int>[
      wordCount << 16 | opCode,
      if (type != null) i.identify(type),
      if (result) i.identify(this),
      ...ops,
    ];
  }

  List<Instruction> get deps => [];
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
          result: true,
          opCode: 11,
        );

  List<int> operands(Identifier i) => [
        ..._utf8Encoder.convert(name).buffer.asInt32List(),
        0, // null padding
      ];
}

class OpMemoryModel extends Instruction {
  const OpMemoryModel._()
      : super._(
          opCode: 14,
        );

  List<int> operands(Identifier i) => [0, 1];
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

  List<Instruction> get deps => [componentType];
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

class OpTypeFunction extends Instruction {
  final Type returnType;
  final List<Type> paramTypes;

  OpTypeFunction._({
    this.returnType,
    this.paramTypes = const [],
  })  : assert(returnType != null),
        super._(
          opCode: 33,
          result: true,
        );

  List<int> operands(Identifier i) => [
        i.identify(returnType),
        ...paramTypes.map((t) => i.identify(t)),
      ];

  List<Instruction> get deps => [returnType];
}

class OpFunction extends Instruction {
  final OpTypeFunction fnType;
  OpFunction._(this.fnType)
      : super._(
          result: true,
          type: fnType.returnType,
          opCode: 54,
        );

  List<int> operands(Identifier i) => [
        8, // const function
        i.identify(fnType), // function type
      ];

  List<Instruction> get deps => [fnType];
}

class OpFunctionEnd extends Instruction {
  const OpFunctionEnd._()
      : super._(
          opCode: 56,
        );
}

final _opFunctionEnd = const OpFunctionEnd._();

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

class OpReturnValue extends Instruction {
  final Instruction value;

  const OpReturnValue._(this.value)
      : super._(
          opCode: 254,
        );

  List<int> operands(Identifier i) => [i.identify(value)];

  List<Instruction> get deps => [value];
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

  OpConstantComposite.vec2(double x, double y) : this._(vec2T, [x, y]);

  OpConstantComposite.vec3(double x, double y, double z)
      : this._(vec3T, [x, y, z]);

  OpConstantComposite.vec4(double x, double y, double z, double w)
      : this._(vec4T, [x, y, z, w]);

  List<int> operands(Identifier i) =>
      constituants.map((op) => i.identify(op)).toList();

  List<Instruction> get deps => List<Instruction>.from(constituants);
}

// Numerical operation with one arguments.
class UniOp extends Instruction {
  final Instruction a;

  UniOp(int opCode, this.a)
      : assert(opCode != null),
        assert(a != null),
        super._(
          type: a.type,
          result: true,
          opCode: opCode,
        );

  List<Instruction> get deps => [a];
}

class OpFNegate extends UniOp {
  OpFNegate(Instruction a) : super(127, a);
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

  List<Instruction> get deps => [a, b];
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

class OpFMod extends BinOp {
  OpFMod(Instruction a, Instruction b) : super(141, a, b);
}

class OpFDot extends Instruction {
  final Instruction a;
  final Instruction b;

  OpFDot(this.a, this.b)
      : assert(a.type == b.type),
        super._(
          type: floatT,
          result: true,
          opCode: 148,
        );

  List<Instruction> get deps => [a, b];
}

class OpVectorTimesScalar extends Instruction {
  final Instruction a;
  final Instruction b;

  OpVectorTimesScalar(this.a, this.b)
      : assert(a.type != floatT),
        super._(
          type: a.type,
          result: true,
          opCode: 142,
        );

  List<Instruction> get deps => [a, b];
}

abstract class OpExtInst extends Instruction {
  final int extOp;
  final List<Instruction> deps;

  OpExtInst(this.extOp, this.deps)
      : assert(deps.length > 0),
        assert(!deps.any((dep) => dep.type != deps[0].type)),
        super._(
          opCode: 12,
          type: deps[0].type,
          result: true,
        );
}

class Trunc extends OpExtInst {
  Trunc(Instruction a) : super(_GLInstructionID.trunc, [a]);
}

class FAbs extends OpExtInst {
  FAbs(Instruction a) : super(_GLInstructionID.fabs, [a]);
}

class FSign extends OpExtInst {
  FSign(Instruction a) : super(_GLInstructionID.fsign, [a]);
}

class Floor extends OpExtInst {
  Floor(Instruction a) : super(_GLInstructionID.floor, [a]);
}

class Ceil extends OpExtInst {
  Ceil(Instruction a) : super(_GLInstructionID.ceil, [a]);
}

class Fract extends OpExtInst {
  Fract(Instruction a) : super(_GLInstructionID.fract, [a]);
}

class Radians extends OpExtInst {
  Radians(Instruction a) : super(_GLInstructionID.radians, [a]);
}

class Degrees extends OpExtInst {
  Degrees(Instruction a) : super(_GLInstructionID.degrees, [a]);
}

class Sin extends OpExtInst {
  Sin(Instruction a) : super(_GLInstructionID.sin, [a]);
}

class Cos extends OpExtInst {
  Cos(Instruction a) : super(_GLInstructionID.cos, [a]);
}

class Tan extends OpExtInst {
  Tan(Instruction a) : super(_GLInstructionID.tan, [a]);
}

class ASin extends OpExtInst {
  ASin(Instruction a) : super(_GLInstructionID.asin, [a]);
}

class ACos extends OpExtInst {
  ACos(Instruction a) : super(_GLInstructionID.acos, [a]);
}

class ATan extends OpExtInst {
  ATan(Instruction a) : super(_GLInstructionID.atan, [a]);
}

class Exp extends OpExtInst {
  Exp(Instruction a) : super(_GLInstructionID.exp, [a]);
}

class Log extends OpExtInst {
  Log(Instruction a) : super(_GLInstructionID.log, [a]);
}

class Exp2 extends OpExtInst {
  Exp2(Instruction a) : super(_GLInstructionID.exp2, [a]);
}

class Log2 extends OpExtInst {
  Log2(Instruction a) : super(_GLInstructionID.log2, [a]);
}

class Sqrt extends OpExtInst {
  Sqrt(Instruction a) : super(_GLInstructionID.sqrt, [a]);
}

class InverseSqrt extends OpExtInst {
  InverseSqrt(Instruction a) : super(_GLInstructionID.inverseSqrt, [a]);
}

class Length extends OpExtInst {
  Length(Instruction a) : super(_GLInstructionID.length, [a]);
}

class Normalize extends OpExtInst {
  Normalize(Instruction a) : super(_GLInstructionID.normalize, [a]);
}

class ATan2 extends OpExtInst {
  ATan2(Instruction a, Instruction b) : super(_GLInstructionID.atan2, [a, b]);
}

class Pow extends OpExtInst {
  Pow(Instruction a, Instruction b) : super(_GLInstructionID.pow, [a, b]);
}

class FMin extends OpExtInst {
  FMin(Instruction a, Instruction b) : super(_GLInstructionID.fmin, [a, b]);
}

class FMax extends OpExtInst {
  FMax(Instruction a, Instruction b) : super(_GLInstructionID.fmax, [a, b]);
}

class FClamp extends OpExtInst {
  FClamp(Instruction x, Instruction min, Instruction max)
      : super(_GLInstructionID.fclamp, [x, min, max]);
}

class FMix extends OpExtInst {
  FMix(Instruction x, Instruction y, Instruction a)
      : super(_GLInstructionID.fmix, [x, y, a]);
}

class Step extends OpExtInst {
  Step(Instruction edge, Instruction x)
      : super(_GLInstructionID.step, [edge, x]);
}

class SmoothStep extends OpExtInst {
  SmoothStep(Instruction edge0, Instruction edge1, Instruction x)
      : super(_GLInstructionID.smoothstep, [edge0, edge1, x]);
}

class Distance extends OpExtInst {
  Distance(Instruction a, Instruction b)
      : super(_GLInstructionID.distance, [a, b]);
}

class Cross extends OpExtInst {
  Cross(Instruction a, Instruction b) : super(_GLInstructionID.cross, [a, b]);
}

class FaceForward extends OpExtInst {
  FaceForward(Instruction n, Instruction i)
      : super(_GLInstructionID.faceforward, [n, i]);
}

class Reflect extends OpExtInst {
  Reflect(Instruction i, Instruction n)
      : super(_GLInstructionID.reflect, [i, n]);
}
