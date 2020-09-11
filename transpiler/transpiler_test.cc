#include "transpiler/transpiler.h"

#include <fstream>
#include <iostream>

#include "external/com_google_googletest/googletest/include/gtest/gtest.h"

namespace ssir {

TEST(TranspilerTest, SimpleGolden) {
  std::ifstream input("expr/test/goldens/simple.golden", std::ios::binary);
  std::string spirv((std::istreambuf_iterator<char>(input)),
                    std::istreambuf_iterator<char>());
  auto t = Transpiler::create();
  auto result = t->Transpile(spirv.c_str(), spirv.length());
  EXPECT_EQ(result.message, "");
  EXPECT_EQ(result.status, kSuccess);
  std::cout << t->GetSkSL();
}

TEST(TranspilerTest, ScalarGolden) {
  std::ifstream input("expr/test/goldens/scalar.golden", std::ios::binary);
  std::string spirv((std::istreambuf_iterator<char>(input)),
                    std::istreambuf_iterator<char>());
  auto t = Transpiler::create();
  auto result = t->Transpile(spirv.c_str(), spirv.length());
  EXPECT_EQ(result.message, "");
  EXPECT_EQ(result.status, kSuccess);
  std::cout << t->GetSkSL();
}

TEST(TranspilerTest, Vec2Golden) {
  std::ifstream input("expr/test/goldens/vec2op.golden", std::ios::binary);
  std::string spirv((std::istreambuf_iterator<char>(input)),
                    std::istreambuf_iterator<char>());
  auto t = Transpiler::create();
  auto result = t->Transpile(spirv.c_str(), spirv.length());
  EXPECT_EQ(result.message, "");
  EXPECT_EQ(result.status, kSuccess);
  std::cout << t->GetSkSL();
}

TEST(TranspilerTest, Vec3Golden) {
  std::ifstream input("expr/test/goldens/vec3op.golden", std::ios::binary);
  std::string spirv((std::istreambuf_iterator<char>(input)),
                    std::istreambuf_iterator<char>());
  auto t = Transpiler::create();
  auto result = t->Transpile(spirv.c_str(), spirv.length());
  EXPECT_EQ(result.message, "");
  EXPECT_EQ(result.status, kSuccess);
  std::cout << t->GetSkSL();
}

TEST(TranspilerTest, Vec4Golden) {
  std::ifstream input("expr/test/goldens/vec4op.golden", std::ios::binary);
  std::string spirv((std::istreambuf_iterator<char>(input)),
                    std::istreambuf_iterator<char>());
  auto t = Transpiler::create();
  auto result = t->Transpile(spirv.c_str(), spirv.length());
  EXPECT_EQ(result.message, "");
  EXPECT_EQ(result.status, kSuccess);
  std::cout << t->GetSkSL();
}

TEST(TranspilerTest, GLSLGolden) {
  std::ifstream input("expr/test/goldens/glslop.golden", std::ios::binary);
  std::string spirv((std::istreambuf_iterator<char>(input)),
                    std::istreambuf_iterator<char>());
  auto t = Transpiler::create();
  auto result = t->Transpile(spirv.c_str(), spirv.length());
  EXPECT_EQ(result.message, "");
  EXPECT_EQ(result.status, kSuccess);
  std::cout << t->GetSkSL();
}

}  // namespace ssir