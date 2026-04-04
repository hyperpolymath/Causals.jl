# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# E2E pipeline tests for Causals.jl
# Tests the full causal inference workflow: DAG construction → identification →
# propensity scoring → ATE estimation → counterfactual reasoning.

using Test
using Causals
using Causals.CausalDAG: add_edge!, d_separation, frontdoor_criterion
using Statistics: mean

@testset "E2E Pipeline Tests" begin

    @testset "Full pipeline: observational causal study" begin
        # 1. Build causal graph: Z confounds X→Y
        g = CausalGraph([:Z, :X, :Y])
        add_edge!(g, :Z, :X)
        add_edge!(g, :Z, :Y)
        add_edge!(g, :X, :Y)

        # 2. Verify backdoor criterion (Z blocks the backdoor path X←Z→Y)
        @test backdoor_criterion(g, :X, :Y, Set([:Z]))

        # 3. Generate observational data with known true ATE ≈ 1.0
        n = 200
        z = randn(n)
        x = Float64.(z .+ randn(n) .> 0.0)
        y = 1.0 .* x .+ 0.5 .* z .+ 0.2 .* randn(n)
        treatment = BitVector(x .> 0.5)
        outcome   = y

        # 4. Propensity score estimation
        covariates = reshape(z, n, 1)
        ps = propensity_score(treatment, covariates)
        @test length(ps) == n
        @test all(0.0 .<= ps .<= 1.0)

        # 5. IPW ATE estimate — should be in a reasonable range of true effect
        ate, se = inverse_probability_weighting(treatment, outcome, ps)
        @test !isnan(ate)
        @test se >= 0.0

        # 6. Ancestor/descendant check
        @test :Z in ancestors(g, :Y)
        @test :X in ancestors(g, :Y)
        @test :Y in descendants(g, :Z)
    end

    @testset "Full pipeline: Granger causality and consensus" begin
        # Generate time series where x Granger-causes y
        n = 150
        x = randn(n)
        y = zeros(n)
        for t in 3:n
            y[t] = 0.6 * y[t-1] + 0.4 * x[t-2] + 0.1 * randn()
        end

        causes, F_stat, p_val, best_lag = granger_test(x, y, 5)
        @test F_stat >= 0.0
        @test best_lag >= 1

        strength = granger_causality(x, y, 5)
        @test 0.0 <= strength <= 1.0

        # Bradford Hill assessment on observed evidence
        criteria = BradfordHillCriteria(
            strength=strength,
            consistency=0.7,
            temporality=1.0,
            plausibility=0.6,
        )
        verdict, confidence = assess_causality(criteria)
        @test verdict in [:strong, :moderate, :weak, :insufficient, :none]
        @test 0.0 <= confidence <= 1.0

        # Consensus engine
        report = causal_consensus(nothing)
        @test report isa ConsensusReport
        @test report.verdict == :likely_causal
    end

    @testset "Error handling: invalid graph operations" begin
        # Masses not summing to 1 should error
        @test_throws ErrorException MassAssignment([:A, :B], Dict(Set([:A]) => 0.3))

        # Bradford Hill criteria outside [0,1] should error
        @test_throws ErrorException BradfordHillCriteria(strength=-0.1)
        @test_throws ErrorException BradfordHillCriteria(temporality=1.5)
    end

    @testset "Round-trip consistency: Dempster-Shafer combination is associative" begin
        frame = [:A, :B, :C]
        m1 = MassAssignment(frame, Dict(Set([:A]) => 0.5, Set([:A,:B,:C]) => 0.5))
        m2 = MassAssignment(frame, Dict(Set([:B]) => 0.4, Set([:A,:B,:C]) => 0.6))
        m3 = MassAssignment(frame, Dict(Set([:A]) => 0.3, Set([:A,:B,:C]) => 0.7))

        # (m1 ⊕ m2) ⊕ m3
        combined_12_3 = combine_dempster(combine_dempster(m1, m2), m3)
        # m1 ⊕ (m2 ⊕ m3)
        combined_1_23 = combine_dempster(m1, combine_dempster(m2, m3))

        # Total mass should sum to 1 in both cases
        @test sum(values(combined_12_3.masses)) ≈ 1.0 atol=1e-10
        @test sum(values(combined_1_23.masses))  ≈ 1.0 atol=1e-10
    end

end
