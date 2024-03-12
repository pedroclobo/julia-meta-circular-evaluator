is_name(expr) = isa(expr, Symbol)
function eval_name(name, env)
    for frame in reverse(env.stack)
        if haskey(frame.bindings, name)
            return frame.bindings[name]
        end
    end
    throw("Variable '$name' not found")
end
