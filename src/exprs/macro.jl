struct Macro
    lambda
    env
end

is_macro(expr) = isa(expr, Macro)

macro_lambda(expr) = expr.lambda

macro_env(expr) = expr.env

eval_macro(expr, env) = make_macro(lambda_params(macro_lambda(expr)), lambda_body(macro_lambda(expr)), env)

make_macro(args, body, env) = Macro(:($(Expr(:tuple, (args...))) -> $(body)), env)

Base.show(io::IO, _::Macro) = print(io, "<macro>")
