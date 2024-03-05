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
