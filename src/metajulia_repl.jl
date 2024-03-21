include("evaluator.jl")

is_valid_expr(expr) =
    !isa(expr, Expr) ||
    (isa(expr, Expr) && expr.head != :incomplete && expr.head != :error)

metajulia_eval(expr) = eval(expr, empty_env())

metajulia_repl() =
    while true
        print(">> ")
        expr = readline()
        parsed_expr = Meta.parse(raise=false, expr)
        while !is_valid_expr(parsed_expr)
            expr = string(expr, '\n', readline())
            parsed_expr = Meta.parse(raise=false, expr)
        end
        expr = eval(Meta.parse(expr), empty_env())
        show(expr)
        println()
    end
