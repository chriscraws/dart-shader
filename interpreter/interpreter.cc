#include "interpreter/interpreter.h"

#include <string>
#include <cstring>

#include "external/spirv_tools/include/spirv-tools/libspirv.h"
#include "external/spirv_headers/include/spirv/unified1/spirv.hpp"

namespace ssir {

class InterpreterImpl : public Interpreter {
 public:
  InterpreterImpl();
  virtual ~InterpreterImpl();

  virtual Result Interpret(const char* data, size_t length) override;
  virtual std::string WriteSKSL() override;

  spv_result_t HandleCapability(const spv_parsed_instruction_t* inst);
  spv_result_t HandleExtInstImport(const spv_parsed_instruction_t* inst);
  spv_result_t HandleMemoryModel(const spv_parsed_instruction_t* inst);

 private:
  const spv_context spv_context_;
  spv_diagnostic spv_diagnostic_;

  const uint32_t* words_;
  size_t word_count_;

  std::string last_error_msg_ = "";
};

namespace {

uint32_t get_operand(const spv_parsed_instruction_t* parsed_instruction, int operand_index) {
  return parsed_instruction->words[parsed_instruction->operands[operand_index].offset];
}

spv_result_t parse_header(void* user_data, spv_endianness_t endian, uint32_t magic, uint32_t version,
    uint32_t generator, uint32_t id_bound, uint32_t reserverd) {
  return SPV_SUCCESS;
}

spv_result_t parse_instruction(void* user_data, const spv_parsed_instruction_t* parsed_instruction) {
  auto* interpreter = static_cast<InterpreterImpl*>(user_data);
  switch (parsed_instruction->opcode) {
    case spv::OpCapability:
      return interpreter->HandleCapability(parsed_instruction);
    case spv::OpExtInstImport:
      return interpreter->HandleExtInstImport(parsed_instruction);
    case spv::OpMemoryModel:
      return interpreter->HandleMemoryModel(parsed_instruction);
    default:
      return SPV_UNSUPPORTED;
  }
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

  words_ = reinterpret_cast<const uint32_t*>(data);
  word_count_ = length / 4;

  spv_result_t result = spvBinaryParse(
    spv_context_,
    this,  // user_data
    words_, 
    word_count_,
    &parse_header,
    &parse_instruction,
    &spv_diagnostic_
  );

  if (result != SPV_SUCCESS) {
    return {
      .status = kFailure,
      .message = last_error_msg_.empty() ?
        "spv error code: " + std::to_string(result) :
        last_error_msg_
    };
  }

  return { .status = kSuccess };
}

std::string InterpreterImpl::WriteSKSL() {
  return "";
}

spv_result_t InterpreterImpl::HandleCapability(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kCapabilityIndex = 0;
  uint32_t capability = get_operand(inst, kCapabilityIndex);
  switch (capability) {
    case spv::CapabilityMatrix:
    case spv::CapabilityShader:
    case spv::CapabilityLinkage:
      return SPV_SUCCESS;
    default:
      last_error_msg_ = "OpCapability: Capability " +
          std::to_string(capability) + " is unsupported.";
      return SPV_UNSUPPORTED;
  }
}

spv_result_t InterpreterImpl::HandleExtInstImport(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kNameIndex = 0;
  static constexpr char kGLSLImportName[] = "GLSL.std.450";

  const char* name = reinterpret_cast<const char*>(
      &inst->words[inst->operands[kNameIndex].offset]);
  if (!strcmp(kGLSLImportName, name)) {
    last_error_msg_ = "OpExtInstImport: '" + std::string(kGLSLImportName) +
        "' is not supported.";
    return SPV_UNSUPPORTED;
  }
  
  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleMemoryModel(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kAddressingModelIndex = 0;
  static constexpr int kMemoryModelIndex = 0;

  uint32_t addressing_model = get_operand(inst, kAddressingModelIndex);
  if (addressing_model != spv::AddressingModelLogical) {
    last_error_msg_ = "OpMemoryModel: Only `Logical` addressing model is supported.";
    return SPV_UNSUPPORTED;
  }

  uint32_t memory_model = get_operand(inst, kMemoryModelIndex);
  if (memory_model != spv::MemoryModelGLSL450) {
    last_error_msg_ = "OpMemoryModel: Only memory model `GLSL450` is supported.";
    return SPV_UNSUPPORTED;
  }
  return SPV_SUCCESS;
}

}  // namespace ssir