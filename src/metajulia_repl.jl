function evaluate(expr)
    if is_self_evaluating(expr)
        expr
    elseif is_call(expr)
        evaluate_call(expr)
    elseif is_and(expr)
        evaluate_and(expr)
    elseif is_or(expr)
        evaluate_or(expr)
    elseif is_if(expr)
        evaluate_if(expr)
    elseif is_block(expr)
        evaluate_block(expr)
    else
        throw("Not implemented")
    end
end

is_self_evaluating(expr) = isa(expr, Int) || isa(expr, Bool) || isa(expr, String)

is_call(expr) = isa(expr, Expr) && expr.head == :call
call_operator(expr) = expr.args[1]
call_arguments(expr) = expr.args[2:end]

function evaluate_call(expr)
    func = call_operator(expr)
    args = map(evaluate, call_arguments(expr))
    if func == :+
        sum(args)
    elseif func == :*
        prod(args)
    elseif func == :/
        args[1] / args[2]
    elseif func == :>
        args[1] > args[2]
    elseif func == :<
        args[1] < args[2]
    else
        throw("Not implemented (EVALUATE_CALL)")
    end
end

is_and(expr) = isa(expr, Expr) && expr.head == :(&&)
and_lvalue(expr) = expr.args[1]
and_rvalue(expr) = expr.args[2]
evaluate_and(expr) = evaluate(and_lvalue(expr)) && evaluate(and_rvalue(expr))

is_or(expr) = isa(expr, Expr) && expr.head == :(||)
or_lvalue(expr) = expr.args[1]
or_rvalue(expr) = expr.args[2]
evaluate_or(expr) = evaluate(or_lvalue(expr)) || evaluate(or_rvalue(expr))

is_if(expr) = isa(expr, Expr) && expr.head == :if
if_condition(expr) = expr.args[1]
if_consequence(expr) = expr.args[2]
if_alternative(expr) = expr.args[3]
evaluate_if(expr) = evaluate(if_condition(expr)) ? evaluate(if_consequence(expr)) : evaluate(if_alternative(expr))

is_block(expr) = isa(expr, Expr) && expr.head == :block
block_expressions(expr) = filter(x -> !isa(x, LineNumberNode), (expr.args))
evaluate_block(expr) = (exprs = map(evaluate, block_expressions(expr)); last(exprs))

function metajulia_repl()
    while true
        print(">> ")
        println(evaluate(Meta.parse(readline())))
    end
end
