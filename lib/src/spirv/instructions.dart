// This file contains class representations of SPIR-V instructions
// from https://www.khronos.org/registry/spir-v/specs/unified1/SPIRV.html#_a_id_instructions_a_instructions

import 'dart:convert';
import 'dart:typed_data';

import 'instruction.dart';

final _storageClassUniformConstant = 0;

const floatT = OpTypeFloat._(32);
const vec2T = OpTypeVec._(floatT, 2);
const vec3T = OpTypeVec._(floatT, 3);
const vec4T = OpTypeVec._(floatT, 4);

final uniformFloatT = OpTypePointer._(floatT);
final uniformVec2T = OpTypePointer._(vec2T);
final uniformVec3T = OpTypePointer._(vec3T);
final uniformVec4T = OpTypePointer._(vec4T);

List<int> _toWords(String string) {
  final utfBytes = utf8.encode(string);
  // include null word required by SPIR-V.
  final padding = 4;
  final paddedList = Uint8List(utfBytes.length + padding);
  for (int i = 0; i < utfBytes.length; i++) {
    paddedList[i] = utfBytes[i];
  }
  return paddedList.buffer.asUint32List();
}

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
  static const int linkageImport = 1;

  OpDecorate({
    required this.decoration,
    required this.extraOperands,
    required this.target,
  })  : deps = [target],
        super(
          opCode: 71,
          isDecoration: true,
        );

  OpDecorate.export({
    required Instruction target,
    required String name,
  }) : this(
          target: target,
          decoration: linkageAttributes,
          extraOperands: [
            ..._toWords(name),
            linkageExport,
          ],
        );

  OpDecorate.import({
    required OpFunction function,
    required String name,
  }) : this(
          target: function,
          decoration: linkageAttributes,
          extraOperands: [
            ..._toWords(name),
            linkageImport,
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
      : assert(elementCount > 1),
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
  final List<Instruction> deps;

  OpTypePointer._(this.objectType)
      : deps = [objectType],
        super(
          isType: true,
          result: true,
          opCode: 32,
        );

  List<int> operands(Identifier i) => [
        _storageClassUniformConstant,
        i.identify(objectType),
      ];
}

class OpTypeFunction extends Instruction {
  final Type returnType;
  final List<Type> paramTypes;
  final List<Instruction> deps;

  OpTypeFunction({
    required this.returnType,
    this.paramTypes = const [],
  })  : deps = [returnType, ...paramTypes],
        super(
          opCode: 33,
          result: true,
          isType: true,
        );

  List<int> operands(Identifier i) => [
        i.identify(returnType),
        ...paramTypes.map((t) => i.identify(t)),
      ];
}

class OpFunction extends Instruction {
  final OpTypeFunction fnType;
  final List<Instruction> deps;

  OpFunction._(this.fnType)
      : deps = [fnType],
        super(
          result: true,
          type: fnType.returnType,
          opCode: 54,
          isFunction: true,
        );

  List<int> operands(Identifier i) => [
        0, // no function control
        i.identify(fnType), // function type
      ];
}

abstract class ExternalSampler {
  double evaluate(double x, double y, int channel);
}

class ShaderFunction<T> extends OpFunction {
  static final _type = OpTypeFunction(
    returnType: vec4T,
    paramTypes: [vec2T],
  );

  final T? source;
  final ExternalSampler? sampler;

  ShaderFunction([this.sampler, this.source]) : super._(_type);

  OpFunctionCall call(Evaluable pos) {
    assert(pos.type == vec2T);
    return OpFunctionCall(
      function: this,
      params: [pos],
      evaluator: _evaluate,
    );
  }

  void _evaluate(List<Evaluable> params, List<double> result) {
    if (sampler == null) {
      return;
    }

    assert(params.length == 1);
    assert(result.length == 4);
    final pos = params[0];
    pos.evaluate();
    for (int i = 0; i < 4; i++) {
      result[i] = sampler!.evaluate(pos.value[0], pos.value[1], i);
    }
  }
}

class OpFunctionCall extends Instruction with Evaluable {
  final OpFunction function;
  final List<Evaluable> params;
  final List<Instruction> deps;
  final void Function(List<Evaluable> params, List<double> result) evaluator;

  OpFunctionCall({
    required this.function,
    required this.params,
    required this.evaluator,
  })  : assert(params.length == function.fnType.paramTypes.length),
        deps = [function, ...params],
        super(
          opCode: 57,
          result: true,
          type: function.type,
        ) {
    value.length = type!.elementCount;
    for (int i = 0; i < value.length; i++) {
      value[i] = 0;
    }
  }

  void evaluate() => evaluator(params, value);

  List<int> operands(Identifier i) => [
        i.identify(function),
        ...params.map(i.identify),
      ];
}

class OpFunctionEnd extends Instruction {
  const OpFunctionEnd()
      : super(
          opCode: 56,
        );
}

class OpFunctionParameter extends Instruction with Evaluable {
  OpFunctionParameter(Type type)
      : super(
          type: type,
          opCode: 55,
          result: true,
        ) {
    value.addAll(Iterable.generate(
      type.elementCount,
      (_) => 0,
    ));
  }

  void evaluate() {}
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
  final List<Instruction> deps;

  OpReturnValue(this.value)
      : deps = [value],
        super(
          opCode: 254,
        );

  List<int> operands(Identifier i) => [i.identify(value)];
}

class OpConstant extends Instruction with Evaluable {
  OpConstant(double value)
      : super(
          constant: value,
          isDeclaration: true,
          opCode: 43,
          result: true,
          type: floatT,
        ) {
    this.value.add(constant!);
  }

  List<int> operands(Identifier i) =>
      Float32List.fromList([constant!]).buffer.asInt32List();

  void evaluate() {}
}

class OpConstantComposite extends Instruction with Evaluable {
  final List<OpConstant> constituants;

  late List<Evaluable> _deps;

  OpConstantComposite._(Type type, List<double> constituants)
      : assert(constituants.length > 1),
        constituants = constituants.map((v) => OpConstant(v)).toList(),
        super(
          isDeclaration: true,
          opCode: 44,
          type: type,
          result: true,
        ) {
    value.addAll(Iterable.generate(
      type.elementCount,
      (_) => 0,
    ));
    _deps = List<Evaluable>.from(this.constituants);
  }

  OpConstantComposite.vec2(double x, double y) : this._(vec2T, [x, y]);

  OpConstantComposite.vec3(double x, double y, double z)
      : this._(vec3T, [x, y, z]);

  OpConstantComposite.vec4(double x, double y, double z, double w)
      : this._(vec4T, [x, y, z, w]);

  List<int> operands(Identifier i) =>
      constituants.map((op) => i.identify(op)).toList();

  List<Evaluable> get deps => _deps;

  void evaluate() {
    int i = 0;
    for (int index = 0; index < constituants.length; index++) {
      final c = constituants[index]..evaluate();
      for (int ci = 0; ci < c.value.length; ci++) {
        value[i++] = c.value[ci];
      }
    }
  }
}

class OpVariable extends Instruction {
  final Type objectType;
  final Float32List variable;

  OpVariable._(OpTypePointer type)
      : objectType = type.objectType,
        variable = Float32List(type.objectType.elementCount),
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

  List<int> operands(Identifier i) => [_storageClassUniformConstant];

  void evaluate() {}
}

class OpLoad extends Instruction with Evaluable {
  final OpVariable pointer;
  final List<Instruction> deps;

  OpLoad(this.pointer)
      : deps = [pointer],
        super(
          opCode: 61,
          result: true,
          type: pointer.objectType,
        );

  List<int> operands(Identifier i) => [i.identify(pointer)];

  void evaluate() {}

  List<double> get value => pointer.variable;

  Float32List get variable => pointer.variable;
}

// Numerical operation with one arguments.
class OpFNegate extends Instruction with Evaluable {
  final Evaluable a;
  final List<Evaluable> deps;

  OpFNegate(this.a)
      : deps = [a],
        super(
          type: a.type,
          result: true,
          opCode: 127,
        ) {
    value.addAll(Iterable.generate(
      type!.elementCount,
      (_) => 0,
    ));
  }

  List<int> operands(Identifier i) => [i.identify(a)];

  void evaluate() {
    a.evaluate();
    for (int i = 0; i < value.length; i++) {
      value[i] = -a.value[i];
    }
  }
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
        ) {
    value.addAll(Iterable.generate(
      type!.elementCount,
      (_) => 0,
    ));
  }

  List<int> operands(Identifier i) => deps.map((d) => i.identify(d)).toList();

  List<Evaluable> get deps => [a, b];

  void evaluate() {
    a.evaluate();
    b.evaluate();
    for (int i = 0; i < value.length; i++) {
      value[i] = _op(a.value[i], b.value[i]);
    }
  }

  double _op(double x, double y);
}

