import 'dart:typed_data';

import './constants.dart';

/// Specifies the numerical type of an instance of [Expression].
abstract class Type {
  VectorType get _vectorType;
  int get _vectorDimensions => vectorTypeDimensions[_vectorType];
}

/// Floating point number.
class Scalar extends Type {
  VectorType get _vectorType => VectorType.scalar;
}

/// Two-component vector.
class Vec2 extends Type {
  VectorType get _vectorType => VectorType.vec2;
}

/// Three-component vector.
class Vec3 extends Type {
  VectorType get _vectorType => VectorType.vec3;
}

/// Four-component vector.
class Vec4 extends Type {
  VectorType get _vectorType => VectorType.vec4;
}

/// Two-by-two matrix.
class Mat2 extends Type {
  VectorType get _vectorType => VectorType.mat2;
}

/// Three-by-three matrix.
class Mat3 extends Type {
  VectorType get _vectorType => VectorType.mat3;
}

/// Four-by-four matrix.
class Mat4 extends Type {
  VectorType get _vectorType => VectorType.mat4;
}

/// Node within an SSIR abstract syntax tree.
abstract class Expression<T extends Type> {
  void _writeTo(Shader shader);
}

class _Const<T extends Type> extends Expression<T> {
  _Const(this._value);

  final List<int> _value;

  void _writeTo(Shader shader) {
    shader._context[this] = shader._buffer.length;
    shader._buffer
      ..add(_vectorType)
      ..addAll(_value);
  }
}

/// Namespace for Const expression constructors.
class Const {
  /// Constant scalar expression.
  static Expression<Scalar> scalar(double value) => _Const<Scalar>([value]);

  /// Constant vec2 expression.
  static Expression<Vec2> vec2(double x, double y) => _Const<Vec2>([x, y]);

  /// Constant vec3 expression.
  static Expression<Vec3> vec2(double x, double y, double z) =>
      _Const<Vec3>([x, y, z]);

  /// Constant vec4 expression.
  static Expression<Vec2> vec2(double x, double y, double z, double w) =>
      _Const<Vec4>([x, y, z, w]);
}

// A specification for a shader that can be serialized to SSIR.
class Shader {
  Shader({this.fragmentColor});

  /// The output color for a fragment shader.
  final Expression<Vec4> fragmentColor;

  final _buffer = <int>[];
  final _context = <Expression, int>{};

  void _writeHeader() {
    _buffer
      ..add(0) // version
      ..add(RootType.fragmentShader); // root type
  }

  void _writeFragmentShader() {
    _buffer
      ..add(0) // uniform count
      ..add(0) // sampler uniform count
      ..add(0) // declaration count
      ..add(0) // assignment count
      ..add(_buffer.length); // offset to fragment color expression
    fragmentColor._writeTo(this);
  }

  /// Create a byte buffer containing a valid SSIR representation of the shader.
  UnmodifiableByteBufferView serialize() {
    if (_buffer.length == 0) {
      _writeHeader();
      _writeFragmentShader();
    }
    return UnmodifiableByteBufferView(Uint32List.fromList(buffer).buffer);
  }
}
