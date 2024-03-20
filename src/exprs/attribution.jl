is_variable_attribution(expr) =
    isa(expr, Expr) && expr.head == :(=) &&
    isa(expr.args[1], Symbol)

is_function_attribution(expr) =
    isa(expr, Expr) && expr.head == :(=) &&
    isa(expr.args[1], Expr)

is_fexpr_attribution(expr) =
    isa(expr, Expr) && expr.head == :(:=) &&
    isa(expr.args[1], Expr)

is_macro_attribution(expr) =
    isa(expr, Expr) && expr.head == :($=) &&
    isa(expr.args[1], Expr)

name(expr, env) =
    begin
        local_name(expr) =
            if is_variable_attribution(expr)
                expr.args[1]
            else
                expr.args[1].args[1]
            end

        if is_local_definition(expr, env) || is_local_assignment(expr, env)
            local_name(expr)
        elseif is_global_definition(expr, env) || is_global_assignment(expr, env)
            local_name(expr.args[1])
        end
    end

init(expr, env) =
    begin
        local_init(expr, env) =
            if is_fexpr_attribution(expr)
                make_fexpr(expr.args[1].args[2:end], expr.args[2], env)
            elseif is_macro_attribution(expr)
                make_macro(expr.args[1].args[2:end], expr.args[2], env)
            elseif is_call(expr.args[1])
                make_lambda(expr.args[1].args[2:end], expr.args[2], env)
            else
                expr.args[2]
            end

        if is_local_definition(expr, env) || is_local_assignment(expr, env)
            local_init(expr, env)
        elseif is_global_definition(expr, env) || is_global_assignment(expr, env)
            local_init(expr.args[1], env)
        end
    end

is_definition(expr, env) = is_local_definition(expr, env) || is_global_definition(expr, env)

is_local_definition(expr, env) =
    (is_variable_attribution(expr) && !has_name_in_frame(expr.args[1], env)) ||
    (is_function_attribution(expr) && !has_name_in_frame(expr.args[1].args[1], env)) ||
    (is_fexpr_attribution(expr) && !has_name_in_frame(expr.args[1].args[1], env)) ||
    (is_macro_attribution(expr) && !has_name_in_frame(expr.args[1].args[1], env))

is_global_definition(expr, env) =
    isa(expr, Expr) && expr.head == :global &&
        (is_variable_attribution(expr.args[1]) && !has_name_in_global_frame(expr.args[1].args[1], env)) ||
        (is_function_attribution(expr.args[1]) && !has_name_in_global_frame(expr.args[1].args[1].args[1], env)) ||
        (is_fexpr_attribution(expr.args[1]) && !has_name_in_global_frame(expr.args[1].args[1].args[1], env)) ||
        (is_macro_attribution(expr) && !has_name_in_frame(expr.args[1].args[1].args[1], env))

eval_definition(expr, env) =
    begin
        let init = eval(init(expr, env), env)
            if is_local_definition(expr, env)
                add_binding!(env, name(expr, env), init)
            else
                add_binding_to_global_frame!(env, name(expr, env), init)
            end
            init
        end
    end

is_assignment(expr, env) = is_local_assignment(expr, env) || is_global_assignment(expr, env)

is_local_assignment(expr, env) =
    (is_variable_attribution(expr) && has_name_in_frame(expr.args[1], env)) ||
    (is_function_attribution(expr) && has_name_in_frame(expr.args[1].args[1], env)) ||
    (is_fexpr_attribution(expr) && has_name_in_frame(expr.args[1].args[1], env)) ||
    (is_macro_attribution(expr) && has_name_in_frame(expr.args[1].args[1], env))

is_global_assignment(expr, env) =
    isa(expr, Expr) && expr.head == :global &&
        (is_variable_attribution(expr.args[1]) && has_name_in_global_frame(expr.args[1].args[1], env)) ||
        (is_function_attribution(expr.args[1]) && has_name_in_global_frame(expr.args[1].args[1].args[1], env)) ||
        (is_fexpr_attribution(expr.args[1]) && has_name_in_global_frame(expr.args[1].args[1].args[1], env)) ||
        (is_macro_attribution(expr.args[1]) && has_name_in_global_frame(expr.args[1].args[1].args[1], env))

eval_assignment(expr, env) = eval_definition(expr, env)
