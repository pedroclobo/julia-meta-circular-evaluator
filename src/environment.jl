struct Frame bindings end
struct Env stack end

#=
Empty environment bindings

This includes the basic arithmetic operations, logical operations,
and comparison operations.
=#

initial_bindings::Dict{Symbol, Any} = Dict(
    :+ => +, :- => -, :* => *, :/ => /, :÷ => div, :\ => \, :% => %, :^ => ^, :√ => √,
    :! => !,
    :~ => ~, :& => &, :| => |, :⊻ => ⊻, :⊼ => ⊼, :⊽ => ⊽, :>>> => >>>, :>> => >>, :<< => <<,
    :(==) => ==, :(!=) => !=, :≠ => ≠, :(<) => <, :(<=) => <=, :≤ => ≤, :(>) => >, :(>=) => >=, :≥ => ≥,
    :(println) => println, :(print) => print,
    :(gensym) => gensym
)

empty_env() = Env([Frame(initial_bindings)])

Base.copy(env::Env) = Env(copy(env.stack))

# Extend the environment by creating a new frame where the new bindings are added.
extend_env(env, names, values) =
    begin
        new_env = copy(env)
        new_frame = Frame(Dict())
        for (name, value) in zip(names, values)
            new_frame.bindings[name] = value
        end
        push!(new_env.stack, new_frame)
        new_env
    end

# Destructively extend the environment by creating a new frame where
# the new bindings are added. Note the ! in the function name.
extend_env!(env, names, values) =
    begin
        new_frame = Frame(Dict())
        for (name, value) in zip(names, values)
            new_frame.bindings[name] = value
        end
        push!(env.stack, new_frame)
    end

# Destructively modify the environment by adding/replacing a binding.
# Note the ! in the function name.
add_binding!(env, name, value) = env.stack[end].bindings[name] = value

# Destructively modify the environment by adding/replacing a binding to the global frame.
# Note the ! in the function name.
add_binding_to_global_frame!(env, name, value) = env.stack[1].bindings[name] = value

# Search for a binding in the environment
has_name(name, env) =
    begin
        for frame in reverse(env.stack)
            if haskey(frame.bindings, name)
                return true
            end
        end
        false
    end

# Search for a binding in the current frame
has_name_in_frame(name, env) = haskey(env.stack[end].bindings, name)

# Search for a binding in the global frame
has_name_in_global_frame(name, env) = haskey(env.stack[1].bindings, name)



