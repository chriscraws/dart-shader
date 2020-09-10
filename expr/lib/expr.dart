/// SSIR Expression library.
///
/// Mathematical expressions that can be evaluated by Dart at runtime,
/// and can also be compiled to SPIR-V. Intended for use in Flutter.
///
/// See [Shader] to start.
library expr;

import 'dart:typed_data';
import 'package:vector_math/vector_math.dart' as vm;

import 'src/spirv/module.dart';
import 'src/spirv/node.dart';

part 'src/expression.dart';
part 'src/scalar.dart';
part 'src/shader.dart';
part 'src/vec2.dart';
part 'src/vec3.dart';
part 'src/vec4.dart';
part 'src/uniforms.dart';
