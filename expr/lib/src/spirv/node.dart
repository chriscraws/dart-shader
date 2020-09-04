import 'dart:math';
import 'package:vector_math/vector_math.dart' as vm;

import 'instruction.dart';
import 'instructions.dart';
import 'glsl.dart';

/// Exception that is thrown when a vector or matrix component
/// is devided by zero.
class DivideByZero implements Exception {
  String toString() => 'Tried to divide component by zero.';
}

/// Math expression that can be evaluated or serialized to SPIR-V.
class Node {
  final Type type;

  final Instruction instruction;

  final List<double> Function() evaluate;

  Node.from(Node child)
      : assert(child != null),
        instruction = child.instruction,
        evaluate = child.evaluate,
        type = child.type;

  Node.scalar(double x)
      : assert(x != null),
        instruction = OpConstant(x),
        evaluate = (() => [x]),
        type = floatT;

  Node.vec2(double x, double y)
      : assert(x != null),
        assert(y != null),
        instruction = OpConstantComposite.vec2(x, y),
        evaluate = (() => [x, y]),
        type = vec2T;

  Node.vec3(double x, double y, double z)
      : assert(x != null),
        assert(y != null),
        assert(z != null),
        instruction = OpConstantComposite.vec3(x, y, z),
        evaluate = (() => [x, y, z]),
        type = vec3T;

  Node.vec4(double x, double y, double z, double w)
      : assert(x != null),
        assert(y != null),
        assert(z != null),
        assert(2 != null),
        instruction = OpConstantComposite.vec4(x, y, z, w),
        evaluate = (() => [x, y, z, w]),
        type = vec4T;

  Node._composite(
    List<Node> children,
    Type type,
  )   : assert(type != null),
        assert(
          type.elementCount ==
              children.fold(
                0,
                (count, child) => count + child.type.elementCount,
              ),
        ),
        type = type,
        instruction =
            OpCompositeConstruct(children.map((c) => c.instruction).toList()),
        evaluate = (() => children.fold([], (out, child) {
              out.addAll(child.evaluate());
              return out;
            }));

  Node.compositeVec2(List<Node> children) : this._composite(children, vec2T);

  Node.compositeVec3(List<Node> children) : this._composite(children, vec3T);

  Node.compositeVec4(List<Node> children) : this._composite(children, vec4T);

  Node.shuffle(
    Node source,
    List<int> indices,
    Type type,
  )   : assert(source.type != floatT),
        assert(indices.length > 1),
        assert(indices.length == type.elementCount),
        type = type,
        instruction = OpVectorShuffle(
          source: source.instruction,
          indices: indices,
        ),
        evaluate = (() {
          final result = source.evaluate();
          final out = List<double>(indices.length);
          for (int i = 0; i < indices.length; i++) {
            out[i] = result[indices[i]];
          }
          return out;
        });

  Node._uniOp(
    Node a,
    Instruction instruction,
    double Function(double) op,
  )   : assert(a != null),
        assert(instruction != null),
        assert(op != null),
        type = a.type,
        instruction = instruction,
        evaluate = (() => a.evaluate().map(op).toList());

  Node.negate(Node a) : this._uniOp(a, OpFNegate(a.instruction), (x) => -x);

  Node.truncate(Node a)
      : this._uniOp(
          a,
          Trunc(a.instruction),
          (x) => x.truncateToDouble(),
        );

  Node.abs(Node a)
      : this._uniOp(
          a,
          FAbs(a.instruction),
          (x) => x.abs(),
        );

  Node.sign(Node a)
      : this._uniOp(
          a,
          FSign(a.instruction),
          (x) => x.sign,
        );

  Node.floor(Node a)
      : this._uniOp(
          a,
          Floor(a.instruction),
          (x) => x.floorToDouble(),
        );

  Node.ceil(Node a)
      : this._uniOp(
          a,
          Ceil(a.instruction),
          (x) => x.ceilToDouble(),
        );

  Node.fract(Node a)
      : this._uniOp(
          a,
          Fract(a.instruction),
          (x) => x - x.floorToDouble(),
        );

