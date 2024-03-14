is_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && isa(expr.args[1], Symbol) &&
    !has_name_in_frame(expr.args[1], env)

definition_name(expr) = expr.args[1]

definition_init(expr) = expr.args[2]

eval_definition(expr, env) =
    let init = eval(definition_init(expr), env)
        # Destructively add a new binding to the last frame of the environment
        # (note the !)
        add_binding!(env, definition_name(expr), init)
        init
    end

is_function_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && isa(expr.args[1], Expr) &&
    !has_name(expr.args[1], env)

function_definition_name(expr) = expr.args[1].args[1]

function_definition_init(expr, env) = make_lambda(expr.args[1].args[2:end], expr.args[2], env)

# A function definition is the definition of a lambda expression
eval_function_definition(expr, env) =
    eval_definition(:($(function_definition_name(expr)) = $(function_definition_init(expr, env))), env)