class OpFAdd extends _BinOp {
  OpFAdd(Instruction a, Instruction b) : super(129, a as Evaluable, b as Evaluable);

  double _op(double x, double y) => x + y;
}

class OpFSub extends _BinOp {
  OpFSub(Instruction a, Instruction b) : super(131, a as Evaluable, b as Evaluable);

  double _op(double x, double y) => x - y;
}

class OpFMul extends _BinOp {
  OpFMul(Instruction a, Instruction b) : super(133, a as Evaluable, b as Evaluable);

  double _op(double x, double y) => x * y;
}

class OpFDiv extends _BinOp {
  OpFDiv(Instruction a, Instruction b) : super(136, a as Evaluable, b as Evaluable);

  double _op(double x, double y) => x / y;
}

class OpFMod extends _BinOp {
  OpFMod(Instruction a, Instruction b) : super(141, a as Evaluable, b as Evaluable);

  double _op(double x, double y) => x % y;
}

class OpFDot extends Instruction with Evaluable {
  final Evaluable a;
  final Evaluable b;

  final List<Evaluable> deps;

  OpFDot(this.a, this.b)
      : assert(a.type != floatT),
        assert(a.type == b.type),
        deps = [a, b],
        super(
          type: floatT,
          result: true,
          opCode: 148,
        ) {
    value.addAll(Iterable.generate(
      type!.elementCount,
      (_) => 0,
    ));
  }

