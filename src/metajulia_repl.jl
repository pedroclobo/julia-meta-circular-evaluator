function evaluate(expr, env)
    if is_self_evaluating(expr)
        expr
    elseif is_call(expr)
        evaluate_call(expr, env)
    elseif is_and(expr)
        evaluate_and(expr, env)
    elseif is_or(expr)
        evaluate_or(expr, env)
    elseif is_if(expr)
        evaluate_if(expr, env)
    elseif is_block(expr)
        evaluate_block(expr, env)
    elseif is_let(expr)
        evaluate_let(expr, env)
    elseif is_name(expr)
        evaluate_name(expr, env)
    else
        throw("Not implemented")
    end
end

evaluate_exprs(exprs, env) = map(expr -> evaluate(expr, env), exprs)

is_self_evaluating(expr) = isa(expr, Int) || isa(expr, Bool) || isa(expr, String)

is_call(expr) = isa(expr, Expr) && expr.head == :call
call_operator(expr) = expr.args[1]
call_arguments(expr) = expr.args[2:end]

function evaluate_call(expr, env)
    func = call_operator(expr)
    args = evaluate_exprs(call_arguments(expr), env)
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
evaluate_and(expr, env) = evaluate(and_lvalue(expr), env) && evaluate(and_rvalue(expr), env)

is_or(expr) = isa(expr, Expr) && expr.head == :(||)
or_lvalue(expr) = expr.args[1]
or_rvalue(expr) = expr.args[2]
evaluate_or(expr, env) = evaluate(or_lvalue(expr), env) || evaluate(or_rvalue(expr), env)

is_if(expr) = isa(expr, Expr) && (expr.head == :if || expr.head == :elseif)
if_condition(expr) = expr.args[1]
if_consequence(expr) = expr.args[2]
if_alternative(expr) = expr.args[3]
evaluate_if(expr, env) = evaluate(if_condition(expr), env) ? evaluate(if_consequence(expr), env) : evaluate(if_alternative(expr), env)

is_block(expr) = isa(expr, Expr) && expr.head == :block
block_expressions(expr) = filter(x -> !isa(x, LineNumberNode), (expr.args))
evaluate_block(expr, env) = (exprs = map((arg) -> evaluate(arg, env), block_expressions(expr)); last(exprs))

is_name(expr) = isa(expr, Symbol)
function evaluate_name(name, env)
  for frame in reverse(env.stack)
    if haskey(frame.bindings, name)
      return frame.bindings[name]
    end
  end
  throw(ArgumentError("Variable '$name' not found"))
end

is_let(expr) = isa(expr, Expr) && expr.head == :let
function let_names(expr)
    res = []
    names = expr.args[1] # names
    if is_block(names)
        names = block_expressions(names)
        for i in 1:1:length(names)
            res = [res; names[i].args[1]]
        end
    else
        res = [res; names.args[1]]
    end
    res
end

function let_inits(expr)
    res = []
    names = expr.args[1]
    if is_block(names)
        names = block_expressions(names)
        for i in 1:1:length(names)
            res = [res; names[i].args[2]]
        end
    else
        res = [names.args[2]]
    end
    res
end

let_body(expr) = expr.args[2]

function evaluate_let(expr, env)
    values = evaluate_exprs(let_inits(expr), env)
    env = add_binding(env, let_names(expr), values)
    evaluate(let_body(expr), env)
end

struct Frame
  bindings
end

struct Env
  stack
end

empty_env() = Env([])

function add_binding(env, names, values)
  new_frame = Frame(Dict())
  for (name, value) in zip(names, values)
    new_frame.bindings[name] = value
  end
  push!(env.stack, new_frame)
  env
end

function metajulia_repl()
    while true
        print(">> ")
        println(evaluate(Meta.parse(readline()), empty_env()))
    end
end
