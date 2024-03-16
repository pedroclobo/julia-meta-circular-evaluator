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

is_global_assignment(expr, env) = isa(expr, Expr) && expr.head == :global &&
    isa(expr.args[1], Expr) && expr.args[1].head == :(=) && (
        (isa(expr.args[1].args[1], Symbol) && has_name_in_global_frame(expr.args[1].args[1], env)) ||
        ((isa(expr.args[1].args[1], Expr) && has_name_in_global_frame(expr.args[1].args[1].args[1], env)))
    )

global_assignment_name(expr) = assignment_name(expr.args[1])

global_assignment_init(expr, env) = assignment_init(expr.args[1], env)

eval_global_assignment(expr, env) =
    begin
        let init = eval(global_assignment_init(expr, env), env)
            # Destructively update a binding to the global frame of the environment
            # (note the !)
            add_binding_to_global_frame!(env, global_assignment_name(expr), init)
            init
        end
    end 
