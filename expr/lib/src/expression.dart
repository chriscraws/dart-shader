part of '../expr.dart';

/// Exception that is thrown when a vector or matrix component
/// is devided by zero.
class DivideByZero implements Exception {
  String toString() => 'Tried to divide component by zero.';
}

/// Math expression that can be evaluated or serialized to SPIR-V.
class Expression {
  final spirv.Type _type;
  final spirv.Instruction _instruction;
  final List<double> Function() _evaluate;

  Expression.from(Expression child)
      : assert(child != null),
        _instruction = child._instruction,
        _evaluate = child._evaluate,
        _type = child._type;

  Expression.scalar(double x)
      : assert(x != null),
        _instruction = spirv.OpConstant(x),
        _evaluate = (() => [x]),
        _type = spirv.floatT;

  Expression.vec2(double x, double y)
      : assert(x != null),
        assert(y != null),
        _instruction = spirv.OpConstantComposite.vec2(x, y),
        _evaluate = (() => [x, y]),
        _type = spirv.vec2T;

  Expression.vec3(double x, double y, double z)
      : assert(x != null),
        assert(y != null),
        assert(z != null),
        _instruction = spirv.OpConstantComposite.vec3(x, y, z),
        _evaluate = (() => [x, y, z]),
        _type = spirv.vec3T;

  Expression.vec4(double x, double y, double z, double w)
      : assert(x != null),
        assert(y != null),
        assert(z != null),
        assert(2 != null),
        _instruction = spirv.OpConstantComposite.vec4(x, y, z, w),
        _evaluate = (() => [x, y, z, w]),
        _type = spirv.vec4T;

  Expression.composite(
    List<Expression> children,
    spirv.Type type,
  )   : assert(type != null),
        assert(
          type.elementCount ==
              children.fold(
                0,
                (count, child) => count + child._type.elementCount,
              ),
        ),
        _type = type,
        _instruction = spirv.OpCompositeConstruct(
            children.map((c) => c._instruction).toList()),
        _evaluate = (() => children.fold([], (out, child) {
              out.addAll(child._evaluate());
              return out;
            }));

  Expression._uniOp(
    Expression a,
    spirv.Instruction instruction,
    double Function(double) op,
  )   : assert(a != null),
        assert(instruction != null),
        assert(op != null),
        _type = a._type,
        _instruction = instruction,
        _evaluate = (() => a._evaluate().map(op).toList());

  Expression.negate(Expression a)
      : this._uniOp(a, spirv.OpFNegate(a._instruction), (x) => -x);

  Expression.truncate(Expression a)
      : this._uniOp(
          a,
          spirv.Trunc(a._instruction),
          (x) => x.truncateToDouble(),
        );

  Expression.abs(Expression a)
      : this._uniOp(
          a,
          spirv.FAbs(a._instruction),
          (x) => x.abs(),
        );

  Expression.sign(Expression a)
      : this._uniOp(
          a,
          spirv.FSign(a._instruction),
          (x) => x.sign,
        );

  Expression.floor(Expression a)
      : this._uniOp(
          a,
          spirv.Floor(a._instruction),
          (x) => x.floorToDouble(),
        );

  Expression.ceil(Expression a)
      : this._uniOp(
          a,
          spirv.Ceil(a._instruction),
          (x) => x.ceilToDouble(),
        );

  Expression.fract(Expression a)
      : this._uniOp(
          a,
          spirv.Fract(a._instruction),
          (x) => x - x.floorToDouble(),
        );

  Expression.radians(Expression a)
      : this._uniOp(
          a,
          spirv.Radians(a._instruction),
          vm.radians,
        );

  Expression.degrees(Expression a)
      : this._uniOp(
          a,
          spirv.Degrees(a._instruction),
          vm.degrees,
        );

  Expression.sin(Expression a)
      : this._uniOp(
          a,
          spirv.Sin(a._instruction),
          sin,
        );

  Expression.cos(Expression a)
      : this._uniOp(
          a,
          spirv.Cos(a._instruction),
          cos,
        );

  Expression.tan(Expression a)
      : this._uniOp(
          a,
          spirv.Tan(a._instruction),
          tan,
        );

  Expression.asin(Expression a)
      : this._uniOp(
          a,
          spirv.ASin(a._instruction),
          asin,
        );

  Expression.acos(Expression a)
      : this._uniOp(
          a,
          spirv.ACos(a._instruction),
          acos,
        );

  Expression.atan(Expression a)
      : this._uniOp(
          a,
          spirv.ATan(a._instruction),
          atan,
        );

  Expression.exp(Expression a)
      : this._uniOp(
          a,
          spirv.Exp(a._instruction),
          exp,
        );

  Expression.log(Expression a)
      : this._uniOp(
          a,
          spirv.Log(a._instruction),
          log,
        );

  Expression.exp2(Expression a)
      : this._uniOp(
          a,
          spirv.Exp2(a._instruction),
          (x) => pow(2, x),
        );

  Expression.log2(Expression a)
      : this._uniOp(
          a,
          spirv.Log2(a._instruction),
          (x) => log(x) / ln2,
        );

  Expression.sqrt(Expression a)
      : this._uniOp(
          a,
          spirv.Sqrt(a._instruction),
          sqrt,
        );

  Expression.isqrt(Expression a)
      : this._uniOp(
          a,
          spirv.InverseSqrt(a._instruction),
          (x) => 1.0 / sqrt(x),
        );

