# SPDX-License-Identifier: PMPL-1.0-or-later
"""
Advanced Causal Analysis Example for Causals.jl

This example demonstrates advanced causal inference techniques including:
- Granger causality for time series
- Propensity score matching for observational studies
- Do-calculus for interventional queries
- Counterfactual reasoning
"""

using Causals
using Causals.Granger
using Causals.PropensityScore
using Causals.DoCalculus
using Causals.Counterfactuals
using Causals.CausalDAG
using Statistics
using Random
using Graphs

Random.seed!(42)

println("=" ^ 60)
println("Causals.jl - Advanced Analysis Example")
println("=" ^ 60)
println()

# Example 1: Granger Causality for Time Series
println("1. Granger Causality Analysis")
println("-" ^ 40)

# Generate synthetic time series: X causes Y with lag
n_observations = 100
time_series_x = randn(n_observations)
time_series_y = zeros(n_observations)

# Y depends on past values of X (with noise)
for time_index in 3:n_observations
    time_series_y[time_index] = 0.7 * time_series_x[time_index-1] +
                                 0.3 * time_series_x[time_index-2] +
                                 0.3 * randn()
end

# Test for Granger causality
println("Testing if X Granger-causes Y...")
result = granger_test(time_series_x, time_series_y; max_lag=5)
println("  F-statistic: $(round(result.f_stat, digits=3))")
println("  p-value: $(round(result.p_value, digits=4))")
println("  Granger causes? $(result.causes)")
println()

# Find optimal lag
optimal = optimal_lag(time_series_x, time_series_y; max_lag=8)
println("  Optimal lag: $(optimal) periods")
println()

# Example 2: Propensity Score Matching
println("2. Propensity Score Matching")
println("-" ^ 40)

# Simulated observational study: effect of training program on salary
num_subjects = 200

# Confounders: education level and prior experience
education = rand(num_subjects) .* 10  # 0-10 years
experience = rand(num_subjects) .* 15  # 0-15 years

# Treatment assignment (training) depends on confounders
propensity_true = 1.0 ./ (1.0 .+ exp.(-(0.3 .* education .+ 0.2 .* experience .- 4.0)))
treatment = rand(num_subjects) .< propensity_true

# Outcome (salary) depends on treatment and confounders
control_outcomes = 30.0 .+ 2.0 .* education .+ 1.5 .* experience .+ randn(num_subjects) .* 3.0
treated_outcomes = control_outcomes .+ 5.0 .+ randn(num_subjects) .* 2.0
observed_outcomes = ifelse.(treatment, treated_outcomes, control_outcomes)

# Estimate propensity scores
covariates = hcat(education, experience)
propensity_scores = propensity_score(treatment, covariates)

println("Propensity score statistics:")
println("  Mean (treated): $(round(mean(propensity_scores[treatment]), digits=3))")
println("  Mean (control): $(round(mean(propensity_scores[.!treatment]), digits=3))")
println()

# Perform matching
matches = matching(treatment, propensity_scores)
println("Matching results:")
println("  Number of matched pairs: $(length(matches))")

# Calculate treatment effect using matched pairs
treated_outcomes_matched = [observed_outcomes[pair[1]] for pair in matches]
control_outcomes_matched = [observed_outcomes[pair[2]] for pair in matches]
average_treatment_effect = mean(treated_outcomes_matched .- control_outcomes_matched)

println("  Average Treatment Effect (ATE): $(round(average_treatment_effect, digits=2)) thousand")
println("  (True effect: 5.0 thousand)")
println()

# Example 3: Do-Calculus and Interventions
println("3. Do-Calculus and Interventional Queries")
println("-" ^ 40)

# Build a causal model with confounding
#   Z (confounder) → X (treatment) → Y (outcome)
#   Z → Y (confounding path)
confounded_graph = CausalGraph(DiGraph(3))
CausalDAG.add_edge!(confounded_graph, 1, 2)  # Z → X
CausalDAG.add_edge!(confounded_graph, 1, 3)  # Z → Y
CausalDAG.add_edge!(confounded_graph, 2, 3)  # X → Y

println("Causal model: Z → X → Y, Z → Y")
println()

# Check if effect is identifiable
effect_identifiable = identify_effect(confounded_graph, 2, 3)
println("Effect identification:")
println("  Can identify causal effect of X on Y? $(effect_identifiable)")
println()

# Use adjustment formula
adjustment_set = confounding_adjustment(confounded_graph, 2, 3)
println("Adjustment formula:")
println("  Sufficient adjustment set: $(adjustment_set)")
println("  Interpretation: Control for Z to eliminate confounding")
println()

# Example 4: Counterfactual Reasoning
println("4. Counterfactual Reasoning")
println("-" ^ 40)

# Simple structural equation model: X → Y
# Y = 2X + noise
structural_equations = Dict(
    :X => (vals) -> get(vals, :X, 0.0),
    :Y => (vals) -> 2.0 * get(vals, :X, 0.0) + get(vals, :noise_Y, 0.0)
)

# Observed values
observed_values = Dict(:X => 3.0, :noise_Y => 0.5)
factual_Y = structural_equations[:Y](observed_values)

println("Factual scenario:")
println("  X = $(observed_values[:X])")
println("  Y = $(factual_Y)")
println()

# Counterfactual: What if X had been 5.0 instead?
counterfactual_values = counterfactual(
    structural_equations,
    observed_values,
    Dict(:X => 5.0)
)

println("Counterfactual scenario (if X = 5.0):")
println("  Y would have been: $(round(counterfactual_values[:Y], digits=2))")
println()

# Probability of necessity: Was X=3 necessary for Y>5?
println("Causal responsibility analysis:")
println("  Factual: X=3 → Y=$(factual_Y)")
println("  Question: Was X=3 necessary for Y>5?")
if factual_Y > 5.0
    counterfactual_Y_if_X_0 = 2.0 * 0.0 + observed_values[:noise_Y]
    was_necessary = counterfactual_Y_if_X_0 <= 5.0
    println("  Answer: $(was_necessary)")
    println("  (If X had been 0, Y would be $(counterfactual_Y_if_X_0))")
else
    println("  Not applicable (Y ≤ 5)")
end
println()

println("=" ^ 60)
println("Advanced analysis example completed successfully!")
println("=" ^ 60)
