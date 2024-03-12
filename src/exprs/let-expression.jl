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
Evaluate let as an anonymous function call

let x = 1 + 2, y = 2 * 3
    x - y
end

it turned into

((x, y) -> (x - y))(1 + 2, 2 * 3)
=#
eval_let(expr, env) =
    eval(:($(make_lambda(let_names(expr), let_body(expr), env))($(let_inits(expr, env)...))) , env)
