using Test

include("metajulia_repl.jl")

function test(input, expected)
    println("Testing `$input`")
    @test evaluate(Meta.parse(input)) == expected
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
