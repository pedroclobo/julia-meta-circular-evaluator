#=
if and elseif expressions can be treated equally as the parser
does the job for us.
=#
is_if(expr) = isa(expr, Expr) && (expr.head == :if || expr.head == :elseif)

if_cond(expr) = expr.args[1]

if_then(expr) = expr.args[2]

if_else(expr) = expr.args[3]

eval_if(expr, env) = eval(if_cond(expr), env) ? eval(if_then(expr), env) : eval(if_else(expr), env)
