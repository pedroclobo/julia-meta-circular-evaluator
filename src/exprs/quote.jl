is_quote(expr) = isa(expr, QuoteNode) || (isa(expr, Expr) && expr.head == :quote)

quoted_form(expr) = isa(expr, QuoteNode) ? expr.value : expr.args[1]

eval_quote(expr, env) = quoted_form(expr)

is_dollar(expr) = isa(expr, Expr) && expr.head == :$

dollar_expr(expr) = expr.args[1]

eval_dollar(expr, env) = eval(dollar_expr(expr), env)

