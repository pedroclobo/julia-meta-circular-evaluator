include("evaluator.jl")

function test(input, expected)
    try
        evaluated = eval(Meta.parse(input), empty_env())
        @assert evaluated == expected
    catch e
        println("FAILED\n$input")
        rethrow(e)
    end
end

# Self-Evaluating Expressions
test("1", 1)
test("\"Hello World\"", "Hello World")
test("true", true)
test("false", false)

# Arithmetic Expressions
test("+1", 1)
test("-1", -1)
test("1 + 2", 3)
test("1 - 2", -1)
test("1 * 2", 2)
test("1 / 2", 0.5)
test("3 ÷ 2", 1)
test("4 $(\) 2", 0.5)
test("2 ^ 3", 8)
test("4 % 3", 1)
test("(2 + 3) * (4 + 5)", 45)
test("2 + 3 * 4 + 5", 19)
test("√ 4", 2)

# Boolean Operators
test("!true", false)
test("!false", true)
test("false && true", false)
test("false || true", true)
test("true || a", true)
test("false && a", false)
test("3 > 2 && 3 < 2", false)
test("3 > 2 || 3 < 2", true)

# Bitwise Operators
test("~123", -124)
test("123 & 234", 106)
test("123 | 234", 251)
test("123 ⊻ 234", 145)
test("123 ⊼ 123", -124)
test("123 ⊽ 124", -128)
test("123 >>> 2", 30)
test("123 >> 2", 30)
test("123 << 2", 492)

# Numeric Comparisons
test("1 == 1", true)
test("1 == 2", false)
test("1 != 2", true)
test("1 == 1.0", true)
test("1 ≠ 1", false)
test("1 < 2", true)
test("1.0 > 3", false)
test("1 >= 1.0", true)
test("1 ≥ 1.0", true)
test("-1 <= 1", true)
test("-1 <= -1", true)
test("-1 <= -2", false)
test("1 ≤ 2", true)
test("3 < -0.5", false)
test("3 > 2", true)
test("3 < 2", false)

# If Expressions
test("3 > 2 ? 1 : 0", 1)
test("3 < 2 ? 1 : 0", 0)
test("""
if 3 > 2
    1
else
    0
end""", 1)
test("""
if 3 < 2
    1
elseif 2 > 3
    2
else
    0
end""", 0)
test("""
if 3 < 2
    1
elseif 2 < 3
    2
else
    0
end""", 2)
test("""
if 1 < 2
    1
elseif 3 < 4
    2
else
    0
end""", 1)

# Blocks
test("(1+2; 2*3; 3/4)", 0.75)
test("begin 1+2; 2*3; 3/4 end", 0.75)
test("""
begin
    1+2
    2*3
    3/4
end""", 0.75)

# Let Expressions
test("""
let
    1+2
end""", 3)
test("let x = 1; x end", 1)
test("let x = 2; x * 3 end", 6)
test("let a = 1, b = 2; let a = 3; a+b end end", 5)
test("""
let a = 1
    a + 2
end""", 3)

# Anonymous Functions
test("(() -> 5)()", 5)
test("(x -> x + 1)(1)", 2)
test("((x, y) -> x + y)(1, 2)", 3)
test("((x, y, z) -> x * y * z)(1, 2, 3)", 6)

# Let Expression with Function Definitions
test("let x(y) = y+1; x(1) end", 2)
test("let x(y,z) = y+z; x(1,2) end", 3)
test("let x = 1, y(x) = x+1; y(x+1) end", 3)

