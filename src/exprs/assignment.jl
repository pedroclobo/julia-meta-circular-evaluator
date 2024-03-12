is_assignment(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && isa(expr.args[1], Symbol) &&
    has_name(expr.args[1], env)

assignment_name(expr) = expr.args[1]

assignment_init(expr) = expr.args[2]

eval_assignment(expr, env) =
    let init = eval(assignment_init(expr), env)
        # Destructively modify the environment (note the !)
        modify_env!(env, assignment_name(expr), init)
        init
    end

is_function_assignment(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && isa(expr.args[1], Expr) &&
    has_name(expr.args[1], env)

function_assignment_name(expr) = expr.args[1].args[1]

function_assignment_init(expr, env) = make_lambda(expr.args[1].args[2:end], expr.args[2], env)

# A function assignment is the assignment of a lambda expression
eval_function_assignment(expr, env) =
    eval_assignment(:($(function_assignment_name(expr)) = $(function_assignment_init(expr))), env)
