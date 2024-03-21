is_let(expr) = isa(expr, Expr) && expr.head == :let

let_names(expr) =
    let
        # If the name is a call, then it's a function definition
        extract_names(expr) = is_call(expr.args[1]) ? expr.args[1].args[1] : expr.args[1]

        if is_block(expr.args[1])
            [extract_names(expr) for expr in block_exprs(expr.args[1])]
        else
             [extract_names(expr.args[1])]
        end
    end

let_inits(expr, env) =
    let
        extract_inits(expr) =
            # If the first argument is a call, then it's a function definition
            # The right side in transformed into a lambda expression
            if is_call(expr.args[1])
                make_lambda(expr.args[1].args[2:end], expr.args[2], env)
            else
                expr.args[2]
            end

        if is_block(expr.args[1])
            [extract_inits(expr) for expr in block_exprs(expr.args[1])]
        else
            [extract_inits(expr.args[1])]
        end
    end

let_body(expr) = expr.args[2]

#=
The following is done to support recursive function calls in lexical scope:

1. Create a new empty frame.
2. Initialize the let inits in the new frame.
3. Bind the names to the inits in the new frame.
=#
eval_let(expr, env) =
    let extended_env = extend_env(env, [], [])
        #=
        In Julia,
        `let a = 1, b = a
             b
         end`
        should return 1
        =#
        for (name, init) in zip(let_names(expr), let_inits(expr, extended_env))
            add_binding!(extended_env, name, eval(init, extended_env))
        end
        eval(let_body(expr), extended_env)
    end
