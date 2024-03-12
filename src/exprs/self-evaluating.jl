is_self_evaluating(expr) = isa(expr, Int) || isa(expr, Float64) || isa(expr, Bool) || isa(expr, String) || is_lambda(expr)
