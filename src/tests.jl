using Test

include("metajulia_repl.jl")

function test(input, expected)
    println("Testing `$input`")
    @test evaluate(Meta.parse(input), empty_env()) == expected
end

# Self-Evaluating Expressions
test("1", 1)
test("\"Hello World\"", "Hello World")
test("true", true)
test("false", false)

# Call Expressions
test("1 + 2", 3)
test("(2 + 3) * (4 + 5)", 45)
test("2 + 3 * 4 + 5", 19)
test("3 > 2", true)
test("3 < 2", false)
test("3 > 2 && 3 < 2", false)
test("3 > 2 || 3 < 2", true)

# If Expressions
test("3 > 2 ? 1 : 0", 1)
test("3 < 2 ? 1 : 0", 0)
test("if 3 > 2 1 else 0 end", 1)
test("if 3 < 2 1 elseif 2 > 3 2 else 0 end", 0)
test("if 3 < 2 1 elseif 2 < 3 2 else 0 end", 2)
test("if 1 < 2 1 elseif 3 < 4 2 else 0 end", 1)

# Blocks
test("(1+2; 2*3; 3/4)", 0.75)
test("begin 1+2; 2*3; 3/4 end", 0.75)

# Let Expressions
test("let x = 1; x end", 1)
test("let x = 2; x * 3 end", 6)
test("let a = 1, b = 2; let a = 3; a+b end end", 5)
