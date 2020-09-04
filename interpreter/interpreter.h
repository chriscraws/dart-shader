// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef SSIR_INTERPRETER_INTERPRETER_H_
#define SSIR_INTERPRETER_INTERPRETER_H_

#include <memory>
#include <string>

namespace ssir {

// Error codes for interpreting.
enum Status {
  kSuccess = 0,
  kFailedToInitialize = 1,
  kInvalidData = 2,
  kFailure = 3,
};

// Outcome of an Interpret call.
struct Result {
  Status status;
  std::string message;
};

// Stub interpreter class.
class Interpreter {
 public:
  static std::unique_ptr<Interpreter> create();

  virtual ~Interpreter() = default;

  virtual Result Interpret(const char* data, size_t length) = 0;

  virtual std::string WriteSKSL() = 0;

 protected:
  Interpreter() = default;
};

}  // namespace ssir

#endif  // SSIR_INTERPRETER_INTERPRETER_H_
