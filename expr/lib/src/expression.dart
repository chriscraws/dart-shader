part of '../expr.dart';

/// Base class for expression nodes.
abstract class Expression {
  final Node _node;
  Expression._(this._node);
}
