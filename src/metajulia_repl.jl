include("evaluator.jl")

is_valid_expr(expr) =
    !isa(expr, Expr) ||
    (isa(expr, Expr) && expr.head != :incomplete && expr.head != :error)

function metajulia_repl()
    while true
        print(">> ")
        expr = readline()
        parsed_expr = Meta.parse(raise=false, expr)
        while !is_valid_expr(parsed_expr)
            expr = string(expr, '\n', readline())
            parsed_expr = Meta.parse(raise=false, expr)
        end
        println(eval(Meta.parse(expr), empty_env()))
    end
end
