# Environment
struct Frame bindings end
struct Env stack end

initial_bindings::Dict{Symbol, Any} = Dict(
    :+ => +, :- => -, :* => *, :/ => /, :÷ => div, :\ => \, :% => %, :^ => ^, :√ => √,
    :! => !,
    :~ => ~, :& => &, :| => |, :⊻ => ⊻, :⊼ => ⊼, :⊽ => ⊽, :>>> => >>>, :>> => >>, :<< => <<,
    :(==) => ==, :(!=) => !=, :≠ => ≠, :(<) => <, :(<=) => <=, :≤ => ≤, :(>) => >, :(>=) => >=, :≥ => ≥,
)

empty_env() = Env([Frame(initial_bindings)])

function extend_env(env, names, values)
    new_env = Env(deepcopy(env.stack))
    new_frame = Frame(Dict())
    for (name, value) in zip(names, values)
        new_frame.bindings[name] = value
    end
    push!(new_env.stack, new_frame)
    new_env
end

extend_env!(env, name, value) = env.stack[end].bindings[name] = value

function modify_env!(env, name, value)
    for frame in reverse(env.stack)
        if haskey(frame.bindings, name)
            frame.bindings[name] = value
            return
        end
    end
    throw("Variable '$name' not found")
end

function has_name(name, env)
    for frame in reverse(env.stack)
        if haskey(frame.bindings, name)
            return true
        end
    end
    false
end

# Evaluation
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

# Self-Evaluating Expressions
is_self_evaluating(expr) = isa(expr, Int) || isa(expr, Float64) || isa(expr, Bool) || isa(expr, String) || is_lambda(expr)

# Lambda Expressions
is_lambda(expr) =
    if isa(expr, Tuple)
        let (lambda, env) = expr
            isa(lambda, Expr) && lambda.head == :(->) && isa(env, Env)
        end
    elseif isa(expr, Expr)
        expr.head == :(->)
    else
        false
    end
lambda_params(expr) =
    let (lambda, _) = expr
        isa(lambda.args[1], Symbol) ? [lambda.args[1]] : lambda.args[1].args
    end
lambda_body(expr) = expr[1].args[2]
lambda_env(expr) = expr[2]
eval_lambda(expr, env) = make_lambda(lambda_params(expr), lambda_body(expr), env)
make_lambda(args, body, env) = (:($(Expr(:tuple, (args...))) -> $(body.args[2])), env)

# Call Expressions
is_call(expr) = isa(expr, Expr) && expr.head == :call
call_op(call) = call.args[1]
call_args(call) = call.args[2:end]
eval_call(call, env) =
    let f = eval(call_op(call), env), args = eval_exprs(call_args(call), env)
        if is_lambda(f)
            let extended_env = extend_env(lambda_env(f), lambda_params(f), args)
                eval(lambda_body(f), extended_env)
            end
        else
            f(args...)
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
    throw("Variable '$name' not found")
end

# Let Expressions
is_let(expr) = isa(expr, Expr) && expr.head == :let
let_names(expr) =
    let
        extract_names(expr) = is_call(expr.args[1]) ? expr.args[1].args[1] : expr.args[1]
        if is_block(expr.args[1])
            [extract_names(expr) for expr in block_exprs(expr.args[1])]
        else
             [extract_names(expr.args[1])]
        end
    end
let_inits(expr, env) =
    let
        extract_inits(expr) =
            if is_call(expr.args[1])
                make_lambda(expr.args[1].args[2:end], expr.args[2], env)
            else
                expr.args[2]
            end
        if is_block(expr.args[1])
            [extract_inits(expr) for expr in block_exprs(expr.args[1])]
        else
            [extract_inits(expr.args[1])]
        end
    end
let_body(expr) = expr.args[2]
eval_let(expr, env) =
    eval(:($(make_lambda(let_names(expr), let_body(expr), env))($(let_inits(expr, env)...))) , env)

# Assignments/Definitions
is_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && !has_name(expr.args[1], env) && isa(expr.args[1], Symbol)
definition_name(expr) = expr.args[1]
definition_init(expr) = expr.args[2]
eval_definition(expr, env) =
    let
        init = eval(definition_init(expr), env)
        extend_env!(env, definition_name(expr), eval(definition_init(expr), env))
        init
    end

is_function_definition(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && !has_name(expr.args[1], env) && isa(expr.args[1], Expr)
function_definition_name(expr) = expr.args[1].args[1]
function_definition_init(expr, env) = make_lambda(expr.args[1].args[2:end], expr.args[2], env)
eval_function_definition(expr, env) =
    eval_definition(:($(function_definition_name(expr)) = $(function_definition_init(expr, env))), env)

is_assignment(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && has_name(expr.args[1], env) && isa(expr.args[1], Symbol)
assignment_name(expr) = expr.args[1]
assignment_init(expr) = expr.args[2]
eval_assignment(expr, env) =
    let init = eval(assignment_init(expr), env)
        modify_env!(env, assignment_name(expr), init)
        init
    end

is_function_assignment(expr, env) =
    isa(expr, Expr) && expr.head == :(=) && has_name(expr.args[1], env) && isa(expr.args[1], Expr)
function_assignment_name(expr) = expr.args[1].args[1]
function_assignment_init(expr, env) = make_lambda(expr.args[1].args[2:end], expr.args[2], env)
eval_function_assignment(expr, env) =
    eval_assignment(:($(function_assignment_name(expr)) = $(function_assignment_init(expr))), env)

# REPL
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
