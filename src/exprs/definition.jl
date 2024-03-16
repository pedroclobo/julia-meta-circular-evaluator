is_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && (
        (isa(expr.args[1], Symbol) && !has_name_in_frame(expr.args[1], env)) ||
        ((isa(expr.args[1], Expr) && !has_name_in_frame(expr.args[1].args[1], env)))
    )

definition_name(expr) = is_call(expr.args[1]) ? expr.args[1].args[1] : expr.args[1]

definition_init(expr, env) = is_call(expr.args[1]) ?
                             make_lambda(expr.args[1].args[2:end], expr.args[2], env) :
                             expr.args[2]

eval_definition(expr, env) =
    begin
        let init = eval(definition_init(expr, env), env)
            # Destructively add a new binding to the last frame of the environment
            # (note the !)
            add_binding!(env, definition_name(expr), init)
            init
        end
    end


is_global_definition(expr, env) = 
    isa(expr, Expr) && expr.head == :global &&
    isa(expr.args[1], Expr) && expr.args[1].head == :(=) && (
        (isa(expr.args[1].args[1], Symbol) && !has_name_in_global_frame(expr.args[1].args[1], env)) ||
        ((isa(expr.args[1].args[1], Expr) && !has_name_in_global_frame(expr.args[1].args[1].args[1], env)))
    )

global_definition_name(expr) = definition_name(expr.args[1])

global_definition_init(expr, env) = definition_init(expr.args[1], env)

eval_global_definition(expr, env) =
    begin
        let init = eval(global_definition_init(expr, env), env)
            # Destructively add a new binding to the global frame of the environment
            # (note the !)
            add_binding_to_global_frame!(env, global_definition_name(expr), init)
            init
        end
    end 