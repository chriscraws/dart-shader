@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:expr/expr.dart';
import 'package:expr/image_sampler.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// If true, overwrites all the golen files. If you run the tests with this
/// set to true, be sure to use `spirv-val` to validate all files matching
/// `test/*.golden`. Then set this back to false.
final overwriteGoldens = true;

Future<void> matchGolden(ByteBuffer item, String filename) async {
  assert(filename != null);
  final file = File('goldens/' + filename);
  if (overwriteGoldens) {
    await file.writeAsBytes(item.asUint8List(), flush: true);
  }
  print("testing '$filename'");
  expect(item.asUint8List(), equals(await file.readAsBytes()));
}

class ColorShader extends Shader {
  final Vec4 out;

  ColorShader(this.out);

  Vec4 color(Vec2 position) => out;
}

class TestShader extends Shader<ui.Shader> {
  TestShader(ui.Image img) : image = ImageSampler(img);
  final time = ScalarUniform();
  final resolution = Vec2Uniform();
  final background = Vec3Uniform();
  final foreground = Vec4Uniform();
  final ImageSampler image;

  Vec4 color(Vec2 position) {
    final uv = (position / resolution - Vec2.all(0.5)) * Scalar(2);

    final ax = sin(5.s * uv.x + time);
    final ay = sin(uv.y + .2.s * time);

    final mixAmt = Vec4(ax, ay, ax, ay);

    final c = mixAmt
        .mix(
          Vec4.of([background, Scalar(1)]),
          foreground * image.sample(uv),
        )
        .abs();

    return c;
  }
}

class UniformShader extends Shader {
  final scalar = ScalarUniform();
  final vec2 = Vec2Uniform();
  final vec3 = Vec3Uniform();
  final vec4 = Vec4Uniform();

  Vec4 color(Vec2 position) =>
      vec4 +
      Vec4.of([
        scalar,
        vec2,
        vec3.x + vec3.y + vec3.z,
      ]);
}

void main() {
  test('simple shader', () async {
    final shader = ColorShader(Vec4.constant(0, 0.25, 0.75, 1.0));
    await matchGolden(shader.toSPIRV(), 'simple.golden');
  });

  test('test shader', () async {
    final pngBytes = File('logo_flutter_1080px_clr.png').readAsBytesSync();
    final codec = await ui.instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    final shader = TestShader(frame.image);
    await matchGolden(shader.toSPIRV(), 'test_shader.golden');
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
    final a = Vec2.constant(1.0, 0.25);
    final b = Vec2.constant(1, 1);
    final c = Vec2Uniform()..value = vm.Vector2(6, 7);

    Vec2 vec2 = (b * Scalar(2) + (a * -b) / a) % Vec2.constant(1.5, 1.5);
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
    final a = Vec3.constant(1.0, 0.25, 0.75);
    final b = Vec3.constant(1, 1, 1);
    final c = Vec3Uniform()..value = vm.Vector3(6, 7, 8);

    final vec3 = ((b * Scalar(2) + (a * -b) / a) % 1.5.v3) * c;

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
    final a = Vec4.constant(1.0, 0.25, 0.75, 1.0);
    final b = Vec4.constant(1, 1, 1, 1);
    final c = Vec4Uniform()..value = vm.Vector4(2, 3, 4, 5);

    final color = ((b * 2.s + (a * -b) / a) % 1.5.v4) * c;

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
    final a = 1.v3;
    final b = 0.5.v3;
    final c = 2.v3;

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

  test('distanceTo vec2', () {
    final result = Vec2.all(0).distanceTo(Vec2.all(5)).evaluate();
    final expected = vm.Vector2.all(0).distanceTo(vm.Vector2.all(5));
    expect(result, equals(expected));
  });

  test('distanceTo vec3', () {
    final result = Vec3.all(0).distanceTo(Vec3.all(5)).evaluate();
    final expected = vm.Vector3.all(0).distanceTo(vm.Vector3.all(5));
    expect(result, equals(expected));
  });

  test('distanceTo vec4', () {
    final result = Vec4.all(0).distanceTo(Vec4.all(5)).evaluate();
    final expected = vm.Vector4.all(0).distanceTo(vm.Vector4.all(5));
    expect(result, equals(expected));
  });

  test('writes uniform data', () {
    final shader = UniformShader();
    final expectedSize = 1 + 2 + 3 + 4; // scalar, vec2, vec3, vec4
    Float32List output = Float32List(expectedSize);
    shader.writeUniformData((i, v) => output[i] = v);

    // expect all zeroes
    for (final v in output) {
      expect(v, equals(0));
    }

    // update values
    shader.scalar.value = 10.0;
    shader.vec2.value = vm.Vector2(8, 9);
    shader.vec3.value = vm.Vector3(5, 6, 7);
    shader.vec4.value = vm.Vector4(1, 2, 3, 4);

    // re-write values to buffer
    shader.writeUniformData((i, v) => output[i] = v);

    // expect correct values - this ordering may be brittle with library changes.
    final expected = [1, 2, 3, 4, 10, 8, 9, 5, 6, 7];
    expect(output, orderedEquals(expected));
  });
}
