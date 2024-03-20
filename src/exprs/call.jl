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
        elseif is_macro(f)
            let (lambda, lambda_env) = (macro_lambda(f), macro_env(f))
                extend_env!(lambda_env, lambda_params(lambda), call_args(call))
                eval(eval(lambda_body(lambda), lambda_env), env)
            end
        else
            let (args = eval_exprs(call_args(call), env))
                f(args...)
            end
        end
    end