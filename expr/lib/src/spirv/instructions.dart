// This file contains class representations of SPIR-V instructions
// from https://www.khronos.org/registry/spir-v/specs/unified1/SPIRV.html#_a_id_instructions_a_instructions

import 'dart:convert';
import 'dart:typed_data';

import 'instruction.dart';

const floatT = OpTypeFloat._(32);
const vec2T = OpTypeVec._(floatT, 2);
const vec3T = OpTypeVec._(floatT, 3);
const vec4T = OpTypeVec._(floatT, 4);

List<int> _toWords(String string) => [
  ...Uint8List.fromList(utf8.encode(string)).buffer.asInt32List(),
  0,  // null padding
];

class OpCapability extends Instruction {
  static const matrix = OpCapability._(0);
  static const shader = OpCapability._(1);
  static const linkage = OpCapability._(5);

  final int capability;

  const OpCapability._(this.capability)
      : super(
          opCode: 17,
        );

  List<int> operands(Identifier i) => [capability];
}

class OpDecorate extends Instruction {
  final Instruction target;
  final int decoration;
  final List<int> extraOperands;
  final List<Instruction> deps;

  static const int linkageAttributes = 41;
  static const int linkageExport = 0;

  OpDecorate({
    this.decoration,
    this.extraOperands,
    this.target,
  }) : deps = [target], super(
    opCode: 71,
    isDecoration: true,
  );

  OpDecorate.export({
    Instruction target,
    String name,
  }) : this(
    target: target,
    decoration: linkageAttributes,
    extraOperands: [
      ..._toWords(name),
      linkageExport,
    ],
  );

  List<int> operands(Identifier i) => [
    i.identify(target),
    decoration,
    ...extraOperands,
  ];
}

class OpExtInstImport extends Instruction {
  static const glsl = OpExtInstImport._('GLSL.std.450');

  final String name;

  const OpExtInstImport._(this.name)
      : super(
          result: true,
          opCode: 11,
        );

  List<int> operands(Identifier i) => _toWords(name);
}

class OpMemoryModel extends Instruction {
  static const glsl = OpMemoryModel._();

  const OpMemoryModel._()
      : super(
          opCode: 14,
        );

  List<int> operands(Identifier i) => [0, 1];
}

class OpTypeFloat extends Instruction with Type {
  final int bitWidth;

  const OpTypeFloat._(this.bitWidth)
      : super(
          result: true,
          opCode: 22,
          isType: true,
        );

  List<int> operands(Identifier i) => [bitWidth];
}

class OpTypeVec extends Instruction with Type {
  final Type componentType;
  final int dimensions;

  const OpTypeVec._(this.componentType, this.dimensions)
      : assert(componentType != null),
        assert(dimensions > 1),
        super(
          result: true,
          opCode: 23,
          isType: true,
        );

  List<int> operands(Identifier i) => [
        i.identify(componentType),
        dimensions,
      ];

  List<Instruction> get deps => [componentType];
}

class OpTypeFunction extends Instruction {
  final Type returnType;
  final List<Type> paramTypes;

  OpTypeFunction({
    this.returnType,
    this.paramTypes = const [],
  })  : assert(returnType != null),
        super(
          opCode: 33,
          result: true,
          isType: true,
        );

  List<int> operands(Identifier i) => [
        i.identify(returnType),
        ...paramTypes.map((t) => i.identify(t)),
      ];

  List<Instruction> get deps => [returnType];
}

class OpFunction extends Instruction {
  final OpTypeFunction fnType;
  OpFunction(this.fnType)
      : super(
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
  const OpFunctionEnd()
      : super(
          opCode: 56,
        );
}

class OpFunctionParameter extends Instruction {
  const OpFunctionParameter(Type type)
      : super(
          type: type,
          opCode: 55,
          result: true,
        );
}

class OpLabel extends Instruction {
  const OpLabel()
      : super(
          opCode: 248,
          result: true,
        );
}

class OpReturnValue extends Instruction {
  final Instruction value;

  const OpReturnValue(this.value)
      : super(
          opCode: 254,
        );

  List<int> operands(Identifier i) => [i.identify(value)];

  List<Instruction> get deps => [value];
}

class OpConstant extends Instruction {
  final double value;

  OpConstant(this.value)
      : super(
          isDeclaration: true,
          opCode: 43,
          result: true,
          type: floatT,
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
        super(
          isDeclaration: true,
          opCode: 44,
          type: type,
          result: true,
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
        super(
          type: a.type,
          result: true,
          opCode: opCode,
        );

  List<int> operands(Identifier i) => [i.identify(a)];

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
        super(
          type: a.type,
          result: true,
          opCode: opCode,
        );

  List<int> operands(Identifier i) => deps.map((d) => i.identify(d)).toList();

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
        super(
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
        assert(b.type == floatT),
        super(
          type: a.type,
          result: true,
          opCode: 142,
        );

  List<int> operands(Identifier i) => deps.map((d) => i.identify(d)).toList();

  List<Instruction> get deps => [a, b];
}

abstract class OpExtInst extends Instruction {
  final int extOp;
  final List<Instruction> deps;

  OpExtInst(this.extOp, this.deps)
      : assert(deps.length > 0),
        assert(!deps.any((dep) => dep.type != deps[0].type)),
        super(
          opCode: 12,
          type: deps[0].type,
          result: true,
        );

  List<int> operands(Identifier i) => [
        i.identify(OpExtInstImport.glsl),
        extOp,
        ...deps.map((inst) => i.identify(inst)),
      ];
}
