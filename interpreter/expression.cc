#include "interpreter/expression.h"

namespace ssir {

Expression::Expression(ExpressionType type, std::string template_str,
                       std::vector<uint32_t> deps)
    : type_(type), template_str_(template_str), deps_(deps) {}

ExpressionType Expression::type() { return type_; }

}  // namespace ssir