  List<int> operands(Identifier i) => [
        i.identify(a),
        i.identify(b),
      ];

  void evaluate() {
    a.evaluate();
    b.evaluate();
    value[0] = _dot(a.value, b.value);
  }
}

class OpVectorTimesScalar extends Instruction with Evaluable {
  final Evaluable a;
  final Evaluable b;
  final List<Evaluable> deps;

  OpVectorTimesScalar(this.a, this.b)
      : assert(a.type != floatT),
        assert(b.type == floatT),
        deps = [a, b],
        super(
          type: a.type,
          result: true,
          opCode: 142,
        ) {
    value.addAll(Iterable.generate(
      type!.elementCount,
      (_) => 0,
    ));
  }

  List<int> operands(Identifier i) => deps.map((d) => i.identify(d)).toList();

  void evaluate() {
    a.evaluate();
    b.evaluate();
    final bVal = b.value[0];
    for (int i = 0; i < value.length; i++) {
      value[i] = a.value[i] * bVal;
    }
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

class OpCompositeExtract extends Instruction with Evaluable {
  final Evaluable source;
  final List<Evaluable> deps;
  final List<int> indices;

  OpCompositeExtract.vec(this.source, int index)
      : deps = [source],
        indices = [index],
        super(
          opCode: 81,
          result: true,
          type: floatT,
        ) {
    value.addAll(Iterable.generate(
      type!.elementCount,
      (_) => 0,
    ));
  }

  List<int> operands(Identifier i) => [
        i.identify(source),
        ...indices,
      ];

  void evaluate() {
    assert(indices.length == 1);
    source.evaluate();
    value[0] = source.value[indices[0]];
  }
}

class OpVectorShuffle extends Instruction with Evaluable {
  final Evaluable source;
  final List<int> indices;
  final List<Evaluable> deps;

  OpVectorShuffle(this.source, this.indices)
      : assert(source.type != floatT),
        assert(indices.length > 0),
        assert(indices.length <= 4),
        deps = [source],
        super(
          opCode: 79,
          result: true,
          type: _resolveVecType(indices.length),
        ) {
    value.addAll(Iterable.generate(
      type!.elementCount,
      (_) => 0,
    ));
  }

  List<int> operands(Identifier i) => [
        i.identify(source),
        i.identify(source),
        ...indices,
      ];

  void evaluate() {
    source.evaluate();
    for (int i = 0; i < indices.length; i++) {
      value[i] = source.value[indices[i]];
    }
  }
}

class OpCompositeConstruct extends Instruction with Evaluable {
  final List<Evaluable> deps;

  static int _count(List<Instruction> instructions) =>
      instructions.fold(0, (sum, i) => sum + i.type!.elementCount);

  OpCompositeConstruct._(Type type, this.deps)
      : assert(deps.every((child) => child.type != null)),
        assert(deps.every((child) => child.type!.elementCount > 0)),
        assert(_count(deps) == type.elementCount),
        super(
          type: type,
          result: true,
          opCode: 80,
        ) {
    value.addAll(Iterable.generate(
      type.elementCount,
      (_) => 0,
    ));
  }

  OpCompositeConstruct.vec2(List<Evaluable> children) : this._(vec2T, children);
  OpCompositeConstruct.vec3(List<Evaluable> children) : this._(vec3T, children);
  OpCompositeConstruct.vec4(List<Evaluable> children) : this._(vec4T, children);

  List<int> operands(Identifier i) => deps.map(i.identify).toList();

  void evaluate() {
    int i = 0;
    for (int d = 0; d < deps.length; d++) {
      final dep = deps[d];
      dep.evaluate();
      for (int di = 0; di < dep.value.length; di++) {
        value[i++] = dep.value[di];
      }
    }
  }
}

abstract class OpExtInst extends Instruction with Evaluable {
  final int extOp;
  final List<Evaluable> deps;

  OpExtInst(this.extOp, this.deps, [Type? type])
      : assert(deps.length > 0),
        assert(!deps.any((dep) => dep.type != deps[0].type)),
        super(
          opCode: 12,
          type: type == null ? deps[0].type : type,
          result: true,
        ) {
    value.addAll(Iterable.generate(
      this.type!.elementCount,
      (_) => 0,
    ));
  }

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
