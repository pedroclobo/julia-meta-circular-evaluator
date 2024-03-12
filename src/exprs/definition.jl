# Assignments/Definitions
is_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && !has_name(expr.args[1], env) && isa(expr.args[1], Symbol)
definition_name(expr) = expr.args[1]
definition_init(expr) = expr.args[2]
eval_definition(expr, env) =
    let
        init = eval(definition_init(expr), env)
        extend_env!(env, definition_name(expr), eval(definition_init(expr), env))
        init
    end

is_function_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && !has_name(expr.args[1], env) && isa(expr.args[1], Expr)
function_definition_name(expr) = expr.args[1].args[1]
function_definition_init(expr, env) = make_lambda(expr.args[1].args[2:end], expr.args[2], env)
eval_function_definition(expr, env) =
    eval_definition(:($(function_definition_name(expr)) = $(function_definition_init(expr, env))), env)