  Node.radians(Node a)
      : this._uniOp(
          a,
          Radians(a.instruction),
          vm.radians,
        );

  Node.degrees(Node a)
      : this._uniOp(
          a,
          Degrees(a.instruction),
          vm.degrees,
        );

  Node.sin(Node a)
      : this._uniOp(
          a,
          Sin(a.instruction),
          sin,
        );

  Node.cos(Node a)
      : this._uniOp(
          a,
          Cos(a.instruction),
          cos,
        );

  Node.tan(Node a)
      : this._uniOp(
          a,
          Tan(a.instruction),
          tan,
        );

  Node.asin(Node a)
      : this._uniOp(
          a,
          ASin(a.instruction),
          asin,
        );

  Node.acos(Node a)
      : this._uniOp(
          a,
          ACos(a.instruction),
          acos,
        );

  Node.atan(Node a)
      : this._uniOp(
          a,
          ATan(a.instruction),
          atan,
        );

  Node.exp(Node a)
      : this._uniOp(
          a,
          Exp(a.instruction),
          exp,
        );

  Node.log(Node a)
      : this._uniOp(
          a,
          Log(a.instruction),
          log,
        );

  Node.exp2(Node a)
      : this._uniOp(
          a,
          Exp2(a.instruction),
          (x) => pow(2, x),
        );

  Node.log2(Node a)
      : this._uniOp(
          a,
          Log2(a.instruction),
          (x) => log(x) / ln2,
        );

  Node.sqrt(Node a)
      : this._uniOp(
          a,
          Sqrt(a.instruction),
          sqrt,
        );

  Node.isqrt(Node a)
      : this._uniOp(
          a,
          InverseSqrt(a.instruction),
          (x) => 1.0 / sqrt(x),
        );

  Node._binOp(
    Node a,
    Node b,
    Instruction instruction,
    double Function(double, double) op,
  )   : assert(a != null),
        assert(b != null),
        assert(a.type == b.type),
        assert(instruction != null),
        assert(op != null),
        type = a.type,
        instruction = instruction,
        evaluate = (() {
          final valueA = a.evaluate();
          final valueB = b.evaluate();
          final out = List<double>(valueA.length);
          for (int i = 0; i < out.length; i++) {
            out[i] = op(valueA[i], valueB[i]);
          }
          return out;
        });

  Node.add(Node a, Node b)
      : this._binOp(
          a,
          b,
          OpFAdd(a.instruction, b.instruction),
          (a, b) => a + b,
        );

  Node.subtract(Node a, Node b)
      : this._binOp(
          a,
          b,
          OpFSub(a.instruction, b.instruction),
          (a, b) => a - b,
        );

  Node.multiply(Node a, Node b)
      : this._binOp(
          a,
          b,
          OpFMul(a.instruction, b.instruction),
          (a, b) => a * b,
        );

  Node.divide(Node a, Node b)
      : this._binOp(
          a,
          b,
          OpFDiv(a.instruction, b.instruction),
          (a, b) {
            if (b == 0) {
              throw DivideByZero();
            }
            return a / b;
          },
        );

  Node.mod(Node a, Node b)
      : this._binOp(
          a,
          b,
          OpFMod(a.instruction, b.instruction),
          (a, b) => a % b,
        );

  Node.atan2(Node a, Node b)
      : this._binOp(
          a,
          b,
          ATan2(a.instruction, b.instruction),
          atan2,
        );

  Node.pow(Node a, Node b)
      : this._binOp(
          a,
          b,
          Pow(a.instruction, b.instruction),
          (a, b) => pow(a, b),
        );

  Node.min(Node a, Node b)
      : this._binOp(
          a,
          b,
          FMin(a.instruction, b.instruction),
          min,
        );

  Node.max(Node a, Node b)
      : this._binOp(
          a,
          b,
          FMax(a.instruction, b.instruction),
          max,
        );

  Node.step(Node a, Node b)
      : this._binOp(
          a,
          b,
          Step(a.instruction, b.instruction),
          (edge, x) => x < edge ? 0 : 1,
        );

