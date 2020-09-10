#include "transpiler/transpiler.h"

#include <cstring>
#include <sstream>
#include <string>

#include "external/spirv_headers/include/spirv/unified1/GLSL.std.450.h"
#include "external/spirv_headers/include/spirv/unified1/spirv.hpp"
#include "external/spirv_tools/include/spirv-tools/libspirv.h"

namespace ssir {

class TranspilerImpl : public Transpiler {
 public:
  TranspilerImpl();
  virtual ~TranspilerImpl();

  virtual Result Transpile(const char* data, size_t length) override;
  virtual std::string GetSkSL() override;

  void set_last_op(uint32_t op);

  spv_result_t HandleCapability(const spv_parsed_instruction_t* inst);
  spv_result_t HandleExtInstImport(const spv_parsed_instruction_t* inst);
  spv_result_t HandleMemoryModel(const spv_parsed_instruction_t* inst);
  spv_result_t HandleDecorate(const spv_parsed_instruction_t* inst);
  spv_result_t HandleTypeFloat(const spv_parsed_instruction_t* inst);
  spv_result_t HandleTypeVector(const spv_parsed_instruction_t* inst);
  spv_result_t HandleTypeFunction(const spv_parsed_instruction_t* inst);
  spv_result_t HandleConstant(const spv_parsed_instruction_t* inst);
  spv_result_t HandleConstantComposite(const spv_parsed_instruction_t* inst);
  spv_result_t HandleFunction(const spv_parsed_instruction_t* inst);
  spv_result_t HandleFunctionParameter(const spv_parsed_instruction_t* inst);
  spv_result_t HandleLabel(const spv_parsed_instruction_t* inst);
  spv_result_t HandleReturnValue(const spv_parsed_instruction_t* inst);
  spv_result_t HandleFNegate(const spv_parsed_instruction_t* inst);
  spv_result_t HandleOperator(const spv_parsed_instruction_t* inst, char op);
  spv_result_t HandleBuiltin(const spv_parsed_instruction_t* inst,
                             std::string name);
  spv_result_t HandleExtInst(const spv_parsed_instruction_t* inst);

 private:
  std::string ResolveName(uint32_t id);
  std::string ResolveType(uint32_t id);
  std::string ResolveGLSLName(uint32_t id);

  const spv_context spv_context_;
  spv_diagnostic spv_diagnostic_;

  const uint32_t* words_;
  size_t word_count_;

  std::string last_error_msg_ = "";

  // Result-IDs of important instructions.
  uint32_t main_function_type_, float_type_, vec2_type_, vec3_type_, vec4_type_,
      main_function_, frag_position_param_, return_ = 0;
  uint32_t last_op_ = 0;
  std::stringstream sksl_;
};

namespace {

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
  auto* interpreter = static_cast<TranspilerImpl*>(user_data);
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
    case spv::OpConstantComposite:
      result = interpreter->HandleConstantComposite(parsed_instruction);
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
    case spv::OpReturnValue:
      result = interpreter->HandleReturnValue(parsed_instruction);
      break;
    case spv::OpFNegate:
      result = interpreter->HandleFNegate(parsed_instruction);
      break;
    case spv::OpFAdd:
      result = interpreter->HandleOperator(parsed_instruction, '+');
      break;
    case spv::OpFSub:
      result = interpreter->HandleOperator(parsed_instruction, '-');
      break;
    case spv::OpFMul:
    case spv::OpVectorTimesScalar:
    case spv::OpVectorTimesMatrix:
    case spv::OpMatrixTimesVector:
    case spv::OpMatrixTimesMatrix:
      result = interpreter->HandleOperator(parsed_instruction, '*');
      break;
    case spv::OpFDiv:
      result = interpreter->HandleOperator(parsed_instruction, '/');
      break;
    case spv::OpFMod:
      result = interpreter->HandleBuiltin(parsed_instruction, "mod");
      break;
    case spv::OpDot:
      result = interpreter->HandleBuiltin(parsed_instruction, "dot");
      break;
    case spv::OpExtInst:
      result = interpreter->HandleExtInst(parsed_instruction);
      break;
    default:
      return SPV_UNSUPPORTED;
  }

  interpreter->set_last_op(parsed_instruction->opcode);
  return result;
}

}  // namespace

