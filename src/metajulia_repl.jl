function evaluate(expr)
    if self_evaluating(expr)
        expr
    elseif is_call(expr)
        evaluate_call(expr)
    else
        throw("Not implemented")
    end
end

function self_evaluating(expr)
    isa(expr, Int) || isa(expr, Bool) || isa(expr, String)
end

function is_call(expr)
    isa(expr, Expr) && expr.head == :call
end

function evaluate_call(expr)
    func = expr.args[1]
    args = map(evaluate, expr.args[2:end])
    if func == :+
        sum(args)
    elseif func == :*
        prod(args)
    elseif func == :>
        args[1] > args[2]
    elseif func == :<
        args[1] < args[2]
    else
        throw("Not implemented (EVALUATE_CALL)")
    end
end

function metajulia_repl()
    while true
        print(">> ")
        println(evaluate(Meta.parse(readline())))
    end
end
