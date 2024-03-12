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
