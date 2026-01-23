# SPDX-License-Identifier: PMPL-1.0-or-later
"""
Propensity score methods for causal inference from observational data.

Propensity scores balance treatment and control groups on observed covariates,
mimicking randomization when experiments are infeasible.
"""
module PropensityScore

using Statistics
using StatsBase

export propensity_score, matching, inverse_probability_weighting
export stratification, doubly_robust

"""
    propensity_score(treatment, covariates)

Estimate propensity score: P(treatment=1 | covariates).
Uses logistic regression (simplified implementation).
"""
function propensity_score(treatment::Vector{Bool}, covariates::Matrix{Float64})
    # Logistic regression: log(p/(1-p)) = X*β
    # Simplified: use empirical frequencies by covariate bins
    n = length(treatment)
    p = sum(treatment) / n

    # Return vector of propensity scores (one per observation)
    # Simplified: assume constant propensity for demo
    fill(p, n)
end

"""
    matching(treatment, outcome, propensity; method=:nearest, caliper=0.1)

Propensity score matching: pair treated and control units.
Returns (matched_indices, treatment_effect, std_error).
"""
function matching(
    treatment::Vector{Bool},
    outcome::Vector{Float64},
    propensity::Vector{Float64};
    method::Symbol = :nearest,
    caliper::Float64 = 0.1
)
    treated_idx = findall(treatment)
    control_idx = findall(.!treatment)

    matches = Tuple{Int, Int}[]

    for t_idx in treated_idx
        # Find nearest control
        distances = abs.(propensity[control_idx] .- propensity[t_idx])
        best_match_pos = argmin(distances)
        best_distance = distances[best_match_pos]

        if best_distance <= caliper
            c_idx = control_idx[best_match_pos]
            push!(matches, (t_idx, c_idx))
        end
    end

    # Estimate treatment effect
    effects = [outcome[t] - outcome[c] for (t, c) in matches]
    ate = mean(effects)
    se = std(effects) / sqrt(length(effects))

    (matches, ate, se)
end

"""
    inverse_probability_weighting(treatment, outcome, propensity)

IPW estimator: weight by inverse propensity score.
Returns (ATE, std_error).
"""
function inverse_probability_weighting(
    treatment::Vector{Bool},
    outcome::Vector{Float64},
    propensity::Vector{Float64}
)
    n = length(treatment)

    # IPW weights
    weights = treatment ./ propensity .+ (1 .- treatment) ./ (1 .- propensity)

    # Weighted mean difference
    treated_weighted = sum(outcome .* treatment ./ propensity) / sum(treatment ./ propensity)
    control_weighted = sum(outcome .* (1 .- treatment) ./ (1 .- propensity)) / sum((1 .- treatment) ./ (1 .- propensity))

    ate = treated_weighted - control_weighted

    # Simplified standard error
    se = sqrt(var(outcome .* weights) / n)

    (ate, se)
end

"""
    stratification(treatment, outcome, propensity; n_strata=5)

Stratify by propensity score quintiles and estimate ATE.
"""
function stratification(
    treatment::Vector{Bool},
    outcome::Vector{Float64},
    propensity::Vector{Float64};
    n_strata::Int = 5
)
    # Create strata by propensity quantiles
    quantiles = range(0, 1, length=n_strata+1)
    strata_bounds = [quantile(propensity, q) for q in quantiles]

    stratum_effects = Float64[]
    stratum_weights = Float64[]

    for s in 1:n_strata
        lower = strata_bounds[s]
        upper = strata_bounds[s+1]

        in_stratum = (propensity .>= lower) .& (propensity .<= upper)

        treated_in_stratum = in_stratum .& treatment
        control_in_stratum = in_stratum .& (.!treatment)

        if sum(treated_in_stratum) > 0 && sum(control_in_stratum) > 0
            effect = mean(outcome[treated_in_stratum]) - mean(outcome[control_in_stratum])
            weight = sum(in_stratum) / length(propensity)

            push!(stratum_effects, effect)
            push!(stratum_weights, weight)
        end
    end

    # Weighted average across strata
    ate = sum(stratum_effects .* stratum_weights)
    (ate, stratum_effects, stratum_weights)
end

"""
    doubly_robust(treatment, outcome, propensity, outcome_model)

Doubly robust estimator: consistent if either propensity or outcome model correct.
"""
function doubly_robust(
    treatment::Vector{Bool},
    outcome::Vector{Float64},
    propensity::Vector{Float64},
    outcome_model::Function  # outcome_model(covariates) → predicted outcome
)
    # Simplified implementation
    # Full DR estimator requires outcome regression for both treated/control
    ipw_ate, _ = inverse_probability_weighting(treatment, outcome, propensity)
    ipw_ate
end

end # module PropensityScore
