// This file contains constants and classes exposing GLSL.std.450 external
// instructions for SPIR-V.
import 'dart:math';
import 'package:vector_math/vector_math.dart' as vm;

import 'instruction.dart';
import 'instructions.dart';

// OpCodes defined at
// https://www.khronos.org/registry/spir-v/specs/1.0/GLSL.std.450.html
final _trunc = 3;
final _fabs = 4;
final _fsign = 6;
final _floor = 8;
final _ceil = 9;
final _fract = 10;
final _radians = 11;
final _degrees = 12;
final _sin = 13;
final _cos = 14;
final _tan = 15;
final _asin = 16;
final _acos = 17;
final _atan = 18;
final _atan2 = 25;
final _pow = 26;
final _exp = 27;
final _log = 28;
final _exp2 = 29;
final _log2 = 30;
final _sqrt = 31;
final _inverseSqrt = 32;
final _fmin = 37;
final _fmax = 40;
final _fclamp = 43;
final _fmix = 46;
final _step = 48;
final _smoothstep = 49;
final _length = 66;
final _distance = 67;
final _cross = 68;
final _normalize = 69;
final _faceforward = 70;
final _reflect = 71;

abstract class _UniOp extends OpExtInst {
  _UniOp(int op, Evaluable x) : super(op, [x]);

  void evaluate() {
    final a = deps[0];
    a.evaluate();
    for (int i = 0; i < value.length; i++) {
      value[i] = _op(a.value[i]);
    }
  }

  double _op(double x);
}

class Trunc extends _UniOp {
  Trunc(Evaluable a) : super(_trunc, a);

  double _op(double x) => x.truncateToDouble();
}

class FAbs extends _UniOp {
  FAbs(Evaluable a) : super(_fabs, a);

  double _op(double x) => x.abs();
}

class FSign extends _UniOp {
  FSign(Evaluable a) : super(_fsign, a);

  double _op(double x) => x.sign;
}

class Floor extends _UniOp {
  Floor(Evaluable a) : super(_floor, a);

  double _op(double x) => x.floorToDouble();
}

class Ceil extends _UniOp {
  Ceil(Evaluable a) : super(_ceil, a);

  double _op(double x) => x.ceilToDouble();
}

class Fract extends _UniOp {
  Fract(Evaluable a) : super(_fract, a);

  double _op(double x) => x - x.floorToDouble();
}

class Radians extends _UniOp {
  Radians(Evaluable a) : super(_radians, a);

  double _op(double x) => vm.radians(x);
}

class Degrees extends _UniOp {
  Degrees(Evaluable a) : super(_degrees, a);

  double _op(double x) => vm.degrees(x);
}

class Sin extends _UniOp {
  Sin(Evaluable a) : super(_sin, a);

  double _op(double x) => sin(x);
}

class Cos extends _UniOp {
  Cos(Evaluable a) : super(_cos, a);

  double _op(double x) => cos(x);
}

class Tan extends _UniOp {
  Tan(Evaluable a) : super(_tan, a);

  double _op(double x) => tan(x);
}

class ASin extends _UniOp {
  ASin(Evaluable a) : super(_asin, a);

  double _op(double x) => asin(x);
}

class ACos extends _UniOp {
  ACos(Evaluable a) : super(_acos, a);

  double _op(double x) => acos(x);
}

class ATan extends _UniOp {
  ATan(Evaluable a) : super(_atan, a);

  double _op(double x) => atan(x);
}

class Exp extends _UniOp {
  Exp(Evaluable a) : super(_exp, a);

  double _op(double x) => exp(x);
}

class Log extends _UniOp {
  Log(Evaluable a) : super(_log, a);

  double _op(double x) => log(x);
}

class Exp2 extends _UniOp {
  Exp2(Evaluable a) : super(_exp2, a);

  double _op(double x) => pow(2, x);
}

class Log2 extends _UniOp {
  Log2(Evaluable a) : super(_log2, a);

  double _op(double x) => log(x) / ln2;
}

class Sqrt extends _UniOp {
  Sqrt(Evaluable a) : super(_sqrt, a);

  double _op(double x) => sqrt(x);
}

class InverseSqrt extends _UniOp {
  InverseSqrt(Evaluable a) : super(_inverseSqrt, a);

  double _op(double x) => 1.0 / sqrt(x);
}

class Length extends OpExtInst {
  Length(Evaluable a) : super(_length, [a], floatT);

  void evaluate() {
    final a = deps[0];
    a.evaluate();
    value[0] = _calculateLength(a.value, a.value.length);
  }
}

