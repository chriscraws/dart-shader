/// Dart Shader Expression library.
///
/// Mathematical expressions that can be evaluated by Dart at runtime,
/// and can also be compiled to SPIR-V. Intended for use with Flutter.
///
/// See [Shader] to start.
library shader;

import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' as vm;

import 'src/spirv/module.dart';
import 'src/spirv/instruction.dart';
import 'src/spirv/instructions.dart';
import 'src/spirv/glsl.dart';

part 'src/shader/expression.dart';
part 'src/shader/scalar.dart';
part 'src/shader/shader.dart';
part 'src/shader/vec2.dart';
part 'src/shader/vec3.dart';
part 'src/shader/vec4.dart';
part 'src/shader/uniforms.dart';