TranspilerImpl::TranspilerImpl()
    : spv_context_(spvContextCreate(SPV_ENV_UNIVERSAL_1_2)) {}

TranspilerImpl::~TranspilerImpl() {
  if (spv_context_ != NULL) {
    spvContextDestroy(spv_context_);
  }
}

Result TranspilerImpl::Transpile(const char* data, size_t length) {
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

std::string TranspilerImpl::GetSkSL() { return sksl_.str(); }

void TranspilerImpl::set_last_op(uint32_t op) { last_op_ = op; }

std::string TranspilerImpl::ResolveName(uint32_t id) {
  return "i" + std::to_string(id);
}

std::string TranspilerImpl::ResolveType(uint32_t id) {
  if (id == float_type_) {
    return "float";
  } else if (id == vec2_type_) {
    return "vec2";
  } else if (id == vec3_type_) {
    return "vec3";
  } else if (id == vec4_type_) {
    return "vec4";
  }
  return "";
}

spv_result_t TranspilerImpl::HandleCapability(
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

spv_result_t TranspilerImpl::HandleExtInstImport(
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

spv_result_t TranspilerImpl::HandleMemoryModel(
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

spv_result_t TranspilerImpl::HandleDecorate(
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

spv_result_t TranspilerImpl::HandleTypeFloat(
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

spv_result_t TranspilerImpl::HandleTypeVector(
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

spv_result_t TranspilerImpl::HandleTypeFunction(
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

spv_result_t TranspilerImpl::HandleConstant(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kValueIndex = 0;

  if (inst->type_id == 0 || inst->type_id != float_type_) {
    last_error_msg_ = "OpConstant: Must have float-type.";
    return SPV_UNSUPPORTED;
  }

  float value = *reinterpret_cast<const float*>(get_literal(inst, kValueIndex));

  sksl_ << "  const float " << ResolveName(inst->result_id) << " = " << value
        << ";\n";

  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleConstantComposite(
    const spv_parsed_instruction_t* inst) {
  int opcount = inst->num_operands;

  sksl_ << "  const vec" << opcount << ResolveName(inst->result_id) << " = vec"
        << opcount << "(";

  for (int i = 0; i < opcount; i++) {
    sksl_ << ResolveName(get_operand(inst, i));
    if (i < opcount - 1) {
      sksl_ << ", ";
    }
  }

  sksl_ << ");\n";

  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleFunction(
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

  sksl_ << "half4 main(";

  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleFunctionParameter(
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

  sksl_ << "half2 " << ResolveName(frag_position_param_);

  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleLabel(const spv_parsed_instruction_t* inst) {
  if (last_op_ != spv::OpFunctionParameter) {
    last_error_msg_ =
        "OpLabel: The last instruction should have been OpFunctionParameter.";
    return SPV_UNSUPPORTED;
  }
  sksl_ << ") {\n";
  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleReturnValue(
    const spv_parsed_instruction_t* inst) {
  static constexpr int kReturnIdIndex = 0;
  if (return_ != 0) {
    last_error_msg_ = "OpReturnValue: There can only be one return value.";
    return SPV_UNSUPPORTED;
  }
  return_ = get_operand(inst, kReturnIdIndex);
  sksl_ << "  return half4(" << ResolveName(return_) << ");\n";
  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleFNegate(
    const spv_parsed_instruction_t* inst) {
  std::string type = ResolveType(inst->type_id);
  if (type.empty()) {
    last_error_msg_ = "Invalid type.";
    return SPV_ERROR_INVALID_BINARY;
  }
  sksl_ << "  " << type << " " << ResolveName(inst->result_id) << " = -"
        << ResolveName(get_operand(inst, 0)) << ";\n";
  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleOperator(
    const spv_parsed_instruction_t* inst, char op) {
  if (inst->num_operands != 2) {
    last_error_msg_ = "Operator '";
    last_error_msg_.push_back(op);
    last_error_msg_ += "' needs two arguments.";
    return SPV_ERROR_INVALID_BINARY;
  }
  std::string type = ResolveType(inst->type_id);
  if (type.empty()) {
    last_error_msg_ = "Invalid type.";
    return SPV_ERROR_INVALID_BINARY;
  }
  sksl_ << "  " << type << " " << ResolveName(inst->result_id) << " = "
        << ResolveName(get_operand(inst, 0)) << op
        << ResolveName(get_operand(inst, 1)) << ";\n";
  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleBuiltin(const spv_parsed_instruction_t* inst,
                                           std::string name) {
  if (inst->num_operands != 2) {
    last_error_msg_ = "Builtin '" + name + "' needs two arguments.";
    return SPV_ERROR_INVALID_BINARY;
  }
  std::string type = ResolveType(inst->type_id);
  if (type.empty()) {
    last_error_msg_ = "Invalid type.";
    return SPV_ERROR_INVALID_BINARY;
  }
  sksl_ << "  " << type << " " << ResolveName(inst->result_id)
        << " = " + name + "(" << ResolveName(get_operand(inst, 0)) << ", "
        << ResolveName(get_operand(inst, 1)) << ");\n";

  return SPV_SUCCESS;
}

spv_result_t TranspilerImpl::HandleExtInst(
    const spv_parsed_instruction_t* inst) {
  std::string type = ResolveType(inst->type_id);
  if (type.empty()) {
    last_error_msg_ = "Invalid type.";
    return SPV_ERROR_INVALID_BINARY;
  }

  if (inst->ext_inst_type != SPV_EXT_INST_TYPE_GLSL_STD_450) {
    last_error_msg_ = "OpExtInst: Must be from 'glsl.450.std'";
    return SPV_UNSUPPORTED;
  }

  static constexpr int kExtInstOperationIndex = 1;
  static constexpr int kExtInstFirstOperandIndex = 2;
  uint32_t glsl_op = get_operand(inst, kExtInstOperationIndex);
  std::string glsl_name = ResolveGLSLName(glsl_op);

  if (glsl_name.empty()) {
    last_error_msg_ = "OpExtInst: '" + std::to_string(glsl_op) +
                      "' is not a supported GLSL instruction.";
    return SPV_UNSUPPORTED;
  }

  sksl_ << "  " << type << " " << ResolveName(inst->result_id) << " = "
        << glsl_name << "(";

  int op_count = inst->num_operands - kExtInstFirstOperandIndex;
  for (int i = 0; i < op_count; i++) {
    sksl_ << ResolveName(get_operand(inst, kExtInstFirstOperandIndex + i));
    if (i != op_count - 1) {
      sksl_ << ", ";
    }
  }

  sksl_ << ");\n";

  return SPV_SUCCESS;
}

std::string TranspilerImpl::ResolveGLSLName(uint32_t id) {
  switch (id) {
    case GLSLstd450Trunc:
      return "trunc";
    case GLSLstd450FAbs:
      return "abs";
    case GLSLstd450FSign:
      return "sign";
    case GLSLstd450Floor:
      return "floor";
    case GLSLstd450Ceil:
      return "ceil";
    case GLSLstd450Fract:
      return "fract";
    case GLSLstd450Radians:
      return "radians";
    case GLSLstd450Degrees:
      return "degrees";
    case GLSLstd450Sin:
      return "sin";
    case GLSLstd450Cos:
      return "cos";
    case GLSLstd450Tan:
      return "tan";
    case GLSLstd450Asin:
      return "asin";
    case GLSLstd450Acos:
      return "acos";
    case GLSLstd450Atan:
      return "atan";
    case GLSLstd450Atan2:
      return "atan2";
    case GLSLstd450Pow:
      return "pow";
    case GLSLstd450Exp:
      return "exp";
    case GLSLstd450Log:
      return "log";
    case GLSLstd450Exp2:
      return "exp2";
    case GLSLstd450Log2:
      return "log2";
    case GLSLstd450Sqrt:
      return "sqrt";
    case GLSLstd450InverseSqrt:
      return "inversesqrt";
    case GLSLstd450FMin:
      return "min";
    case GLSLstd450FMax:
      return "max";
    case GLSLstd450FClamp:
      return "clamp";
    case GLSLstd450FMix:
      return "mix";
    case GLSLstd450Step:
      return "step";
    case GLSLstd450SmoothStep:
      return "smoothstep";
    case GLSLstd450Length:
      return "length";
    case GLSLstd450Distance:
      return "distance";
    case GLSLstd450Cross:
      return "cross";
    case GLSLstd450Normalize:
      return "normalize";
    case GLSLstd450FaceForward:
      return "faceforward";
    case GLSLstd450Reflect:
      return "reflect";
    default:
      return "";
  }
}

}  // namespace ssir