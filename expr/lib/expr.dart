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
import 'src/spirv/instruction.dart';
import 'src/spirv/instructions.dart';
import 'src/spirv/glsl.dart';

part 'src/expr/expression.dart';
part 'src/expr/scalar.dart';
part 'src/expr/shader.dart';
part 'src/expr/vec2.dart';
part 'src/expr/vec3.dart';
part 'src/expr/vec4.dart';
part 'src/expr/uniforms.dart';
