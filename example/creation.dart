// Example use of CPU evaluation of shaders, and SPIR-V generation.
// Shader is 'Creation by Silexars' - credits to Danilo Guanabara.
//
// run using `dart creation.dart`
// the program will output two files, 'creation.gif' and 'creation.spv'
//
// Warning! it takes some time to run :) CPU evaluation is still slow.

import 'dart:io';

import 'package:shader/shader.dart';
import 'package:image/image.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  final shader = Creation();
  final animate = Animation();
  for (double t = 0; t < 2; t += 1.0 / 15) {
    final img = shader.draw(t);
    animate.addFrame(img);
  }
  File('creation.gif')..writeAsBytesSync(encodeGifAnimation(animate));
  File('creation.spv')..writeAsBytesSync(shader.toSPIRV().asUint8List());
}

class Creation extends Shader {
  final _time = ScalarUniform();
  final _resolution = Vec2Uniform();

  Creation({int width = 500}) {
    _resolution.value.x = width.toDouble();
    _resolution.value.y = width.toDouble();
  }

  @override
  Vec4 color(Vec2 position) {
    // Ported from 'Creation by Silexars' - credits to Danilo Guanabara.
    // https://www.shadertoy.com/view/XsXXDn
    final uv = position / _resolution;
    final rgb = List<Scalar>.filled(3, 0.s);
    for (int i = 0; i < 3; i++) {
      final p = (uv - Vec2.all(0.5));
      final z = _time + Scalar(0.7 * i);
      final l = p.length() + Scalar(0.0001);
      final uvi = uv +
          (p /
              l *
              (sin(z) + Scalar(1) * sin(l * Scalar(9) - z * Scalar(2)).abs()));
      rgb[i] = (Scalar(0.01) /
              (Scalar(0.001) + (uvi.fract() - Vec2.all(0.5)).abs().length())) /
          l;
    }
    return Vec4.of([
      ...rgb,
      Scalar(1.0),
    ]);
  }

  Image draw(double time) {
    _time.value = time;
    final img = Image(_resolution.value.x.toInt(), _resolution.value.y.toInt());
    for (int i = 0; i < _resolution.value.x; i++) {
      for (int j = 0; j < _resolution.value.y; j++) {
        final result = evaluate(vm.Vector2(i.toDouble(), j.toDouble()));
        img.setPixelRgba(
          i,
          j,
          (result.r * 0xff).toInt(),
          (result.g * 0xff).toInt(),
          (result.b * 0xff).toInt(),
          (result.a * 0xff).toInt(),
        );
      }
    }
    return img;
  }
}
