// This file contains class representations of SPIR-V instructions
// from https://www.khronos.org/registry/spir-v/specs/unified1/SPIRV.html#_a_id_instructions_a_instructions

import 'dart:convert';
import 'dart:typed_data';

import 'instruction.dart';

final _storageClassUniform = 2;

const floatT = OpTypeFloat._(32);
const vec2T = OpTypeVec._(floatT, 2);
const vec3T = OpTypeVec._(floatT, 3);
const vec4T = OpTypeVec._(floatT, 4);

const uniformFloatT = OpTypePointer._(floatT);
const uniformVec2T = OpTypePointer._(vec2T);
const uniformVec3T = OpTypePointer._(vec3T);
const uniformVec4T = OpTypePointer._(vec4T);

List<int> _toWords(String string) => [
      ...Uint8List.fromList(utf8.encode(string)).buffer.asInt32List(),
      0, // null padding
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
  })  : deps = [target],
        super(
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

  final int elementCount = 1;

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
  final int elementCount;

  const OpTypeVec._(this.componentType, this.elementCount)
      : assert(componentType != null),
        assert(elementCount > 1),
        super(
          result: true,
          opCode: 23,
          isType: true,
        );

  List<int> operands(Identifier i) => [
        i.identify(componentType),
        elementCount,
      ];

  List<Instruction> get deps => [componentType];
}

class OpTypePointer extends Instruction with Type {
  final int elementCount = -1;
  final Type objectType;

  const OpTypePointer._(this.objectType)
      : assert(objectType != null),
        super(
          result: true,
          opCode: 32,
        );

  List<int> operands(Identifier i) => [
        _storageClassUniform,
        i.identify(objectType),
      ];

  List<Instruction> get deps => [objectType];
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
        0, // no function control
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

class OpFunctionParameter extends Instruction with Evaluable {
  const OpFunctionParameter(Type type)
      : super(
          type: type,
          opCode: 55,
          result: true,
        );

  List<double> evaluate() => List<double>(type.elementCount);
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

class OpConstant extends Instruction with Evaluable {
  OpConstant(double value)
      : super(
          constant: value,
          isDeclaration: true,
          opCode: 43,
          result: true,
          type: floatT,
        );

  List<int> operands(Identifier i) =>
      Float32List.fromList([constant]).buffer.asInt32List();

  List<double> evaluate() => [constant];
}

class OpConstantComposite extends Instruction with Evaluable {
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

  List<double> evaluate() => constituants.fold([], (out, child) {
        out.addAll(child.evaluate());
        return out;
      });
}

class OpVariable extends Instruction {
  final Type objectType;

  final List<double> variable;

  OpVariable._(OpTypePointer type)
      : assert(type != null),
        objectType = type.objectType,
        variable = List<double>(type.objectType.elementCount),
        super(
          isDeclaration: true,
          opCode: 59,
          result: true,
          type: type,
        );

  OpVariable.scalarUniform() : this._(uniformFloatT);
  OpVariable.vec2Uniform() : this._(uniformVec2T);
  OpVariable.vec3Uniform() : this._(uniformVec3T);
  OpVariable.vec4Uniform() : this._(uniformVec4T);

  List<int> operands(Identifier i) => [_storageClassUniform];

  List<Instruction> get deps => [type];
}

class OpLoad extends Instruction with Evaluable {
  final OpVariable pointer;

  OpLoad(this.pointer)
      : assert(pointer != null),
        super(
          opCode: 61,
          result: true,
          type: pointer.objectType,
        );

  List<int> operands(Identifier i) => [i.identify(pointer)];
  List<Instruction> get deps => [pointer];

  List<double> evaluate() => pointer.variable.toList();

  List<double> get variable => pointer.variable;
}

// Numerical operation with one arguments.
class OpFNegate extends Instruction with Evaluable {
  final Evaluable a;

  OpFNegate(this.a)
      : assert(a != null),
        super(
          type: a.type,
          result: true,
          opCode: 127,
        );

  List<int> operands(Identifier i) => [i.identify(a)];

  List<Instruction> get deps => [a];

  List<double> evaluate() => a.evaluate().map((x) => -x).toList();
}

// Numerical operation with two arguments.
abstract class _BinOp extends Instruction with Evaluable {
  final Evaluable a;
  final Evaluable b;

  _BinOp(int opCode, this.a, this.b)
      : assert(a.type == b.type),
        super(
          type: a.type,
          result: true,
          opCode: opCode,
        );

  List<int> operands(Identifier i) => deps.map((d) => i.identify(d)).toList();

