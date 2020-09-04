@TestOn('vm')
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:expr/expr.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// If true, overwrites all the golen files. If you run the tests with this
/// set to true, be sure to use `spirv-val` to validate all files matching
/// `test/*.golden`. Then set this back to false.
final overwriteGoldens = false;

Future<void> matchGolden(ByteBuffer item, String filename) async {
  assert(filename != null);
  final file = File('goldens/' + filename);
  if (overwriteGoldens) {
    print(Directory.current);
    await file.writeAsBytes(item.asUint8List(), flush: true);
  }
  expect(item.asUint8List(), equals(await file.readAsBytes()));
}

void main() {
  test('simple shader', () async {
    final shader = Shader(
      color: Vec4(0, 0.25, 0.75, 1.0),
    );
    await matchGolden(shader.toSPIRV(), 'simple.golden');
  });

  test('scalar ops', () async {
    final a = Scalar(0.5);
    final b = Scalar(1);

    final scalar = (b * Scalar(2) + (a * -b) / a) % Scalar(1.5);

    final color = Vec4.of([scalar, scalar, scalar, scalar]);

    final shader = Shader(color: color);
    await matchGolden(shader.toSPIRV(), 'scalar.golden');

    final result = scalar.evaluate();
    expect(result, equals(1));
  });

  test('vec2 ops', () async {
    final a = Vec2(1.0, 0.25);
    final b = Vec2(1, 1);

    final vec2 = (b.scale(Scalar(2)) + (a * -b) / a) % Vec2(1.5, 1.5);

    final color = Vec4.of([vec2, vec2]);

    final shader = Shader(color: color);
    await matchGolden(shader.toSPIRV(), 'vec2op.golden');

    final result = vec2.evaluate();
    expect(result, equals(vm.Vector2.all(1)));
    expect(vec2.dot(b).evaluate(), equals(2));
  });

  test('vec3 ops', () async {
    final a = Vec3(1.0, 0.25, 0.75);
    final b = Vec3(1, 1, 1);

    final vec3 = (b.scale(Scalar(2)) + (a * -b) / a) % Vec3(1.5, 1.5, 1.5);

    final color = Vec4.of([vec3, Scalar(1.0)]);

    final shader = Shader(color: color);
    await matchGolden(shader.toSPIRV(), 'vec3op.golden');

    final result = vec3.evaluate();
    expect(result, equals(vm.Vector3.all(1)));
    expect(vec3.dot(b).evaluate(), equals(3));
  });

  test('vec4 ops', () async {
    final a = Vec4(1.0, 0.25, 0.75, 1.0);
    final b = Vec4(1, 1, 1, 1);

    final color =
        (b.scale(Scalar(2)) + (a * -b) / a) % Vec4(1.5, 1.5, 1.5, 1.5);

    final shader = Shader(color: color);
    await matchGolden(shader.toSPIRV(), 'vec4op.golden');

    final result = color.evaluate();
    expect(result, equals(vm.Vector4.all(1)));
    expect(color.dot(b).evaluate(), equals(4));
  });
}