  Expression._binOp(
    Expression a,
    Expression b,
    spirv.Instruction instruction,
    double Function(double, double) op,
  )   : assert(a != null),
        assert(b != null),
        assert(a._type == b._type),
        assert(instruction != null),
        assert(op != null),
        _type = a._type,
        _instruction = instruction,
        _evaluate = (() {
          final valueA = a._evaluate();
          final valueB = b._evaluate();
          final out = List<double>(valueA.length);
          for (int i = 0; i < out.length; i++) {
            out[i] = op(valueA[i], valueB[i]);
          }
          return out;
        });

  Expression.add(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.OpFAdd(a._instruction, b._instruction),
          (a, b) => a + b,
        );

  Expression.subtract(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.OpFSub(a._instruction, b._instruction),
          (a, b) => a - b,
        );

  Expression.multiply(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.OpFMul(a._instruction, b._instruction),
          (a, b) => a * b,
        );

  Expression.divide(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.OpFDiv(a._instruction, b._instruction),
          (a, b) {
            if (b == 0) {
              throw DivideByZero();
            }
            return a / b;
          },
        );

  Expression.mod(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.OpFMod(a._instruction, b._instruction),
          (a, b) => a % b,
        );

  Expression.atan2(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.ATan2(a._instruction, b._instruction),
          atan2,
        );

  Expression.pow(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.Pow(a._instruction, b._instruction),
          (a, b) => pow(a, b),
        );

  Expression.min(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.FMin(a._instruction, b._instruction),
          min,
        );

  Expression.max(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.FMax(a._instruction, b._instruction),
          max,
        );

  Expression.step(Expression a, Expression b)
      : this._binOp(
          a,
          b,
          spirv.Step(a._instruction, b._instruction),
          (edge, x) => x < edge ? 0 : 1,
        );

  Expression.length(Expression a)
      : assert(a != null),
        assert(a._type != spirv.floatT),
        _instruction = spirv.Length(a._instruction),
        _type = spirv.floatT,
        _evaluate = (() => [_length(a._evaluate())]);

  Expression.normalize(Expression a)
      : assert(a != null),
        assert(a._type != spirv.floatT),
        _instruction = spirv.Normalize(a._instruction),
        _type = a._type,
        _evaluate = (() {
          final aResult = a._evaluate();
          final len = _length(aResult);
          for (int i = 0; i < aResult.length; i++) {
            aResult[i] /= len;
          }
          return aResult;
        });

  Expression.dot(Expression a, Expression b)
      : assert(a != null),
        assert(b != null),
        assert(a._type != spirv.floatT),
        assert(a._type == b._type),
        _instruction = spirv.OpFDot(a._instruction, b._instruction),
        _type = spirv.floatT,
        _evaluate = (() => [_dot(a._evaluate(), b._evaluate())]);

  Expression.scale(Expression a, Expression b)
      : assert(a != null),
        assert(b != null),
        assert(a._type != spirv.floatT),
        assert(b._type == spirv.floatT),
        _instruction = spirv.OpVectorTimesScalar(
          a._instruction,
          b._instruction,
        ),
        _type = a._type,
        _evaluate = (() {
          double scale = b._evaluate()[0];
          return a._evaluate().map((x) => x * scale).toList();
        });

  Expression._terOp(
    Expression a,
    Expression b,
    Expression c,
    spirv.Instruction instruction,
    double Function(double, double, double) op,
  )   : assert(a != null),
        assert(b != null),
        assert(c != null),
        assert(a._type == b._type),
        assert(b._type == c._type),
        assert(instruction != null),
        assert(op != null),
        _type = a._type,
        _instruction = instruction,
        _evaluate = (() {
          final valueA = a._evaluate();
          final valueB = b._evaluate();
          final valueC = c._evaluate();
          final out = List<double>(valueA.length);
          for (int i = 0; i < out.length; i++) {
            out[i] = op(valueA[i], valueB[i], valueC[i]);
          }
          return out;
        });

  Expression.clamp(Expression x, Expression low, Expression high)
      : this._terOp(
          x,
          low,
          high,
          spirv.FClamp(x._instruction, low._instruction, high._instruction),
          (x, low, high) => min(max(x, low), high),
        );

  Expression.mix(Expression x, Expression y, Expression a)
      : this._terOp(
          x,
          y,
          a,
          spirv.FMix(x._instruction, y._instruction, a._instruction),
          vm.mix,
        );

  Expression.smoothStep(Expression x, Expression y, Expression a)
      : this._terOp(
          x,
          y,
          a,
          spirv.SmoothStep(x._instruction, y._instruction, a._instruction),
          vm.smoothStep,
        );

  Expression.faceForward(Expression n, Expression i, Expression nref)
      : assert(n != null),
        assert(i != null),
        assert(nref != null),
        assert(n._type != null),
        assert(n._type != spirv.floatT),
        assert(n._type == i._type && i._type == nref._type),
        _instruction = spirv.FaceForward(
          n._instruction,
          i._instruction,
          nref._instruction,
        ),
        _type = n._type,
        _evaluate = (() => _dot(i._evaluate(), nref._evaluate()) < 0
            ? n._evaluate()
            : n._evaluate().map((i) => -i).toList());

  Expression.reflect(Expression i, Expression n)
      : assert(i != null),
        assert(n != null),
        assert(i._type != null),
        assert(i._type != spirv.floatT),
        assert(i._type == n._type),
        _instruction = spirv.Reflect(i._instruction, n._instruction),
        _type = i._type,
        _evaluate = (() {
          final iRes = i._evaluate();
          final nRes = n._evaluate();
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
