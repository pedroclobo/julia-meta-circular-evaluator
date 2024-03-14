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
)

empty_env() = Env([Frame(initial_bindings)])

Base.copy(env::Env) = Env(copy(env.stack))

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
