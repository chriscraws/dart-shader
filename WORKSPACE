load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
  name = "spirv_tools",
  urls = ["https://github.com/KhronosGroup/SPIRV-Tools/archive/v2020.4.zip"],
  strip_prefix = "SPIRV-Tools-2020.4",
)

http_archive(
  name = "spirv_headers",
  urls = ["https://github.com/KhronosGroup/SPIRV-Headers/archive/1.5.3.reservations1.zip"],
  strip_prefix = "SPIRV-Headers-1.5.3.reservations1",
)

http_archive(
  name = "com_google_googletest",
  urls = ["https://github.com/google/googletest/archive/release-1.10.0.zip"],
  strip_prefix = "googletest-release-1.10.0",
)

http_archive(
     name = "com_google_absl",
     urls = ["https://github.com/abseil/abseil-cpp/archive/master.zip"],
     strip_prefix = "abseil-cpp-master",
)

http_archive(
    name = "rules_cc",
    strip_prefix = "rules_cc-master",
    urls = ["https://github.com/bazelbuild/rules_cc/archive/master.zip"],
)

http_archive(
    name = "rules_python",
    strip_prefix = "rules_python-master",
    urls = ["https://github.com/bazelbuild/rules_python/archive/master.zip"],
)