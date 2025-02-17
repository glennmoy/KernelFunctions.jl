@testset "piecewisepolynomial" begin
    D = 2
    v1 = rand(D)
    v2 = rand(D)
    maha = Matrix{Float64}(I, D, D)
    degree = 3

    k = PiecewisePolynomialKernel(; degree=degree, dim=D)
    k2 = PiecewisePolynomialKernel{degree}(; dim=D)

    @test k2(v1, v2) == k(v1, v2)

    @test_throws UndefKeywordError PiecewisePolynomialKernel()
    @test_throws UndefKeywordError PiecewisePolynomialKernel(; degree=degree)
    @test_throws UndefKeywordError PiecewisePolynomialKernel{4}()
    @test_throws ErrorException PiecewisePolynomialKernel{4}(; dim=D)
    @test_throws ErrorException PiecewisePolynomialKernel{degree}(; dim=-1)

    # default degree
    @test PiecewisePolynomialKernel(; dim=D) isa PiecewisePolynomialKernel{0}

    @test repr(k) ==
        "Piecewise Polynomial Kernel (degree = $(degree), ⌊dim/2⌋ = $(div(D, 2)), metric = Euclidean(0.0))"

    k3 = PiecewisePolynomialKernel(;
        degree=degree, dim=D, metric=WeightedEuclidean(ones(D))
    )
    @test metric(k3) isa WeightedEuclidean
    @test k3(v1, v2) ≈ k(v1, v2)

    # Standardised tests.
    TestUtils.test_interface(k, ColVecs{Float64}; dim_in=2)
    TestUtils.test_interface(k, RowVecs{Float64}; dim_in=2)
    test_ADs(() -> PiecewisePolynomialKernel{degree}(; dim=D))

    test_params(k, ())
    if VERSION >= v"1.8.0"
        test_interface_ad_perf(nothing, StableRNG(123456)) do _
            PiecewisePolynomialKernel{degree}(; dim=D)
        end
    else
        @testset "AD Alloc Performance ($T)" for T in [
            Vector{Float64},
            ColVecs{Float64,Matrix{Float64}},
            RowVecs{Float64,Matrix{Float64}},
        ]
            test_interface_ad_perf(
                _ -> PiecewisePolynomialKernel{degree}(; dim=D),
                nothing,
                example_inputs(StableRNG(123456), T)...;
                passes=(
                    unary=(true, true, false),
                    binary=(true, true, false),
                    diag_unary=(true, true, false),
                    diag_binary=(true, true, false),
                ),
            )
        end
    end
end
