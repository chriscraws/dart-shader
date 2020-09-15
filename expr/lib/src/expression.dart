part of '../expr.dart';

/// Abstract base class for mathematical expressions that can be
/// evaluated at runtime and can be compiled to SPIR-V.
abstract class Expression {
  final Evaluable _node;
  const Expression._(this._node);
}
