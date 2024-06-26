is_quasiquote(expr) = isa(expr, QuoteNode) || (isa(expr, Expr) && expr.head == :quote)

quasiquoted_form(expr) = isa(expr, QuoteNode) ? expr.value : expr.args[1]

eval_quasiquote(expr, env) = expand(quasiquoted_form(expr), env)

is_unquote(expr) = isa(expr, Expr) && expr.head == :$

unquote_form(expr) = expr.args[1]

expand(form, env) =
    if is_unquote(form)
        eval(unquote_form(form), env)
    elseif is_quasiquote(form)
        expand(quasiquoted_form(form), env)
    elseif isa(form, Expr)
        form.args = map(i -> expand(i, env), form.args)
        form
    else
        form
    end