  List<Instruction> get deps => [a, b];

  List<double> evaluate() {
    final valueA = a.evaluate();
    final valueB = b.evaluate();
    final out = List<double>(valueA.length);
    for (int i = 0; i < out.length; i++) {
      out[i] = _op(valueA[i], valueB[i]);
    }
    return out;
  }

  double _op(double x, double y);
}

class OpFAdd extends _BinOp {
  OpFAdd(Instruction a, Instruction b) : super(129, a, b);

  double _op(double x, double y) => x + y;
}

class OpFSub extends _BinOp {
  OpFSub(Instruction a, Instruction b) : super(131, a, b);

  double _op(double x, double y) => x - y;
}

class OpFMul extends _BinOp {
  OpFMul(Instruction a, Instruction b) : super(133, a, b);

  double _op(double x, double y) => x * y;
}

class OpFDiv extends _BinOp {
  OpFDiv(Instruction a, Instruction b) : super(136, a, b);

  double _op(double x, double y) => x / y;
}

class OpFMod extends _BinOp {
  OpFMod(Instruction a, Instruction b) : super(141, a, b);

  double _op(double x, double y) => x % y;
}

class OpFDot extends Instruction with Evaluable {
  final Evaluable a;
  final Evaluable b;

  OpFDot(this.a, this.b)
      : assert(a.type == b.type),
        super(
          type: floatT,
          result: true,
          opCode: 148,
        );

  List<Instruction> get deps => [a, b];

  List<double> evaluate() => [_dot(a.evaluate(), b.evaluate())];
}

class OpVectorTimesScalar extends Instruction with Evaluable {
  final Evaluable a;
  final Evaluable b;

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

  List<double> evaluate() {
    final bVal = b.evaluate()[0];
    return a.evaluate().map((a) => a * bVal).toList();
  }
}

Type _resolveVecType(int elCount) {
  if (elCount == 1) {
    return floatT;
  } else if (elCount == 2) {
    return vec2T;
  } else if (elCount == 3) {
    return vec3T;
  }
  return vec4T;
}

class OpVectorShuffle extends Instruction with Evaluable {
  final Evaluable source;
  final List<int> indices;
  final List<Instruction> deps;

  OpVectorShuffle({
    this.source,
    this.indices,
  })  : assert(source.type != floatT),
        assert(indices != null),
        assert(indices.length > 0),
        assert(indices.length <= 4),
        deps = [source],
        super(
          opCode: 79,
          result: true,
          type: _resolveVecType(indices.length),
        );

  List<int> operands(Identifier i) => [
        i.identify(source),
        i.identify(source),
        ...indices,
      ];

  List<double> evaluate() {
    final result = source.evaluate();
    final out = List<double>(indices.length);
    for (int i = 0; i < indices.length; i++) {
      out[i] = result[indices[i]];
    }
    return out;
  }
}

class OpCompositeConstruct extends Instruction with Evaluable {
  final List<Evaluable> deps;

  static int _count(List<Instruction> instructions) =>
      instructions.fold(0, (sum, i) => sum + i.type.elementCount);

  OpCompositeConstruct._(Type type, this.deps)
      : assert(deps != null),
        assert(deps.every((child) => child.type != null)),
        assert(deps.every((child) => child.type.elementCount > 0)),
        assert(_count(deps) == type.elementCount),
        super(
          type: type,
          result: true,
          opCode: 80,
        );

  OpCompositeConstruct.vec2(List<Evaluable> children) : this._(vec2T, children);
  OpCompositeConstruct.vec3(List<Evaluable> children) : this._(vec3T, children);
  OpCompositeConstruct.vec4(List<Evaluable> children) : this._(vec4T, children);

  List<int> operands(Identifier i) => deps.map(i.identify).toList();

  List<double> evaluate() => deps.fold([], (out, child) {
        out.addAll(child.evaluate());
        return out;
      });
}

abstract class OpExtInst extends Instruction with Evaluable {
  final int extOp;
  final List<Evaluable> deps;

  OpExtInst(this.extOp, this.deps, [Type type])
      : assert(deps.length > 0),
        assert(!deps.any((dep) => dep.type != deps[0].type)),
        super(
          opCode: 12,
          type: type == null ? deps[0].type : type,
          result: true,
        );

  List<int> operands(Identifier i) => [
        i.identify(OpExtInstImport.glsl),
        extOp,
        ...deps.map((inst) => i.identify(inst)),
      ];
}

double _dot(List<double> a, List<double> b) {
  double sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += a[i] * b[i];
  }
  return sum;
}
