# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# Property-based tests for Causals.jl
# Verifies mathematical invariants across random data and graph configurations.

using Test
using Causals
using Causals.CausalDAG: add_edge!
using Statistics: mean

@testset "Property-Based Tests" begin

    @testset "Invariant: Dempster-Shafer masses always sum to 1" begin
        frame = [:A, :B, :C]
        for _ in 1:50
            # Generate two random valid mass assignments
            a1, a2 = sort(rand(2))
            m1 = MassAssignment(frame, Dict(Set([:A]) => a1, Set([:A,:B,:C]) => 1.0 - a1))
            b1 = rand()
            m2 = MassAssignment(frame, Dict(Set([:B]) => b1, Set([:A,:B,:C]) => 1.0 - b1))
            combined = combine_dempster(m1, m2)
            @test sum(values(combined.masses)) ≈ 1.0 atol=1e-10
        end
    end

    @testset "Invariant: belief ≤ plausibility always" begin
        frame = [:A, :B, :C]
        for _ in 1:50
            p_a = rand()
            m = MassAssignment(frame, Dict(Set([:A]) => p_a, Set([:A,:B,:C]) => 1.0 - p_a))
            for focal in [Set([:A]), Set([:B]), Set([:A,:B]), Set([:A,:B,:C])]
                @test belief(m, focal) <= plausibility(m, focal) + 1e-12
            end
        end
    end

    @testset "Invariant: propensity scores in [0, 1]" begin
        for _ in 1:50
            n = rand(20:100)
            treatment = rand(Bool, n)
            covariates = randn(n, rand(1:5))
            ps = propensity_score(treatment, covariates)
            @test length(ps) == n
            @test all(0.0 .<= ps .<= 1.0)
        end
    end

    @testset "Invariant: Granger strength in [0, 1]" begin
        for _ in 1:50
            n = rand(30:80)
            x = randn(n)
            y = randn(n)
            strength = granger_causality(x, y, rand(1:3))
            @test 0.0 <= strength <= 1.0
        end
    end

    @testset "Invariant: ancestors never include the node itself" begin
        for _ in 1:50
            # Build a random chain graph of length 3-6
            n = rand(3:6)
            names = [Symbol("N$i") for i in 1:n]
            g = CausalGraph(names)
            for i in 1:(n-1)
                add_edge!(g, names[i], names[i+1])
            end
            # Check for each node that it is not in its own ancestors set
            for name in names
                @test name ∉ ancestors(g, name)
            end
        end
    end

    @testset "Invariant: discount preserves total mass" begin
        frame = [:A, :B, :C]
        for _ in 1:50
            p_a = rand()
            m = MassAssignment(frame, Dict(Set([:A]) => p_a, Set([:A,:B,:C]) => 1.0 - p_a))
            epsilon = rand()  # discount factor in [0,1]
            m_discounted = discount(m, epsilon)
            @test sum(values(m_discounted.masses)) ≈ 1.0 atol=1e-10
        end
    end

end
