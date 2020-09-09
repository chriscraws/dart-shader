#include "interpreter/interpreter.h"

#include <cstring>
#include <sstream>
#include <string>

#include "external/spirv_headers/include/spirv/unified1/spirv.hpp"
#include "external/spirv_tools/include/spirv-tools/libspirv.h"
#include "interpreter/expression.h"

namespace ssir {

class InterpreterImpl : public Interpreter {
 public:
  InterpreterImpl();
  virtual ~InterpreterImpl();

  virtual Result Interpret(const char* data, size_t length) override;
  virtual std::string WriteSKSL() override;

  void set_last_op(uint32_t op);

  ExpressionType ResolveType(uint32_t);

  spv_result_t HandleCapability(const spv_parsed_instruction_t* inst);
  spv_result_t HandleExtInstImport(const spv_parsed_instruction_t* inst);
  spv_result_t HandleMemoryModel(const spv_parsed_instruction_t* inst);
  spv_result_t HandleDecorate(const spv_parsed_instruction_t* inst);
  spv_result_t HandleTypeFloat(const spv_parsed_instruction_t* inst);
  spv_result_t HandleTypeVector(const spv_parsed_instruction_t* inst);
  spv_result_t HandleTypeFunction(const spv_parsed_instruction_t* inst);
  spv_result_t HandleConstant(const spv_parsed_instruction_t* inst);
  spv_result_t HandleFunction(const spv_parsed_instruction_t* inst);
  spv_result_t HandleFunctionParameter(const spv_parsed_instruction_t* inst);
  spv_result_t HandleLabel(const spv_parsed_instruction_t* inst);

 private:
  const spv_context spv_context_;
  spv_diagnostic spv_diagnostic_;

  const uint32_t* words_;
  size_t word_count_;

  std::string last_error_msg_ = "";

