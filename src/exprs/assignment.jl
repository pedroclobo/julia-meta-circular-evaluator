is_assignment(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && (
        (isa(expr.args[1], Symbol) && has_name_in_frame(expr.args[1], env)) ||
        ((isa(expr.args[1], Expr) && has_name_in_frame(expr.args[1].args[1], env)))
    )

assignment_name(expr) = is_call(expr.args[1]) ? expr.args[1].args[1] : expr.args[1]

assignment_init(expr, env) = is_call(expr.args[1]) ?
                        make_lambda(expr.args[1].args[2:end], expr.args[2], env) :
                        expr.args[2]

eval_assignment(expr, env) =
    let init = eval(assignment_init(expr, env), env)
        # Destructively add a new binding to the last frame of the environment
        # (note the !)
        add_binding!(env, assignment_name(expr), init)
        init
    end
