struct Fexpr
    lambda
    env
end

is_fexpr(expr) = isa(expr, Fexpr)
fexpr_lambda(expr) = expr.lambda
fexpr_env(expr) = expr.env
eval_fexpr(expr, env) = make_fexpr(lambda_params(fexpr_lambda(expr)), lambda_body(fexpr_lambda(expr)), env)

is_fexpr_assignment(expr, env) =
    isa(expr, Expr) && expr.head == :(:=) &&
    isa(expr.args[1], Expr) && has_name_in_frame(expr.args[1].args[1], env)

fexpr_assignment_name(expr) = expr.args[1].args[1]

fexpr_assignment_init(expr, env) = make_fexpr(expr.args[1].args[2:end], expr.args[2], env)

make_fexpr(args, body, env) = Fexpr(:($(Expr(:tuple, (args...))) -> $(body)), env)

eval_fexpr_assignment(expr, env) =
    let init = eval(fexpr_assignment_init(expr, env), env)
        # Destructively add a new binding to the last frame of the environment
        # (note the !)
        add_binding!(env, fexpr_assignment_name(expr), init)
        init
    end

is_fexpr_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(:=) &&
    isa(expr.args[1], Expr) && !has_name_in_frame(expr.args[1].args[1], env)

fexpr_definition_name(expr) = expr.args[1].args[1]

fexpr_definition_init(expr, env) = make_fexpr(expr.args[1].args[2:end], expr.args[2], env)

eval_fexpr_definition(expr, env) =
    let init = eval(fexpr_definition_init(expr, env), env)
        # Destructively add a new binding to the last frame of the environment
        # (note the !)
        add_binding!(env, fexpr_definition_name(expr), init)
        init
    end