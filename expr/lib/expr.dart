library expr;

import './src/constants.dart';

/// Specifies the numerical type of an instance of [Expression].
abstract class Type {

  VectorType get _vectorType;

  int get _vectorDimensions => vectorTypeDimensions[_vectorType];

}

/// Node within an SSIR abstract syntax tree.
abstract class Expression<T extends Type> {}
