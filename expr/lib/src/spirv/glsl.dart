// This file contains constants and classes exposing GLSL.std.450 external
// instructions for SPIR-V.
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

class Trunc extends OpExtInst {
  Trunc(Instruction a) : super(_trunc, [a]);
}

class FAbs extends OpExtInst {
  FAbs(Instruction a) : super(_fabs, [a]);
}

class FSign extends OpExtInst {
  FSign(Instruction a) : super(_fsign, [a]);
}

class Floor extends OpExtInst {
  Floor(Instruction a) : super(_floor, [a]);
}

class Ceil extends OpExtInst {
  Ceil(Instruction a) : super(_ceil, [a]);
}

class Fract extends OpExtInst {
  Fract(Instruction a) : super(_fract, [a]);
}

class Radians extends OpExtInst {
  Radians(Instruction a) : super(_radians, [a]);
}

class Degrees extends OpExtInst {
  Degrees(Instruction a) : super(_degrees, [a]);
}

class Sin extends OpExtInst {
  Sin(Instruction a) : super(_sin, [a]);
}

class Cos extends OpExtInst {
  Cos(Instruction a) : super(_cos, [a]);
}

class Tan extends OpExtInst {
  Tan(Instruction a) : super(_tan, [a]);
}

class ASin extends OpExtInst {
  ASin(Instruction a) : super(_asin, [a]);
}

class ACos extends OpExtInst {
  ACos(Instruction a) : super(_acos, [a]);
}

class ATan extends OpExtInst {
  ATan(Instruction a) : super(_atan, [a]);
}

class Exp extends OpExtInst {
  Exp(Instruction a) : super(_exp, [a]);
}

class Log extends OpExtInst {
  Log(Instruction a) : super(_log, [a]);
}

class Exp2 extends OpExtInst {
  Exp2(Instruction a) : super(_exp2, [a]);
}

class Log2 extends OpExtInst {
  Log2(Instruction a) : super(_log2, [a]);
}

class Sqrt extends OpExtInst {
  Sqrt(Instruction a) : super(_sqrt, [a]);
}

class InverseSqrt extends OpExtInst {
  InverseSqrt(Instruction a) : super(_inverseSqrt, [a]);
}

class Length extends OpExtInst {
  Length(Instruction a) : super(_length, [a]);
}

class Normalize extends OpExtInst {
  Normalize(Instruction a) : super(_normalize, [a]);
}

class ATan2 extends OpExtInst {
  ATan2(Instruction a, Instruction b) : super(_atan2, [a, b]);
}

class Pow extends OpExtInst {
  Pow(Instruction a, Instruction b) : super(_pow, [a, b]);
}

class FMin extends OpExtInst {
  FMin(Instruction a, Instruction b) : super(_fmin, [a, b]);
}

class FMax extends OpExtInst {
  FMax(Instruction a, Instruction b) : super(_fmax, [a, b]);
}

class FClamp extends OpExtInst {
  FClamp(Instruction x, Instruction min, Instruction max)
      : super(_fclamp, [x, min, max]);
}

class FMix extends OpExtInst {
  FMix(Instruction x, Instruction y, Instruction a) : super(_fmix, [x, y, a]);
}

class Step extends OpExtInst {
  Step(Instruction edge, Instruction x) : super(_step, [edge, x]);
}

class SmoothStep extends OpExtInst {
  SmoothStep(Instruction edge0, Instruction edge1, Instruction x)
      : super(_smoothstep, [edge0, edge1, x]);
}

class Distance extends OpExtInst {
  Distance(Instruction a, Instruction b) : super(_distance, [a, b]);
}

class Cross extends OpExtInst {
  Cross(Instruction a, Instruction b) : super(_cross, [a, b]);
}

class FaceForward extends OpExtInst {
  FaceForward(Instruction n, Instruction i, Instruction nref)
      : super(_faceforward, [n, i, nref]);
}

class Reflect extends OpExtInst {
  Reflect(Instruction i, Instruction n) : super(_reflect, [i, n]);
}