# Assignments and Definitions
test("""
begin
    x = 1 + 2
    x + 2
end""", 5)
test("""
begin
    x = 1 + 2
    x = 2
    x
end""", 2)
test("""
begin
    x = 3
    triple(a) = a + a + a
    triple(x + 3)
end""", 18)
test("""
begin
    baz = 3
    let x = 0
        baz = 5
    end + baz
end""", 8)
test("""
begin
    baz = 3
        let
            baz = 6
        end + baz
end""", 9)
test("""
begin
    triple(a) = a + a + a
    sum(f, a, b) = a > b ?  0 : f(a) + sum(f, a + 1, b)
    sum(triple, 1, 10)
end""", 165)
test("""
begin
    f(a) = a + 1
    f(a) = 2 * a
    f(3)
end""", 6)
test("""
begin
    f = x -> x + 1
    f = x -> 2*x
    f(3)
end""", 6)
test("""
begin
    incr =
        let priv_counter = 0
            () -> priv_counter = priv_counter + 1
        end
    incr()
end""", 1)
test("""
begin
    incr = let priv_counter = 0
        () -> priv_counter = priv_counter + 1
    end
    incr()
    incr()
end""", 2)
test("""
begin
    incr = let priv_counter = 0
        () -> priv_counter = priv_counter + 1
    end
    incr()
    incr()
    incr()
end""", 3)
test("""
begin
    let
        global x = 1
    end
    x
end""", 1)
test("""
begin
    let secret = 1234
        global show_secret() = secret
    end
    show_secret()
end
""", 1234)
test("""
begin
    let priv_balance = 0
        global deposit = quantity -> priv_balance = priv_balance + quantity
        global withdraw = quantity -> priv_balance = priv_balance - quantity
    end
    deposit(200)
end""", 200)
test("""
begin
    let priv_balance = 0
        global deposit = quantity -> priv_balance = priv_balance + quantity
        global withdraw = quantity -> priv_balance = priv_balance - quantity
    end
    deposit(200)
    withdraw(50)
end""", 150)
test("""
let n = 1
    n = n - 1
    n
end
""", 0)

# Short-Circuit
test("""
let quotient_or_false(a, b) = !(b == 0) && a/b
    quotient_or_false(6, 2)
end
""", 3)
test("""
let quotient_or_false(a, b) = !(b == 0) && a/b
    quotient_or_false(6, 0)
end
""", false)

# Recursive Functions
test("""
let fact(n) = n == 0 ? 1 : n * fact(n - 1)
    fact(3)
end
""", 6)

# Reflection
test(":foo", Symbol(:foo))
test(":(foo + bar)", :(foo + bar))
test(":((1 + 2) * \$(1 + 2))", :((1 + 2) * 3))
test("""
begin
    a = 1
    b = 2
    :(\$a + \$b)
end
""", :(1 + 2))

# Fexprs
test("""
begin
    identity_fexpr(x) := x
    identity_fexpr(1 + 2)
end""", :(1 + 2))
test("""
begin
    identity_fexpr(x) := x
    identity_fexpr(1 + 2) == :(1 + 2)
end""", true)
test("""
begin
    debug(expr) :=
        let r = eval(expr)
            r
        end

    let x = 1
        1 + debug(x + 1)
    end
end
""", 3)
test("""
begin
    let a = 1
        global puzzle(x) :=
            let b = 2
                eval(x) + a + b
            end
    end

    let a = 3, b = 4
        puzzle(a + b)
    end
end
""", 10)
test("""
begin
    let a = 1
        global puzzle(x) :=
            let b = 2
                eval(x) + a + b
            end
    end

    let eval = 123
        puzzle(eval)
    end
end
""", 126)
test("""
begin
    mystery() := eval
    let a = 1, b = 2
        global eval_here = mystery()
    end
    let a = 3, b = 4
        global eval_there = mystery()
    end
    eval_here(:(a + b)) + eval_there(:(a + b))
end
""", 10)

# Macros
test("""
begin
    when(condition, action) \$= :(\$condition ? \$action : false)
    abs(x) = (when(x < 0, (x = -x;)); x)
    abs(-5)
end
""", 5)
test("""
begin
    when(condition, action) \$= :(\$condition ? \$action : false)
    abs(x) = (when(x < 0, (x = -x;)); x)
    abs(5)
end
""", 5)
