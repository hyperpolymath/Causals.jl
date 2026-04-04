# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# BenchmarkTools benchmarks for Causals.jl
# Measures Granger causality, propensity scoring, and DAG queries at varying scales.

using BenchmarkTools
using Causals
using Causals.CausalDAG: add_edge!

# ── Granger causality benchmarks ─────────────────────────────────────────────

# Small series (50 observations)
x_small = randn(50);  y_small = randn(50)
println("=== granger_causality (small: n=50, maxlag=3) ===")
@benchmark granger_causality($x_small, $y_small, 3)

# Medium series (500 observations)
x_med = randn(500);  y_med = randn(500)
println("=== granger_causality (medium: n=500, maxlag=5) ===")
@benchmark granger_causality($x_med, $y_med, 5)

# Large series (2000 observations)
x_large = randn(2000);  y_large = randn(2000)
println("=== granger_causality (large: n=2000, maxlag=10) ===")
@benchmark granger_causality($x_large, $y_large, 10)

# ── Propensity score benchmarks ───────────────────────────────────────────────

n_small  = 50
n_medium = 500
n_large  = 2000

t_small = rand(Bool, n_small);   cov_small = randn(n_small,  3)
t_med   = rand(Bool, n_medium);  cov_med   = randn(n_medium, 5)
t_large = rand(Bool, n_large);   cov_large = randn(n_large,  10)

println("=== propensity_score (small: n=50, 3 covariates) ===")
@benchmark propensity_score($t_small, $cov_small)

println("=== propensity_score (medium: n=500, 5 covariates) ===")
@benchmark propensity_score($t_med, $cov_med)

println("=== propensity_score (large: n=2000, 10 covariates) ===")
@benchmark propensity_score($t_large, $cov_large)

# ── DAG ancestor query benchmarks ────────────────────────────────────────────

# Build chain graphs of different lengths
function chain_graph(n::Int)
    names = [Symbol("N$i") for i in 1:n]
    g = CausalGraph(names)
    for i in 1:(n-1)
        add_edge!(g, names[i], names[i+1])
    end
    g, names[end]
end

g_small, leaf_small   = chain_graph(5)
g_medium, leaf_medium = chain_graph(20)
g_large, leaf_large   = chain_graph(50)

println("=== ancestors query (small: chain of 5) ===")
@benchmark ancestors($g_small, $leaf_small)

println("=== ancestors query (medium: chain of 20) ===")
@benchmark ancestors($g_medium, $leaf_medium)

println("=== ancestors query (large: chain of 50) ===")
@benchmark ancestors($g_large, $leaf_large)
