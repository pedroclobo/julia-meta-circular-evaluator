function evaluate(expr)
    if self_evaluating(expr)
        expr
    elseif is_call(expr)
        evaluate_call(expr)
    elseif is_and(expr)
        evaluate_and(expr) 
    elseif is_or(expr)
        evaluate_or(expr)
    elseif is_if(expr)
        evaluate_if(expr)
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

function is_and(expr)
    isa(expr, Expr) && expr.head == :(&&)
end

function is_or(expr)
    isa(expr, Expr) && expr.head == :(||)
end

function is_if(expr)
    isa(expr, Expr) && expr.head == :if
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

function evaluate_and(expr)
    leftExpr = evaluate(expr.args[1])
    rightExpr = evaluate(expr.args[2])
    leftExpr && rightExpr
end

function evaluate_or(expr)
    leftExpr = evaluate(expr.args[1])
    rightExpr = evaluate(expr.args[2])
    leftExpr || rightExpr
end

function evaluate_if(expr)
    condition = evaluate(expr.args[1])
    condition ? evaluate(expr.args[2]) : evaluate(expr.args[3])
end

function metajulia_repl()
    while true
        print(">> ")
        println(evaluate(Meta.parse(readline())))
    end
end
