is_block(expr) = isa(expr, Expr) && expr.head == :block
block_exprs(block) = filter(x -> !isa(x, LineNumberNode), (block.args))
eval_block(block, env) = (exprs = map((arg) -> eval(arg, env), block_exprs(block)); last(exprs))
