include("evaluator.jl")

is_valid_expr(expr) =
    !isa(expr, Expr) ||
    (isa(expr, Expr) && expr.head != :incomplete && expr.head != :error)

metajulia_eval(expr) = eval(expr, empty_env())

print_expr(expr) =
    if isa(expr, Expr)
        println(":($expr)")
    elseif isa(expr, String)
        println("\"$expr\"")
    elseif isa(expr, Symbol)
        println(":$expr")
    else
        println(expr)
    end

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
        print_expr(expr)
    end
