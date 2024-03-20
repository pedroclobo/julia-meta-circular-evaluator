include("evaluator.jl")

is_valid_expr(expr) =
    !isa(expr, Expr) ||
    (isa(expr, Expr) && expr.head != :incomplete && expr.head != :error)

metajulia_eval(expr) = eval(expr, empty_env())

print_expr(expr) =
    begin
        if isa(expr, String)
            println("\"$expr\"")
        elseif isa(expr, Symbol)
            println(":$expr")
        elseif isa(expr, Expr)
            println(":($expr)")
        elseif is_function(expr)
            println("<function>")
        elseif is_fexpr(expr)
            println("<fexpr>")
        elseif is_macro(expr)
            println("<macro>")
        else
            println(expr)
        end
    end

function metajulia_repl()
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
end
