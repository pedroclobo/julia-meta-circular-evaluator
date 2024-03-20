is_block(expr) = isa(expr, Expr) && expr.head == :block

# Filter the annoying Julia LineNumberNode
block_exprs(block) = filter(x -> !isa(x, LineNumberNode), (block.args))

# Evaluate all the expressions and return the last one
eval_block(block, env) = (exprs = map((arg) -> eval(arg, env), block_exprs(block)); last(exprs))

# Return a block node without the LineNumberNodes
clean_block(block) = Expr(:block, block_exprs(block)...)
