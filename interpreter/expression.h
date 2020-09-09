// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef SSIR_INTERPRETER_EXPRESSION_H_
#define SSIR_INTERPRETER_EXPRESSION_H_

#include <functional>
#include <string>
#include <unordered_map>
#include <vector>

namespace ssir {

enum ExpressionType { kNone, kFloat, kVec2, kVec3, kVec4 };

class Expression {
 public:
  explicit Expression(ExpressionType type, std::string template_str,
                      std::vector<uint32_t> deps = {});

  ExpressionType type();

 private:
  const ExpressionType type_;
  const std::string template_str_;
  const std::vector<uint32_t> deps_;
};

}  // namespace ssir

#endif  // SSIR_INTERPRETER_EXPRESSION_H_