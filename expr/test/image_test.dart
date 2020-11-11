import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:expr/expr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';
import 'package:vector_math/vector_math.dart' as vm;

void main() {
  test('make png', () async {
    final pngBytes = File('logo_flutter_1080px_clr.png').readAsBytesSync();
    final codec = await instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    final sampler = Sampler(frame.image);
    await sampler.ready;
    final shader = Warp(
      image: sampler,
      resolution: Vec2Uniform()
        ..value = vm.Vector2(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        ),
    );
    final img = Image(frame.image.width, frame.image.height);
    for (int i = 0; i < img.width; i++) {
      for (int j = 0; j < img.height; j++) {
        final result = shader.evaluate(vm.Vector2(i.toDouble(), j.toDouble()));
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
    File('image_test.png')..writeAsBytesSync(encodePng(img));
  });
}

class Warp extends Shader {
  final Sampler image;
  final Vec2 resolution;

  Warp({
    this.image,
    this.resolution,
  });

  Vec4 color(Vec2 position) {
    Vec2 uv = position / resolution;
    uv += Vec2.all(0.2) * sin(Vec2(Scalar(10) * uv.y, Scalar(0)));
    final sampled = image.sample(uv);
    return sampled.zxyw;
  }
}
