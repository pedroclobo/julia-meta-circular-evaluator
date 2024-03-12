include("environment.jl")
include("exprs/assignment.jl")
include("exprs/block.jl")
include("exprs/definition.jl")
include("exprs/if-expressions.jl")
include("exprs/lambda.jl")
include("exprs/let-expression.jl")
include("exprs/name.jl")
include("exprs/operator.jl")
include("exprs/self-evaluating.jl")

function eval(expr, env)
    # Transform lambda into a tuple containing the definition environment
    if isa(expr, Expr) && expr.head == :(->)
        expr = (expr, env)
    end

    if is_self_evaluating(expr) expr
    elseif is_call(expr) eval_call(expr, env)
    elseif is_and(expr) eval_and(expr, env)
    elseif is_or(expr) eval_or(expr, env)
    elseif is_if(expr) eval_if(expr, env)
    elseif is_block(expr) eval_block(expr, env)
    elseif is_let(expr) eval_let(expr, env)
    elseif is_name(expr) eval_name(expr, env)
    elseif is_definition(expr, env) eval_definition(expr, env)
    elseif is_function_definition(expr, env) eval_function_definition(expr, env)
    elseif is_assignment(expr, env) eval_assignment(expr, env)
    elseif is_function_assignment(expr, env) eval_function_assignment(expr, env)
    elseif is_lambda(expr) eval_lambda(expr, env)
    else throw("Not implemented (EVAL)")
    end
end

eval_exprs(exprs, env) = map(expr -> eval(expr, env), exprs)