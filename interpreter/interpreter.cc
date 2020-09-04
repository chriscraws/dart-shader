#include "interpreter/interpreter.h"

#include "external/spirv_tools/include/spirv-tools/libspirv.h"

namespace ssir {

class InterpreterImpl : public Interpreter {
 public:
  InterpreterImpl();
  virtual ~InterpreterImpl();

  virtual Result Interpret(const char* data, size_t length) override;
  virtual std::string WriteSKSL() override;
 private:
  const spv_context spv_context_;
  spv_diagnostic spv_diagnostic_;
};

namespace {

spv_result_t parse_header(void* user_data, spv_endianness_t endian, uint32_t magic, uint32_t version,
    uint32_t generator, uint32_t id_bound, uint32_t reserverd) {
  return SPV_SUCCESS;
}

spv_result_t parse_instruction(void* user_data, const spv_parsed_instruction_t* parsed_instruction) {
  return SPV_SUCCESS;
}

}  // namespace

InterpreterImpl::InterpreterImpl() :
  spv_context_(spvContextCreate(SPV_ENV_UNIVERSAL_1_2)) {}

InterpreterImpl::~InterpreterImpl() {
  if (spv_context_ != NULL) {
    spvContextDestroy(spv_context_);
  }
}

Result InterpreterImpl::Interpret(const char* data, size_t length) {
  if (spv_context_ == NULL) {
    return {
      .status = kFailedToInitialize,
      .message = "Failed to create SPIR-V Tools context."
    };
  }

  if (length % 4 != 0) {
    return {
      .status = kInvalidData,
      .message = "Provided data was not an integer number of 32-bit words"
    };
  }

  spv_result_t result = spvBinaryParse(
    spv_context_,
    this,  // user_data
    reinterpret_cast<const uint32_t*>(data),  // words
    length / 4,  // num_words
    &parse_header,
    &parse_instruction,
    &spv_diagnostic_
  );

  if (result != SPV_SUCCESS) {
    return {
      .status = kFailure,
      .message = "spv error code: " + std::to_string(result)
    };
  }

  return { .status = kSuccess };
}

std::string WriteSKSL() {
  return "";
}

}  // namespace ssir