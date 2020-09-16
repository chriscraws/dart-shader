part of '../../expr.dart';

/// Abstract base class for mathematical expressions that can be
/// evaluated at runtime and can be compiled to SPIR-V.
abstract class Expression {
  final Evaluable _node;

  const Expression._(this._node);

  Expression _construct(Evaluable node);
}

// experimenting with alternate api for functions that don't
// feel like methods

T sin<T extends Expression>(T val) {
  return val._construct(Sin(val._node));
}

T cos<T extends Expression>(T val) {
  return val._construct(Cos(val._node));
}

T tan<T extends Expression>(T val) {
  return val._construct(Tan(val._node));
}

T asin<T extends Expression>(T val) {
  return val._construct(ASin(val._node));
}

T acos<T extends Expression>(T val) {
  return val._construct(ACos(val._node));
}

T atan<T extends Expression>(T val) {
  return val._construct(ATan(val._node));
}
