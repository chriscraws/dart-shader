// This file defines a class to represent a SPIR-V module.

import 'dart:collection';
import 'dart:typed_data';

import 'instruction.dart';
import 'instructions.dart';
import 'package:collection/collection.dart' show IterableExtension;

final _magicNumber = 0x07230203;
final _version = 0x00010000;

/// Module builds a complete unit of SPIR-V from
/// an Instruction representing fragment color for a shader.
///
class Module extends Identifier {
  // fragment position
  final Evaluable color;

  Module({required this.color});

  final _ids = <Instruction, int>{};
  final _constants = <Instruction>{};
  final _uniforms = <OpVariable>[];

  int _bound = 0;

  @override
  int identify(Instruction inst) {
    if (_ids.containsKey(inst)) {
      return _ids[inst]!;
    }

    if (inst.constant != null) {
      final constant = _constants.singleWhereOrNull(
        (c) => c.constant == inst.constant,
      );
      if (constant != null) {
        return _ids[constant]!;
      }
      _constants.add(inst);
    }

    int id = ++_bound;
    _ids[inst] = id;
    return id;
  }

  List<double> packUniformValues() {
    int size = 0;
    for (final uniform in _uniforms) {
      size += uniform.variable.length;
    }
    int i = 0;
    List<double> values = List<double>.filled(size, 0);
    for (final uniform in _uniforms) {
      for (int ui = 0; ui < uniform.variable.length; ui++) {
        values[i] = uniform.variable[ui];
        i++;
      }
    }
    return values;
  }

  // Encode the module to binary SPIR-V.
  ByteBuffer encode() {
    _ids.clear();

    final main = OpFunction(OpTypeFunction(returnType: voidT));
    final entryPoint = OpEntryPoint(
      entryPoint: main,
      name: "main",
      interfaceVars: <OpVariable>[
        OpVariable.fragCoord,
        OpVariable.oColor,
      ],
    );
    final assignColor = OpStore(
      pointer: OpVariable.oColor,
      value: color,
    );

    final instructions = <Instruction>[
      OpCapability.matrix,
      OpCapability.shader,
      OpExtInstImport.glsl,
      OpMemoryModel.glsl,
      entryPoint,
      OpExecutionMode(entryPoint: main),
      OpDecorate(
        target: OpVariable.fragCoord,
        decoration: OpDecorate.builtin,
        extraOperands: <int>[OpDecorate.builtinFragCoord],
      ),
      OpDecorate(
        target: OpVariable.oColor,
        decoration: OpDecorate.location,
        extraOperands: <int>[0],
      ),
    ];

    int nextLocation = 0;

    <Instruction>[main, entryPoint, color]
        .forEach((inst) => inst.resolve(this));

    // insert all instruction/id pairs into a sorted map
    final sortedMap = SplayTreeMap.fromIterables(
      _ids.values, // ids as keys
      _ids.keys, // instructions as values
    );

    // collect uniforms
    _uniforms.addAll(sortedMap.values
        .where((i) => i is OpVariable)
        .map((i) => i as OpVariable));

    // add uniform locations
    instructions
        .addAll(_uniforms.where((u) => u.isUniform).map((u) => OpDecorate(
              target: u,
              decoration: OpDecorate.location,
              extraOperands: <int>[nextLocation++],
            )));

    // add type declarations
    instructions.addAll(sortedMap.values.where((i) => i.isType));

    // add variable declarations
    instructions.addAll(sortedMap.values.where((i) => i.isDeclaration));

    // add function declaration opening
    instructions.addAll([
      main,
      OpLabel(),
    ]);

    // add block
    instructions
        .addAll(sortedMap.values.where((i) => !instructions.contains(i)));

    // complete function declaration
    instructions.addAll([
      assignColor,
      opReturn,
      OpFunctionEnd(),
    ]);

    final words = <int>[
      _magicNumber,
      _version,
      0, // generator's magic number
      0, // bound
      0, // reserved.
    ];

    for (final instruction in instructions) {
      words.addAll(instruction.encode(this));
    }

    words[3] = _bound + 1;

    return Int32List.fromList(words).buffer;
  }
}
