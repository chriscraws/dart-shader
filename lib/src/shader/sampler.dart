part of '../../shader.dart';

abstract class Sampler<T> extends ExternalSampler {
  ShaderFunction<T> _functionNode;

  Sampler(T source) {
    _functionNode = ShaderFunction<T>(this, source);
  }

  Vec4 sample(Vec2 pos) => Vec4._(_functionNode(pos._node));
}
