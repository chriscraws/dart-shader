// This file defines a class to represent a SPIR-V module.

import 'dart:collection';
import 'dart:typed_data';

import 'instruction.dart';
import 'instructions.dart';

final _magicNumber = 0x07230203;
final _version = 0x00010500;

/// Module builds a complete unit of SPIR-V from
/// an Instruction representing fragment color for a shader.
class Module extends Identifier {
  final _ids = <Instruction, int>{};

  int _bound = 0;
  List<Instruction> _main;

  @override
  int identify(Instruction inst) {
    if (_ids.containsKey(inst)) {
      return _ids[inst];
    }

    int id = ++_bound;
    _ids[inst] = id;
    return id;
  }

  // main must be assiged before calling [encode].
  set main(Instruction fragColor) {
    assert(fragColor.type == vec4T);
    final pos = OpFunctionParameter(vec2T);
    final fnType = OpTypeFunction(
      returnType: vec4T,
      paramTypes: [vec2T],
    );
    final fun = OpFunction(fnType);
    _main = [
      fun,
      pos,
      OpLabel(),
      OpReturnValue(fragColor),
      OpFunctionEnd(),
    ];
  }

  // Encode the module to binary SPIR-V.
  ByteBuffer encode() {
    _ids.clear();

    final instructions = <Instruction>[
      // capabilities
      OpCapability.matrix,
      OpCapability.shader,
      OpCapability.linkage,

      // extension instruction imports
      OpExtInstImport.glsl,

      // memory model
      OpMemoryModel.glsl,

      // type delcarations
      floatT,
      vec2T,
      vec3T,
      vec4T,
    ];

    // get main definition, and identify all dependent instructions.
    for (final inst in _main) {
      inst.resolve(this);
    }

    // insert all instruction/id pairs into a sorted map
    final sortedMap = SplayTreeMap.fromIterables(
      _ids.values, // ids as keys
      _ids.keys, // instructions as values
    );

    // add all instructions required by main, in order
    instructions.addAll(sortedMap.values
        .where((i) => !instructions.contains(i) && !_main.contains(i)));

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

    words.addAll(_main.map((i) => i.encode(this)).expand((words) => words));

    words[3] = _bound + 1;

    return Int32List.fromList(words).buffer;
  }
}