  // Result-IDs of important instructions.
  uint32_t main_function_type_, float_type_, vec2_type_, vec3_type_, vec4_type_,
      main_function_, frag_position_param_ = 0;
  uint32_t last_op_ = 0;
  std::stringstream sksl_;
  std::unordered_map<uint32_t, Expression> expressions_;
};

namespace {

constexpr char kFragColorParamName[] = "fragPos";

uint32_t get_operand(const spv_parsed_instruction_t* parsed_instruction,
                     int operand_index) {
  return parsed_instruction
      ->words[parsed_instruction->operands[operand_index].offset];
}

const char* get_literal(const spv_parsed_instruction_t* parsed_instruction,
                        int operand_index) {
  return reinterpret_cast<const char*>(
      &parsed_instruction
           ->words[parsed_instruction->operands[operand_index].offset]);
}

spv_result_t parse_header(void* user_data, spv_endianness_t endian,
                          uint32_t magic, uint32_t version, uint32_t generator,
                          uint32_t id_bound, uint32_t reserverd) {
  return SPV_SUCCESS;
}

spv_result_t parse_instruction(
    void* user_data, const spv_parsed_instruction_t* parsed_instruction) {
  auto* interpreter = static_cast<InterpreterImpl*>(user_data);
  spv_result_t result = SPV_UNSUPPORTED;

  switch (parsed_instruction->opcode) {
    case spv::OpCapability:
      result = interpreter->HandleCapability(parsed_instruction);
      break;
    case spv::OpExtInstImport:
      result = interpreter->HandleExtInstImport(parsed_instruction);
      break;
    case spv::OpMemoryModel:
      result = interpreter->HandleMemoryModel(parsed_instruction);
      break;
    case spv::OpTypeFloat:
      result = interpreter->HandleTypeFloat(parsed_instruction);
      break;
    case spv::OpTypeVector:
      result = interpreter->HandleTypeVector(parsed_instruction);
      break;
    case spv::OpTypeFunction:
      result = interpreter->HandleTypeFunction(parsed_instruction);
      break;
    case spv::OpConstant:
      result = interpreter->HandleConstant(parsed_instruction);
      break;
    case spv::OpFunction:
      result = interpreter->HandleFunction(parsed_instruction);
      break;
    case spv::OpFunctionParameter:
      result = interpreter->HandleFunctionParameter(parsed_instruction);
      break;
    case spv::OpLabel:
      result = interpreter->HandleLabel(parsed_instruction);
      break;
    default:
      return SPV_UNSUPPORTED;
  }

  interpreter->set_last_op(parsed_instruction->opcode);
  return result;
}

}  // namespace

InterpreterImpl::InterpreterImpl()
    : spv_context_(spvContextCreate(SPV_ENV_UNIVERSAL_1_2)) {}

InterpreterImpl::~InterpreterImpl() {
  if (spv_context_ != NULL) {
    spvContextDestroy(spv_context_);
  }
}

Result InterpreterImpl::Interpret(const char* data, size_t length) {
  if (spv_context_ == NULL) {
    return {.status = kFailedToInitialize,
            .message = "Failed to create SPIR-V Tools context."};
  }

  if (length % 4 != 0) {
    return {
        .status = kInvalidData,
        .message = "Provided data was not an integer number of 32-bit words"};
  }

  words_ = reinterpret_cast<const uint32_t*>(data);
  word_count_ = length / 4;

  // Write SkSL header
  sksl_ << "half4 main(half2 " << kFragColorParamName << ") {\n  ";

  spv_result_t result = spvBinaryParse(spv_context_,
                                       this,  // user_data
                                       words_, word_count_, &parse_header,
                                       &parse_instruction, &spv_diagnostic_);

  if (result != SPV_SUCCESS) {
    sksl_.str("");
    return {.status = kFailure,
            .message = last_error_msg_.empty()
                           ? "spv error code: " + std::to_string(result)
                           : last_error_msg_};
  }

  return {.status = kSuccess};
}

std::string InterpreterImpl::WriteSKSL() { return ""; }

void InterpreterImpl::set_last_op(uint32_t op) { last_op_ = op; }

ExpressionType InterpreterImpl::ResolveType(uint32_t id) {
  if (id == float_type_) {
    return kFloat;
  } else if (id == vec2_type_) {
    return kVec2;
  } else if (id == vec3_type_) {
    return kVec3;
  } else if (id == vec4_type_) {
    return kVec4;
  }
  return kNone;
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
  static constexpr int kMemoryModelIndex = 1;

  uint32_t addressing_model = get_operand(inst, kAddressingModelIndex);
  if (addressing_model != spv::AddressingModelLogical) {
    last_error_msg_ =
        "OpMemoryModel: Only `Logical` addressing model is supported.";
    return SPV_UNSUPPORTED;
  }

  uint32_t memory_model = get_operand(inst, kMemoryModelIndex);
  if (memory_model != spv::MemoryModelGLSL450) {
    last_error_msg_ =
        "OpMemoryModel: Only memory model `GLSL450` is supported.";
    return SPV_UNSUPPORTED;
  }
  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleDecorate(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kTargetIndex = 0;
  static constexpr int kDecorationIndex = 1;
  static constexpr int kLinkageName = 2;
  static constexpr int kLinkageType = 3;
  static constexpr char kMainExportName[] = "main";

  if (get_operand(inst, kDecorationIndex) != spv::DecorationLinkageAttributes) {
    last_error_msg_ = "OpDecorate: Only LinkageAttributes are supported.";
    return SPV_UNSUPPORTED;
  }

  if (get_operand(inst, kLinkageType) != spv::LinkageTypeExport) {
    last_error_msg_ =
        "OpDecorate: Only exporting is available "
        "using LinkageAttributes.";
    return SPV_UNSUPPORTED;
  }

  if (!strcmp(get_literal(inst, kLinkageName), kMainExportName) ||
      main_function_type_ != 0) {
    last_error_msg_ =
        "OpDecorate: There can only be a single exported "
        "function named 'main'.";
    return SPV_UNSUPPORTED;
  }

  main_function_ = get_operand(inst, kTargetIndex);
  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleTypeFloat(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kWidthIndex = 0;
  static constexpr uint32_t kRequiredFloatWidth = 32;
  uint32_t width = get_operand(inst, kWidthIndex);
  if (width != kRequiredFloatWidth) {
    last_error_msg_ = "OpTypeFloat: Only 32-bit width is supported.";
    return SPV_UNSUPPORTED;
  }

  if (float_type_ != 0) {
    last_error_msg_ = "OpTypeFloat: Only one OpTypeFloat should be specified.";
    return SPV_UNSUPPORTED;
  }

  float_type_ = inst->result_id;
  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleTypeVector(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kComponentTypeIndex = 0;
  static constexpr int kComponentCountIndex = 0;
  uint32_t type = get_operand(inst, kComponentTypeIndex);
  if (type == 0 || type != float_type_) {
    last_error_msg_ =
        "OpTypeVector: OpTypeFloat was not declared, "
        "or didn't match the given component type.";
    return SPV_ERROR_INVALID_VALUE;
  }

  uint32_t count = get_operand(inst, kComponentCountIndex);

  switch (count) {
    case 2:
      vec2_type_ = inst->result_id;
      break;
    case 3:
      vec3_type_ = inst->result_id;
      break;
    case 4:
      vec4_type_ = inst->result_id;
      break;
    default:
      last_error_msg_ = "OpTypeVector: Component count must be 2, 3, or 4.";
      return SPV_UNSUPPORTED;
  }

  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleTypeFunction(
    const spv_parsed_instruction_t* inst) {
  if (main_function_type_ != 0) {
    last_error_msg_ =
        "OpTypeFunction: Only a single function type is supported.";
    return SPV_UNSUPPORTED;
  }

  if (inst->num_operands > 1) {
    last_error_msg_ = "OpTypeFunction: Only one parameter is supported.";
    return SPV_UNSUPPORTED;
  }

  uint32_t param_type_id = get_operand(inst, 0);
  if (param_type_id == 0 || param_type_id != vec2_type_) {
    last_error_msg_ =
        "OpTypeFunction: Parameter type was not defined or was not vec2.";
    return SPV_UNSUPPORTED;
  }

  if (inst->type_id == 0 || inst->type_id != vec4_type_) {
    last_error_msg_ =
        "OpTypeFunction: Return type was not defined or was not vec4.";
    return SPV_UNSUPPORTED;
  }

  main_function_type_ = inst->result_id;
  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleConstant(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kValueIndex = 0;

  if (inst->type_id == 0 || inst->type_id != float_type_) {
    last_error_msg_ = "OpConstant: Must have float-type.";
    return SPV_UNSUPPORTED;
  }

  float value = *reinterpret_cast<const float*>(get_literal(inst, kValueIndex));
  expressions_.emplace(inst->result_id,
                       Expression(kFloat, std::to_string(value)));
  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleFunction(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kFunctionControlIndex = 0;
  static constexpr int kFunctionTypeIndex = 0;

  if (inst->result_id == 0 || inst->result_id != main_function_) {
    last_error_msg_ =
        "OpFunction: There must be one function exported as 'main'";
    return SPV_UNSUPPORTED;
  }

  uint32_t function_control = get_operand(inst, kFunctionControlIndex);
  if (function_control != spv::FunctionControlMaskNone) {
    last_error_msg_ = "OpFunction: No function control flags are supported.";
    return SPV_UNSUPPORTED;
  }

  uint32_t function_type = get_operand(inst, kFunctionTypeIndex);
  if (function_type == 0 || function_type != main_function_type_) {
    last_error_msg_ = "OpFunction: Function type mismatch.";
    return SPV_UNSUPPORTED;
  }

  if (inst->type_id != vec4_type_) {
    last_error_msg_ = "OpFunction: Function must return vec4 type.";
    return SPV_UNSUPPORTED;
  }

  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleFunctionParameter(
    const spv_parsed_instruction_t* inst) {
  if (frag_position_param_ != 0) {
    last_error_msg_ =
        "OpFunctionParam: There can only be one specified parameter.";
    return SPV_UNSUPPORTED;
  }

  if (inst->type_id != vec2_type_) {
    last_error_msg_ = "OpFunctionParam: Param must be type vec2.";
    return SPV_UNSUPPORTED;
  }

  frag_position_param_ = inst->result_id;
  return SPV_SUCCESS;
}

spv_result_t InterpreterImpl::HandleLabel(
    const spv_parsed_instruction_t* inst) {
  if (last_op_ != spv::OpFunctionParameter) {
    last_error_msg_ =
        "OpLabel: The last instruction should have been OpFunctionParameter.";
    return SPV_UNSUPPORTED;
  }

  return SPV_SUCCESS;
}

}  // namespace ssir