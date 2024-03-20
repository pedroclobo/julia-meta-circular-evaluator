struct Fexpr
    lambda
    env
end

is_fexpr(expr) = isa(expr, Fexpr)

fexpr_lambda(expr) = expr.lambda

fexpr_env(expr) = expr.env

eval_fexpr(expr, env) = make_fexpr(lambda_params(fexpr_lambda(expr)), lambda_body(fexpr_lambda(expr)), env)

make_fexpr(args, body, env) = Fexpr(:($(Expr(:tuple, (args...))) -> $(body)), env)

Base.show(io::IO, _::Fexpr) = print(io, "<fexpr>")
