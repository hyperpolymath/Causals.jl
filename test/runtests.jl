# SPDX-License-Identifier: PMPL-1.0-or-later
using Test
using Causals
using Causals.CausalDAG: add_edge!

@testset "Causals.jl" begin

    @testset "Dempster-Shafer" begin
        frame = [:A, :B, :C]
        masses = Dict(
            Set([:A]) => 0.4,
            Set([:B]) => 0.3,
            Set([:A, :B, :C]) => 0.3
        )
        m = MassAssignment(frame, masses)

        @test mass(m, Set([:A])) == 0.4
        @test belief(m, Set([:A])) == 0.4
        @test plausibility(m, Set([:A])) >= belief(m, Set([:A]))

        # Combination
        m2 = MassAssignment(frame, Dict(Set([:A]) => 0.6, Set([:A, :B, :C]) => 0.4))
        m_combined = combine_dempster(m, m2)
        @test sum(values(m_combined.masses)) ≈ 1.0

        # Discount
        m_discounted = discount(m, 0.8)
        @test sum(values(m_discounted.masses)) ≈ 1.0
    end

    @testset "Bradford Hill" begin
        criteria = BradfordHillCriteria(
            strength = 0.8,
            consistency = 0.9,
            temporality = 1.0,
            plausibility = 0.7
        )

        verdict, confidence = assess_causality(criteria)
        @test verdict in [:strong, :moderate, :weak, :insufficient, :none]
        @test 0.0 <= confidence <= 1.0

        # Temporality required
        no_temporal = BradfordHillCriteria(strength=0.9, temporality=0.0)
        verdict_no_temp, _ = assess_causality(no_temporal)
        @test verdict_no_temp == :none
    end

    @testset "Granger Causality" begin
        # Generate test data: x causes y with lag
        n = 100
        x = randn(n)
        y = zeros(n)
        for t in 2:n
            y[t] = 0.5 * y[t-1] + 0.3 * x[t-1] + 0.1 * randn()
        end

        causes, F_stat, p_val, lag = granger_test(x, y, 5)
        @test F_stat >= 0.0
        @test lag >= 1

        strength = granger_causality(x, y, 5)
        @test 0.0 <= strength <= 1.0
    end

    @testset "Causal DAG" begin
        # Create simple DAG: X → M → Y, C → X, C → Y
        g = CausalGraph([:X, :M, :Y, :C])
        add_edge!(g, :X, :M)
        add_edge!(g, :M, :Y)
        add_edge!(g, :C, :X)
        add_edge!(g, :C, :Y)

        # Test ancestors/descendants
        anc_y = ancestors(g, :Y)
        @test :X in anc_y
        @test :M in anc_y
        @test :C in anc_y

        desc_x = descendants(g, :X)
        @test :M in desc_x
        @test :Y in desc_x

        # Backdoor criterion
        @test backdoor_criterion(g, :X, :Y, Set([:C]))
    end

    @testset "Propensity Score" begin
        n = 100
        treatment = rand(Bool, n)
        outcome = treatment .* 2.0 .+ randn(n)
        propensity = propensity_score(treatment, randn(n, 3))

        @test length(propensity) == n
        @test all(0.0 .<= propensity .<= 1.0)

        # IPW
        ate, se = inverse_probability_weighting(treatment, outcome, propensity)
        @test !isnan(ate)
        @test se >= 0.0
    end

end