class Normalize extends OpExtInst {
  Normalize(Evaluable a) : super(_normalize, [a]);

  void evaluate() {
    final a = deps[0];
    a.evaluate();
    final len = _calculateLength(a.value, a.value.length);
    for (int i = 0; i < value.length; i++) {
      value[i] = a.value[i] / len;
    }
  }
}

abstract class _BinOp extends OpExtInst {
  _BinOp(int op, Evaluable x, Evaluable y) : super(op, [x, y]);

  void evaluate() {
    final a = deps[0]..evaluate();
    final b = deps[1]..evaluate();
    for (int i = 0; i < value.length; i++) {
      value[i] = _op(a.value[i], b.value[i]);
    }
  }

  double _op(double x, double y);
}

class ATan2 extends _BinOp {
  ATan2(Evaluable a, Evaluable b) : super(_atan2, a, b);

  double _op(double x, double y) => atan2(x, y);
}

class Pow extends _BinOp {
  Pow(Evaluable a, Evaluable b) : super(_pow, a, b);

  double _op(double x, double y) => pow(x, y);
}

class FMin extends _BinOp {
  FMin(Evaluable a, Evaluable b) : super(_fmin, a, b);

  double _op(double x, double y) => min(x, y);
}

class FMax extends _BinOp {
  FMax(Evaluable a, Evaluable b) : super(_fmax, a, b);

  double _op(double x, double y) => max(x, y);
}

abstract class _TerOp extends OpExtInst {
  _TerOp(int op, Evaluable x, Evaluable y, Evaluable z) : super(op, [x, y, z]);

  void evaluate() {
    final a = deps[0]..evaluate();
    final b = deps[1]..evaluate();
    final c = deps[2]..evaluate();
    for (int i = 0; i < value.length; i++) {
      value[i] = _op(a.value[i], b.value[i], c.value[i]);
    }
  }

  double _op(double x, double y, double z);
}

class FClamp extends _TerOp {
  FClamp(Evaluable x, Evaluable min, Evaluable max)
      : super(_fclamp, x, min, max);

  double _op(double x, double y, double z) => x.clamp(y, z);
}

class FMix extends _TerOp {
  FMix(Evaluable x, Evaluable y, Evaluable a) : super(_fmix, x, y, a);

  double _op(double x, double y, double z) => vm.mix(x, y, z);
}

class Step extends _BinOp {
  Step(Evaluable edge, Evaluable x) : super(_step, edge, x);

  double _op(double x, double y) => y < x ? 0 : 1;
}

class SmoothStep extends _TerOp {
  SmoothStep(Evaluable edge0, Evaluable edge1, Evaluable x)
      : super(_smoothstep, edge0, edge1, x);

  double _op(double x, double y, double z) => vm.smoothStep(x, y, z);
}

class Distance extends OpExtInst {
  Distance(Evaluable a, Evaluable b) : super(_distance, [a, b], floatT);

  // prevents allocation inside evaluate, should be as large
  // as the largest numerical type.
  static final _diff = List<double>(vec4T.elementCount);

  void evaluate() {
    final a = deps[0]..evaluate();
    final b = deps[1]..evaluate();
    for (int i = 0; i < a.value.length; i++) {
      _diff[i] = b.value[i] - a.value[i];
    }
    value[0] = _calculateLength(_diff, a.value.length);
  }
}

class FaceForward extends OpExtInst {
  FaceForward(Evaluable n, Evaluable i, Evaluable nref)
      : super(_faceforward, [n, i, nref]);

  void evaluate() {
    final n = deps[0]..evaluate();
    final i = deps[1]..evaluate();
    final nref = deps[2]..evaluate();
    if (_dot(i.value, nref.value) < 0) {
      value.setAll(0, n.value);
    } else {
      for (int index = 0; index < value.length; index++) {
        value[index] = -n.value[index];
      }
    }
  }
}

class Reflect extends OpExtInst {
  Reflect(Evaluable i, Evaluable n) : super(_reflect, [i, n]);

  void evaluate() {
    final iRes = deps[0]..evaluate();
    final nRes = deps[1]..evaluate();
    final dot = _dot(nRes.value, iRes.value);
    for (int index = 0; index < value.length; index++) {
      value[index] = iRes.value[index] - 2.0 * dot * nRes.value[index];
    }
  }
}

double _calculateLength(List<double> vector, int count) {
  double sum = 0;
  for (int i = 0; i < count; i++) {
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
