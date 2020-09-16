// This file defines the SPIR-V Instruction class and an
// interface for keeping track of Instruction IDs.

import 'dart:typed_data';

/// Identifier is used to assign ids to Instructions.
abstract class Identifier {
  /// Assign an ID to an Instruction, and return it. If
  /// an ID is already assigned, return that.
  int identify(Instruction inst);
}

/// It's helpful to identify types statically.
mixin Type on Instruction {
  int get elementCount;
}

/// Instructions that can evaluate to a value.
mixin Evaluable on Instruction {
  final List<double> value = <double>[];
  void evaluate();
}

/// Instructions are the next level of semantics in SPIR-V,
/// they are essentially a grouping of words, that can be
/// optionally assigned an identifier.
abstract class Instruction {
  /// Optional type for the instruction.
  final Type type;

  /// True if this instruction provides a result.
  final bool result;

  /// SPIR-V code for the instruction.
  final int opCode;

  // True if this instruction is a variable or constant declaration.
  final bool isDeclaration;

  // True if this instruction is a type declaration.
  final bool isType;

  // True if this instruction is a decoration.
  final bool isDecoration;

  // Null if not a constant, otherwise, the constant value.
  final double constant;

  // Null if not a variable, otherwise the variable value.
  // Must have length equal to [type.elementCount].
  Float32List get variable => null;

  const Instruction({
    this.opCode,
    this.type,
    this.constant,
    this.result = false,
    this.isDeclaration = false,
    this.isType = false,
    this.isDecoration = false,
  });

  /// Ensure that every Instruction included transitively
  /// by this Instruction has been assigned and ID by the
  /// Identifier.
  void resolve(Identifier i) {
    for (final dep in deps) {
      dep.resolve(i);
    }
    if (result) {
      i.identify(this);
    }
  }

  /// Encode the word-stream of operands for this Instruction.
  /// This method should be overwridden by subclasses.
  List<int> operands(Identifier i) => [];

  /// Encode the full word-stream for the entire instruction.
  /// This method should not be overridden.
  List<int> encode(Identifier i) {
    final ops = operands(i);
    int wordCount = ops.length + 1;
    if (type != null) wordCount++;
    if (result) wordCount++;
    return <int>[
      wordCount << 16 | opCode,
      if (type != null) i.identify(type),
      if (result) i.identify(this),
      ...ops,
    ];
  }

  /// Returns any Instructions that return results and need
  /// to be defined before this Instruction. This should be
  /// overriden by subclasses.
  List<Instruction> get deps => [];
}
