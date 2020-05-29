// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef SSIR_INTERPRETER_INTERPRETER_H_
#define SSIR_INTERPRETER_INTERPRETER_H_

#include <string>

namespace ssir {

// Error codes for interpreting.
enum Status { kSuccess = 0 };

// Outcome of an Interpret call.
struct Result {
  Status status;
  std::string message;
};

// Stub interpreter class.
class Interpreter {
 public:
  Interpreter() = default;

  virtual ~Interpreter() = default;

  virtual void SetData(const char* data, size_t length) = 0;

  virtual Result Interpret() = 0;

  virtual std::string WriteSKSL() = 0;
};

}  // namespace ssir

#endif  // SSIR_INTERPRETER_INTERPRETER_H_
