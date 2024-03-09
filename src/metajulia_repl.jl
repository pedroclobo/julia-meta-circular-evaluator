# Environment
struct Frame bindings end
struct Env stack end

empty_env() = Env([])

function extend_env(env, names, values)
    new_env = Env(deepcopy(env.stack))
    new_frame = Frame(Dict())
    for (name, value) in zip(names, values)
        new_frame.bindings[name] = value
    end
    push!(new_env.stack, new_frame)
    new_env
end

# Evaluation
function eval(expr, env)
    if is_self_evaluating(expr) expr
    elseif is_call(expr) eval_call(expr, env)
    elseif is_and(expr) eval_and(expr, env)
    elseif is_or(expr) eval_or(expr, env)
    elseif is_if(expr) eval_if(expr, env)
    elseif is_block(expr) eval_block(expr, env)
    elseif is_let(expr) eval_let(expr, env)
    elseif is_name(expr) eval_name(expr, env)
    else throw("Not implemented (EVAL)")
    end
end

eval_exprs(exprs, env) = map(expr -> eval(expr, env), exprs)

# Self-Evaluating Expressions
is_self_evaluating(expr) = isa(expr, Int) || isa(expr, Bool) || isa(expr, String)

# Call Expressions
is_call(expr) = isa(expr, Expr) && expr.head == :call
call_op(call) = call.args[1]
call_args(call) = call.args[2:end]
function eval_call(call, env)
    func = call_op(call)
    args = eval_exprs(call_args(call), env)

    if func == :+ sum(args)
    elseif func == :* prod(args)
    elseif func == :/ args[1] / args[2]
    elseif func == :> args[1] > args[2]
    elseif func == :< args[1] < args[2]
    else throw("Not implemented (EVAL_CALL)")
    end
end

# And and Or Expressions
is_and(expr) = isa(expr, Expr) && expr.head == :(&&)
and_lvalue(and) = and.args[1]
and_rvalue(and) = and.args[2]
eval_and(and, env) = eval(and_lvalue(and), env) && eval(and_rvalue(and), env)

is_or(expr) = isa(expr, Expr) && expr.head == :(||)
or_lvalue(or) = or.args[1]
or_rvalue(or) = or.args[2]
eval_or(or, env) = eval(or_lvalue(or), env) || eval(or_rvalue(or), env)

# If Expressions
is_if(expr) = isa(expr, Expr) && (expr.head == :if || expr.head == :elseif)
if_cond(expr) = expr.args[1]
if_then(expr) = expr.args[2]
if_else(expr) = expr.args[3]
eval_if(expr, env) = eval(if_cond(expr), env) ? eval(if_then(expr), env) : eval(if_else(expr), env)

# Blocks
is_block(expr) = isa(expr, Expr) && expr.head == :block
block_exprs(block) = filter(x -> !isa(x, LineNumberNode), (block.args))
eval_block(block, env) = (exprs = map((arg) -> eval(arg, env), block_exprs(block)); last(exprs))

# Names
is_name(expr) = isa(expr, Symbol)
function eval_name(name, env)
    for frame in reverse(env.stack)
        if haskey(frame.bindings, name)
            return frame.bindings[name]
        end
    end
    throw(ArgumentError("Variable '$name' not found"))
end

# Let Expressions
is_let(expr) = isa(expr, Expr) && expr.head == :let
let_names(expr) = is_block(expr.args[1]) ?  [expr.args[1] for expr in block_exprs(expr.args[1])] : [expr.args[1].args[1]]
let_inits(expr) = is_block(expr.args[1]) ?  [expr.args[2] for expr in block_exprs(expr.args[1])] : [expr.args[1].args[2]]
let_body(expr) = expr.args[2]
function eval_let(expr, env)
    values = eval_exprs(let_inits(expr), env)
    env = extend_env(env, let_names(expr), values)
    eval(let_body(expr), env)
end

# REPL
function metajulia_repl()
    while true
        print(">> ")
        println(eval(Meta.parse(readline()), empty_env()))
    end
end
