include("fexpr.jl")

#=
Function captures a lambda and the environment where it was defined.
The environment is need to support lexical scoping, as the environment
where the function is defined (lexical scope) is different from the environment
where it's called (dynamic scope).
=#
struct Function
    lambda
    env
end

is_function(expr) = isa(expr, Function)
function_lambda(expr) = expr.lambda
function_env(expr) = expr.env
eval_function(expr) = make_lambda(lambda_params(expr.lambda), lambda_body(expr.lambda), expr.env)


#=
Lambdas are the Expr given by Meta.parse
They contain a list of parameters and a body
=#

is_lambda(expr) = isa(expr, Expr) && expr.head == :(->)
lambda_params(expr) = isa(expr.args[1], Symbol) ? [expr.args[1]] : expr.args[1].args
lambda_body(expr) = expr.args[2]

# Called when defining a lambda, we need to capture the environment to support
# lexical scoping
make_lambda(args, body, env) = Function(:($(Expr(:tuple, (args...))) -> $(body.args[2])), env)

eval_lambda(expr, env) = make_lambda(lambda_params(expr), lambda_body(expr), env)


is_call(expr) = isa(expr, Expr) && expr.head == :call
call_op(call) = call.args[1]
call_args(call) = call.args[2:end]

eval_call(call, env) =
    let f = eval(call_op(call), env)
        # If the calee is a function, extend the function's environment
        # and evaluate its body
        if is_function(f)
            let (lambda, lambda_env, args) = (function_lambda(f), function_env(f), eval_exprs(call_args(call), env))
                extend_env!(lambda_env, lambda_params(lambda), args)
                eval(lambda_body(lambda), lambda_env)
            end
        elseif is_fexpr(f)
            let (lambda, lambda_env) = (function_lambda(f), function_env(f))
                extend_env!(lambda_env, lambda_params(lambda), call_args(call))
                eval(lambda_body(lambda), lambda_env)
            end
        else
            let (args = eval_exprs(call_args(call), env))
                f(args...)
            end
        end
    end
