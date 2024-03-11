include("metajulia_repl.jl")

function test(input, expected)
    try
        eval(Meta.parse(input), empty_env()) == expected || error("Test Failed")
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
test("let secret = 1234; global show_secret() = secret end; show_secret()", 1234)
test("""
begin
    let priv_balance = 0
        global deposit = quantity -> priv_balance = priv_balance + quantity
        global withdraw = quantity -> priv_balance = priv_balance - quantity
    end
    deposit(100)
end""", 200)
test("""
begin
    let priv_balance = 0
        global deposit = quantity -> priv_balance = priv_balance + quantity
        global withdraw = quantity -> priv_balance = priv_balance - quantity
    end
    deposit(100)
    withdraw(150)
end""", 150)
