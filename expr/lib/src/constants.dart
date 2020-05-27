// This file contains constants used within SSIR. This file is maintained against
// the specification at flutter.dev/go/shaders

/// The kind of shader encoded.
enum RootType { fragmentShader }

/// Allowable types used as nodes in an abstract-syntax-tree
/// representation of an SSIR shader.
enum ExpressionType {
  constant,
  vector,
  uniform,
  builtInVariable,
  functionCall,
  builtInFunctionCall,
  variableAccessor,
  textureSample
}

/// Numerical types availble for use in expressions.
enum VectorType { scalar, vec2, vec3, vec4, mat2, mat3, mat4 }

/// Function types provided by the target shading language.
enum BuiltInFunction {
  add,
  subtract,
  multiply,
  divide,
  radians,
  degrees,
  sine,
  cosine,
  tangent,
  arcsine,
  arccosine,
  arctangent,
  power,
  exponentiateBaseE,
  logarithmBaseE,
  exponentiateBaseTwo,
  logarithmBaseTwo,
  squareRoot,
  inverseSquareRoot,
  absoluteValue,
  sign,
  floor,
  ceiling,
  fractionalPart,
  modulo,
  minimum,
  maximum,
  clamp,
  mix,
  smoothstep,
  length,
  distance,
  dotProduct,
  crossProduct,
  normalize,
  faceForward
}

/// Variables that can be set or read in the target shading language.
enum BuiltInVariable { fragmentCoordinate, fragmentColor }

/// Bit-precision for floating-point numbers.
enum Precision { defaultP, low, medium, high }
