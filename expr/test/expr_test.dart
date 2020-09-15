@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:expr/src/spirv/instructions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expr/expr.dart';
import 'package:image/image.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// If true, overwrites all the golen files. If you run the tests with this
/// set to true, be sure to use `spirv-val` to validate all files matching
/// `test/*.golden`. Then set this back to false.
final overwriteGoldens = false;

Future<void> matchGolden(ByteBuffer item, String filename) async {
  assert(filename != null);
  final file = File('goldens/' + filename);
  if (overwriteGoldens) {
    await file.writeAsBytes(item.asUint8List(), flush: true);
  }
  expect(item.asUint8List(), equals(await file.readAsBytes()));
}

class ColorShader extends Shader {
  final Vec4 out;

  ColorShader(this.out);

  Vec4 color(Vec2 position) => out;
}

class TestShader extends Shader {
  final time = ScalarUniform();
  final resolution = Vec2Uniform();
  final background = Vec3Uniform();
  final foreground = Vec4Uniform();

  Vec4 color(Vec2 position) {
    final uv = position / resolution;

    final ax = sin(Scalar(5.0) * uv.x + time);
    final ay = sin(uv.y + Scalar(0.2) * time);

    final mixAmt = Vec4.of([ax, ay, ax, ay]);

    final c = mixAmt
        .mix(
          Vec4.of([background, Scalar(1)]),
          foreground,
        )
        .abs();

    return c;
  }
}

void main() {
  test('simple shader', () async {
    final shader = ColorShader(Vec4(0, 0.25, 0.75, 1.0));
    await matchGolden(shader.toSPIRV(), 'simple.golden');
  });

  test('test shader', () async {
    final shader = TestShader();
    await matchGolden(shader.toSPIRV(), 'test_shader.golden');

    // final width = 100;
    // final height = 100;

    // shader.time.value = 10;
    // shader.background.value = vm.Vector3(0, 1, 0);
    // shader.foreground.value = vm.Vector4(1, 0, 0, 1);
    // shader.resolution.value = vm.Vector2(width.toDouble(), height.toDouble());

    // final animate = Animation();

    // for (double t = 0; t < 20; t+= 0.5) {
    //   final img = Image(width, height);
    //   shader.time.value = t;
    //   for (int i = 0; i < width; i++) {
    //     for (int j = 0; j < height; j++) {
    //       final result = shader.evaluate(vm.Vector2(i.toDouble(), j.toDouble()));
    //       img.setPixelRgba(
    //         i, j,
    //         (result.r * 0xff).toInt(),
    //         (result.g * 0xff).toInt(),
    //         (result.b * 0xff).toInt(),
    //         (result.a * 0xff).toInt(),
    //       );
    //     }
    //   }
    //   animate.addFrame(img);
    // }
    // File('output.gif')..writeAsBytesSync(encodeGifAnimation(animate,
    //   samplingFactor: 60,
    // ));
  });

  test('scalar ops', () async {
    final a = Scalar(0.5);
    final b = Scalar(1);
    final c = ScalarUniform()..value = 7;

    final scalar = (b * Scalar(2) + (a * -b) / a) % Scalar(1.5);

    final color = Vec4.of([scalar, scalar, scalar, scalar]) * c;

    final shader = ColorShader(color);
    await matchGolden(shader.toSPIRV(), 'scalar.golden');

    final result = (scalar * c).evaluate();
    expect(result, equals(7));
  });

  test('vec2 ops', () async {
    final a = Vec2(1.0, 0.25);
    final b = Vec2(1, 1);
    final c = Vec2Uniform()..value = vm.Vector2(6, 7);

    Vec2 vec2 = (b * Scalar(2) + (a * -b) / a) % Vec2(1.5, 1.5);
    vec2 *= c;

    final color = Vec4.of([vec2, vec2]);

    final shader = ColorShader(color);
    await matchGolden(shader.toSPIRV(), 'vec2op.golden');

    final result = vec2.evaluate();
    expect(result, equals(vm.Vector2(6, 7)));
    expect(vec2.x.evaluate(), equals(6));
    expect(vec2.y.evaluate(), equals(7));
    expect(vec2.dot(b).evaluate(), equals(13));
  });

  test('vec3 ops', () async {
    final a = Vec3(1.0, 0.25, 0.75);
    final b = Vec3(1, 1, 1);
    final c = Vec3Uniform()..value = vm.Vector3(6, 7, 8);

    final vec3 = ((b * Scalar(2) + (a * -b) / a) % Vec3(1.5, 1.5, 1.5)) * c;

    final color = Vec4.of([vec3, Scalar(1.0)]);

    final shader = ColorShader(color);
    await matchGolden(shader.toSPIRV(), 'vec3op.golden');

    final result = vec3.evaluate();
    expect(result, equals(vm.Vector3(6, 7, 8)));
    expect(vec3.x.evaluate(), equals(6));
    expect(vec3.y.evaluate(), equals(7));
    expect(vec3.z.evaluate(), equals(8));
    expect(vec3.dot(b).evaluate(), equals(21));
  });

  test('vec4 ops', () async {
    final a = Vec4(1.0, 0.25, 0.75, 1.0);
    final b = Vec4(1, 1, 1, 1);
    final c = Vec4Uniform()..value = vm.Vector4(2, 3, 4, 5);

    final color =
        ((b * Scalar(2) + (a * -b) / a) % Vec4(1.5, 1.5, 1.5, 1.5)) * c;

    final shader = ColorShader(color);
    await matchGolden(shader.toSPIRV(), 'vec4op.golden');

    final result = color.evaluate();
    expect(result, equals(vm.Vector4(2, 3, 4, 5)));
    expect(color.x.evaluate(), equals(2));
    expect(color.y.evaluate(), equals(3));
    expect(color.z.evaluate(), equals(4));
    expect(color.w.evaluate(), equals(5));
    expect(color.dot(b).evaluate(), equals(14));
  });

  test('glsl ops', () async {
    final a = Vec3(1.0, 1.0, 1.0);
    final b = Vec3(0.5, 0.5, 0.5);
    final c = Vec3(2.0, 2.0, 2.0);

    final out = a
        .abs()
        .acos()
        .asin()
        .atan()
        .ceil()
        .clamp(b, c)
        .cos()
        .degrees()
        .exp()
        .exp2()
        .faceForward(b, c)
        .floor()
        .fract()
        .isqrt()
        .log()
        .log2()
        .mix(b, c)
        .radians()
        .reflect(b)
        .sign()
        .sin()
        .smoothStep(b, c)
        .sqrt()
        .step(b)
        .tan()
        .truncate();

    final shader = ColorShader(Vec4.of([out, Scalar(1)]));
    await matchGolden(shader.toSPIRV(), 'glslop.golden');
  });
}
