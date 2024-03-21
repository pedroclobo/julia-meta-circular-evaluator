include("metajulia_repl.jl")

import Test.@testset
import Test.@test

@testset verbose = true "MetaJulia" begin

    # Self-Evaluating Expressions
    @testset verbose = true "Self-Evaluating Expressions" begin
        @test metajulia_eval(:(1)) == 1
        @test metajulia_eval(:("Hello World")) == "Hello World"
        @test metajulia_eval(:(true)) == true
        @test metajulia_eval(:(false)) == false
    end

    # Arithmetic Expressions
    @testset verbose = true "Arithmetic Expressions" begin
        @test metajulia_eval(:(+1)) == 1
        @test metajulia_eval(:(-1)) == -1
        @test metajulia_eval(:(1 + 2)) == 3
        @test metajulia_eval(:(1 - 2)) == -1
        @test metajulia_eval(:(1 * 2)) == 2
        @test metajulia_eval(:(1 / 2)) == 0.5
        @test metajulia_eval(:(3 ÷ 2)) == 1
        @test metajulia_eval(:(4 \ 2)) == 0.5
        @test metajulia_eval(:(2^3)) == 8
        @test metajulia_eval(:(4 % 3)) == 1
        @test metajulia_eval(:((2 + 3) * (4 + 5))) == 45
        @test metajulia_eval(:(2 + 3 * 4 + 5)) == 19
        @test metajulia_eval(:(√4)) == 2
    end

    # Boolean Operators
    @testset verbose = true "Boolean Operators" begin
        @test metajulia_eval(:(!true)) == false
        @test metajulia_eval(:(!false)) == true
        @test metajulia_eval(:(false && true)) == false
        @test metajulia_eval(:(false || true)) == true
        @test metajulia_eval(:(true || a)) == true
        @test metajulia_eval(:(false && a)) == false
        @test metajulia_eval(:(3 > 2 && 3 < 2)) == false
        @test metajulia_eval(:(3 > 2 || 3 < 2)) == true
    end

    # Bitwise Operators
    @testset verbose = true "Bitwise Operators" begin
        @test metajulia_eval(:(~123)) == -124
        @test metajulia_eval(:(123 & 234)) == 106
        @test metajulia_eval(:(123 | 234)) == 251
        @test metajulia_eval(:(123 ⊻ 234)) == 145
        @test metajulia_eval(:(123 ⊼ 123)) == -124
        @test metajulia_eval(:(123 ⊽ 124)) == -128
        @test metajulia_eval(:(123 >>> 2)) == 30
        @test metajulia_eval(:(123 >> 2)) == 30
        @test metajulia_eval(:(123 << 2)) == 492
    end

    # Numeric Comparisons
    @testset verbose = true "Numeric Comparisons" begin
        @test metajulia_eval(:(1 == 1)) == true
        @test metajulia_eval(:(1 == 2)) == false
        @test metajulia_eval(:(1 != 2)) == true
        @test metajulia_eval(:(1 == 1.0)) == true
        @test metajulia_eval(:(1 ≠ 1)) == false
        @test metajulia_eval(:(1 < 2)) == true
        @test metajulia_eval(:(1.0 > 3)) == false
        @test metajulia_eval(:(1 >= 1.0)) == true
        @test metajulia_eval(:(1 ≥ 1.0)) == true
        @test metajulia_eval(:(-1 <= 1)) == true
        @test metajulia_eval(:(-1 <= -1)) == true
        @test metajulia_eval(:(-1 <= -2)) == false
        @test metajulia_eval(:(1 ≤ 2)) == true
        @test metajulia_eval(:(3 < -0.5)) == false
        @test metajulia_eval(:(3 > 2)) == true
        @test metajulia_eval(:(3 < 2)) == false
    end

    # If Expressions
    @testset verbose = true "If Expressions" begin
        @test metajulia_eval(:(3 > 2 ? 1 : 0)) == 1
        @test metajulia_eval(:(3 < 2 ? 1 : 0)) == 0
        @test metajulia_eval(:(
            if 3 > 2
                1
            else
                0
            end)) == 1
        @test metajulia_eval(:(
            if 3 < 2
                1
            elseif 2 > 3
                2
            else
                0
            end)) == 0
        @test metajulia_eval(:(
            if 3 < 2
                1
            elseif 2 < 3
                2
            else
                0
            end)) == 2
        @test metajulia_eval(:(
            if 1 < 2
                1
            elseif 3 < 4
                2
            else
                0
            end)) == 1
    end

    # Blocks
    @testset verbose = true "Blocks" begin
        @test metajulia_eval(:((1 + 2; 2 * 3; 3 / 4))) == 0.75
        @test metajulia_eval(:(
            begin
                1 + 2
                2 * 3
                3 / 4
            end
        )) == 0.75
        @test metajulia_eval(:(
            begin
                1 + 2
                2 * 3
                3 / 4
            end)) == 0.75
    end

    # Let Expressions
    @testset verbose = true "Let Expressions" begin
        @test metajulia_eval(:(
            let
                1 + 2
            end)) == 3
        @test metajulia_eval(:(
            let x = 1
                x
            end
        )) == 1
        @test metajulia_eval(:(
            let x = 2
                x * 3
            end
        )) == 6
        @test metajulia_eval(:(
            let a = 1, b = 2
                let a = 3
                    a + b
                end
            end
        )) == 5
        @test metajulia_eval(:(
            let a = 1
                a + 2
            end)) == 3
        @test metajulia_eval(:(
            let a = 1, b = a
                b + 1
            end
        )) == 2
    end

    # Anonymous Functions
    @testset verbose = true "Anonymous Functions" begin
        @test metajulia_eval(:((() -> 5)())) == 5
        @test metajulia_eval(:((x -> x + 1)(1))) == 2
        @test metajulia_eval(:(((x, y) -> x + y)(1, 2))) == 3
        @test metajulia_eval(:(((x, y, z) -> x * y * z)(1, 2, 3))) == 6
    end

    # Let Expression with Function Definitions
    @testset verbose = true "Let Expression with Function Definitions" begin
        @test metajulia_eval(:(
            let x(y) = y + 1
                x(1)
            end
        )) == 2
        @test metajulia_eval(:(
            let x(y, z) = y + z
                x(1, 2)
            end
        )) == 3
        @test metajulia_eval(:(
            let x = 1, y(x) = x + 1
                y(x + 1)
            end
        )) == 3
    end

    # Assignments and Definitions
    @testset verbose = true "Assignments and Definitions" begin
        @test metajulia_eval(:(
            begin
                x = 1 + 2
                x + 2
            end)) == 5
        @test metajulia_eval(:(
            begin
                x = 1 + 2
                x = 2
                x
            end)) == 2
        @test metajulia_eval(:(
            begin
                x = 3
                triple(a) = a + a + a
                triple(x + 3)
            end)) == 18
        @test metajulia_eval(:(
            begin
                baz = 3
                let x = 0
                    baz = 5
                end + baz
            end)) == 8
        @test metajulia_eval(:(
            begin
                baz = 3
                let
                    baz = 6
                end + baz
            end)) == 9
        @test metajulia_eval(:(
            begin
                triple(a) = a + a + a
                sum(f, a, b) = a > b ? 0 : f(a) + sum(f, a + 1, b)
                sum(triple, 1, 10)
            end)) == 165
        @test metajulia_eval(:(
            begin
                f(a) = a + 1
                f(a) = 2 * a
                f(3)
            end)) == 6
        @test metajulia_eval(:(
            begin
                f = x -> x + 1
                f = x -> 2 * x
                f(3)
            end)) == 6
        @test metajulia_eval(:(
            begin
                incr =
                    let priv_counter = 0
                        () -> priv_counter = priv_counter + 1
                    end
                incr()
            end)) == 1
        @test metajulia_eval(:(
            begin
                incr = let priv_counter = 0
                    () -> priv_counter = priv_counter + 1
                end
                incr()
                incr()
            end)) == 2
        @test metajulia_eval(:(
            begin
                incr = let priv_counter = 0
                    () -> priv_counter = priv_counter + 1
                end
                incr()
                incr()
                incr()
            end)) == 3
        @test metajulia_eval(:(
            begin
                let
                    global x = 1
                end
                x
            end)) == 1
        @test metajulia_eval(:(
            begin
                let secret = 1234
                    global show_secret() = secret
                end
                show_secret()
            end
        )) == 1234
        @test metajulia_eval(:(
            begin
                let priv_balance = 0
                    global deposit = quantity -> priv_balance = priv_balance + quantity
                    global withdraw = quantity -> priv_balance = priv_balance - quantity
                end
                deposit(200)
            end)) == 200
        @test metajulia_eval(:(
            begin
                let priv_balance = 0
                    global deposit = quantity -> priv_balance = priv_balance + quantity
                    global withdraw = quantity -> priv_balance = priv_balance - quantity
                end
                deposit(200)
                withdraw(50)
            end)) == 150
        @test metajulia_eval(:(
            let n = 1
                n = n - 1
                n
            end
        )) == 0
    end

    # Short-Circuit
    @testset verbose = true "Short-Circuit" begin
        @test metajulia_eval(:(
            let quotient_or_false(a, b) = !(b == 0) && a / b
                quotient_or_false(6, 2)
            end
        )) == 3
        @test metajulia_eval(:(
            let quotient_or_false(a, b) = !(b == 0) && a / b
                quotient_or_false(6, 0)
            end
        )) == false
    end

    # Recursive Functions
    @testset verbose = true "Recursive Functions" begin
        @test metajulia_eval(:(
            let fact(n) = n == 0 ? 1 : n * fact(n - 1)
                fact(3)
            end
        )) == 6
    end

    # Basic Reflection
    @testset verbose = true "Basic Reflection" begin
        @test metajulia_eval(:(:foo)) == Symbol(:foo)
        @test metajulia_eval(:(:(foo + bar))) == :(foo + bar)
        @test metajulia_eval(:(:((1 + 2) * $(1 + 2)))) == :((1 + 2) * 3)
        @test metajulia_eval(:(
            begin
                a = 1
                b = 2
                :($a + $b)
            end
        )) == :(1 + 2)
    end

    # Fexprs
    @testset verbose = true "Fexprs" begin
        @test metajulia_eval(:(
            begin
                identity_fexpr(x) := x
                identity_fexpr(1 + 2)
            end)) == :(1 + 2)
        @test metajulia_eval(:(
            begin
                identity_fexpr(x) := x
                identity_fexpr(1 + 2) == :(1 + 2)
            end)) == true
        @test metajulia_eval(:(
            begin
                debug(expr) :=
                    let r = eval(expr)
                        r
                    end

                let x = 1
                    1 + debug(x + 1)
                end
            end
        )) == 3
        @test metajulia_eval(:(
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
        )) == 10
        @test metajulia_eval(:(
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
        )) == 126
        @test metajulia_eval(:(
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
        )) == 10
    end

    # Macros
    @testset verbose = true "Macros" begin
        @test metajulia_eval(Meta.parse("""
            begin
                when(condition, action) \$= :(\$condition ? \$action : false)
                abs(x) = (when(x < 0, (x = -x;)); x)
                abs(-5)
            end
        """)) == 5
        @test metajulia_eval(Meta.parse("""
            begin
                when(condition, action) \$= :(\$condition ? \$action : false)
                abs(x) = (when(x < 0, (x = -x)); x)
                abs(5)
            end
        """)) == 5
        @test metajulia_eval(Meta.parse("""
            begin
                repeat_until(condition, action) \$=
                    :(
                        let
                            loop() = (\$action; \$condition ? false : loop())
                            loop()
                        end
                    )

                let n = 4, a = 0
                    repeat_until(n == 0, (a = a + 1; n = n - 1))
                    a
                end
            end
        """)) == 4
        @test metajulia_eval(Meta.parse("""
            begin
                repeat_until(condition, action) \$=
                    let loop = gensym()
                        :(
                            let
                                \$loop() = (\$action; \$condition ? false : \$loop())
                                \$loop()
                            end
                        )
                    end

                let loop = 0, i = 3
                    repeat_until(i == 0, (loop = loop + 1; i = i - 1))
                    loop
                end
            end
        """)) == 3
    end

end
