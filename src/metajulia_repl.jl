include("evaluator.jl")

function metajulia_repl()
    while true
        print(">> ")
        expr = readline()
        parsed_expr = Meta.parse(raise=false, expr)
        while parsed_expr.head == :incomplete || parsed_expr.head == :error
            expr = string(expr, '\n', readline())
            parsed_expr = Meta.parse(raise=false, expr)
        end
        println(eval(Meta.parse(expr), empty_env()))
    end
end