  Node.length(Node a)
      : assert(a != null),
        assert(a.type != floatT),
        instruction = Length(a.instruction),
        type = floatT,
        evaluate = (() => [_length(a.evaluate())]);

  Node.normalize(Node a)
      : assert(a != null),
        assert(a.type != floatT),
        instruction = Normalize(a.instruction),
        type = a.type,
        evaluate = (() {
          final aResult = a.evaluate();
          final len = _length(aResult);
          for (int i = 0; i < aResult.length; i++) {
            aResult[i] /= len;
          }
          return aResult;
        });

  Node.dot(Node a, Node b)
      : assert(a != null),
        assert(b != null),
        assert(a.type != floatT),
        assert(a.type == b.type),
        instruction = OpFDot(a.instruction, b.instruction),
        type = floatT,
        evaluate = (() => [_dot(a.evaluate(), b.evaluate())]);

  Node.scale(Node a, Node b)
      : assert(a != null),
        assert(b != null),
        assert(a.type != floatT),
        assert(b.type == floatT),
        instruction = OpVectorTimesScalar(
          a.instruction,
          b.instruction,
        ),
        type = a.type,
        evaluate = (() {
          double scale = b.evaluate()[0];
          return a.evaluate().map((x) => x * scale).toList();
        });

  Node._terOp(
    Node a,
    Node b,
    Node c,
    Instruction instruction,
    double Function(double, double, double) op,
  )   : assert(a != null),
        assert(b != null),
        assert(c != null),
        assert(a.type == b.type),
        assert(b.type == c.type),
        assert(instruction != null),
        assert(op != null),
        type = a.type,
        instruction = instruction,
        evaluate = (() {
          final valueA = a.evaluate();
          final valueB = b.evaluate();
          final valueC = c.evaluate();
          final out = List<double>(valueA.length);
          for (int i = 0; i < out.length; i++) {
            out[i] = op(valueA[i], valueB[i], valueC[i]);
          }
          return out;
        });

  Node.clamp(Node x, Node low, Node high)
      : this._terOp(
          x,
          low,
          high,
          FClamp(x.instruction, low.instruction, high.instruction),
          (x, low, high) => min(max(x, low), high),
        );

  Node.mix(Node x, Node y, Node a)
      : this._terOp(
          x,
          y,
          a,
          FMix(x.instruction, y.instruction, a.instruction),
          vm.mix,
        );

  Node.smoothStep(Node x, Node y, Node a)
      : this._terOp(
          x,
          y,
          a,
          SmoothStep(x.instruction, y.instruction, a.instruction),
          vm.smoothStep,
        );

  Node.faceForward(Node n, Node i, Node nref)
      : assert(n != null),
        assert(i != null),
        assert(nref != null),
        assert(n.type != null),
        assert(n.type != floatT),
        assert(n.type == i.type && i.type == nref.type),
        instruction = FaceForward(
          n.instruction,
          i.instruction,
          nref.instruction,
        ),
        type = n.type,
        evaluate = (() => _dot(i.evaluate(), nref.evaluate()) < 0
            ? n.evaluate()
            : n.evaluate().map((i) => -i).toList());

  Node.reflect(Node i, Node n)
      : assert(i != null),
        assert(n != null),
        assert(i.type != null),
        assert(i.type != floatT),
        assert(i.type == n.type),
        instruction = Reflect(i.instruction, n.instruction),
        type = i.type,
        evaluate = (() {
          final iRes = i.evaluate();
          final nRes = n.evaluate();
          final dot = _dot(nRes, iRes);
          final out = List<double>(iRes.length);
          for (int index = 0; index < out.length; index++) {
            out[index] = iRes[index] - 2.0 * dot * nRes[index];
          }
          return out;
        });
}

double _length(List<double> vector) {
  double sum = 0;
  for (int i = 0; i < vector.length; i++) {
    final el = vector[i];
    sum += el * el;
  }
  return sqrt(sum);
}

double _dot(List<double> a, List<double> b) {
  double sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += a[i] * b[i];
  }
  return sum;
}
