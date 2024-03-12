is_let(expr) = isa(expr, Expr) && expr.head == :let
let_names(expr) =
    let
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
eval_let(expr, env) =
    eval(:($(make_lambda(let_names(expr), let_body(expr), env))($(let_inits(expr, env)...))) , env)
