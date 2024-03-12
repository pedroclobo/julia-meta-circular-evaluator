# And and Or Expressions
is_and(expr) = isa(expr, Expr) && expr.head == :(&&)
and_lvalue(and) = and.args[1]
and_rvalue(and) = and.args[2]
eval_and(and, env) = eval(and_lvalue(and), env) && eval(and_rvalue(and), env)

is_or(expr) = isa(expr, Expr) && expr.head == :(||)
or_lvalue(or) = or.args[1]
or_rvalue(or) = or.args[2]
eval_or(or, env) = eval(or_lvalue(or), env) || eval(or_rvalue(or), env)
