
cc_library(
  name = "transpiler",
  hdrs = ["transpiler.h"],
  srcs = [
    "transpiler.cc",
  ],
  linkstatic = 1,
  deps = [
    "@com_google_absl//absl/memory",
    "@spirv_tools//:spirv_tools",
    "@spirv_headers//:spirv_cpp_headers",
    "@spirv_headers//:spirv_common_headers",
  ]
)

cc_test(
  name = "transpiler_test",
  srcs = ["transpiler_test.cc"],
  data = [
    "//expr/test/goldens:glslop.golden",
    "//expr/test/goldens:simple.golden",
    "//expr/test/goldens:scalar.golden",
    "//expr/test/goldens:vec2op.golden",
    "//expr/test/goldens:vec3op.golden",
    "//expr/test/goldens:vec4op.golden",
  ],
  deps = [
    ":transpiler",
    "@com_google_googletest//:gtest",
    "@com_google_googletest//:gtest_main",
  ]
)