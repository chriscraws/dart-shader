
cc_library(
  name = "interpreter",
  hdrs = ["interpreter.h"],
  srcs = [
    "expression.h",
    "expression.cc",
    "interpreter.cc",
  ],
  deps = [
    "@spirv_tools//:spirv_tools",
    "@spirv_headers//:spirv_cpp_headers",
    "@spirv_headers//:spirv_common_headers",
  ]
)
