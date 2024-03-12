is_lambda(expr) =
    if isa(expr, Tuple)
        let (lambda, env) = expr
            isa(lambda, Expr) && lambda.head == :(->) && isa(env, Env)
        end
    elseif isa(expr, Expr)
        expr.head == :(->)
    else
        false
    end
lambda_params(expr) =
    let (lambda, _) = expr
        isa(lambda.args[1], Symbol) ? [lambda.args[1]] : lambda.args[1].args
    end
lambda_body(expr) = expr[1].args[2]
lambda_env(expr) = expr[2]
eval_lambda(expr, env) = make_lambda(lambda_params(expr), lambda_body(expr), env)
make_lambda(args, body, env) = (:($(Expr(:tuple, (args...))) -> $(body.args[2])), env)

# Call Expressions
is_call(expr) = isa(expr, Expr) && expr.head == :call
call_op(call) = call.args[1]
call_args(call) = call.args[2:end]
eval_call(call, env) =
    let f = eval(call_op(call), env), args = eval_exprs(call_args(call), env)
        if is_lambda(f)
            let extended_env = extend_env(lambda_env(f), lambda_params(f), args)
                eval(lambda_body(f), extended_env)
            end
        else
            f(args...)
        end
    end
