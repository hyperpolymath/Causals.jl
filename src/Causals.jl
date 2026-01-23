# SPDX-License-Identifier: PMPL-1.0-or-later
"""
    Causals.jl

Comprehensive causal inference and analysis toolkit for Julia.

Combines multiple approaches to causal reasoning:
- Dempster-Shafer theory (evidence combination)
- Bradford Hill criteria (causal assessment)
- Causal DAGs and do-calculus (interventions)
- Granger causality (time series)
- Propensity score methods (observational studies)
- Counterfactual reasoning
"""
module Causals

using LinearAlgebra
using Statistics
using Distributions
using Graphs
using StatsBase

# Submodules
include("DempsterShafer.jl")
include("BradfordHill.jl")
include("CausalDAG.jl")
include("Granger.jl")
include("PropensityScore.jl")
include("DoCalculus.jl")
include("Counterfactuals.jl")

# Re-export key types and functions
using .DempsterShafer
export MassAssignment, mass, belief, plausibility, uncertainty, combine_dempster, discount, pignistic_transform, conflict_measure

using .BradfordHill
export BradfordHillCriteria, assess_causality, strength_of_evidence

using .CausalDAG
export CausalGraph, add_edge!, remove_edge!, d_separation, ancestors, descendants, backdoor_criterion, frontdoor_criterion, markov_blanket

using .Granger
export granger_test, granger_causality, optimal_lag, bidirectional_granger

using .PropensityScore
export propensity_score, matching, inverse_probability_weighting, stratification, doubly_robust

using .DoCalculus
export do_intervention, identify_effect, adjustment_formula, confounding_adjustment

using .Counterfactuals
export counterfactual, twin_network, probability_of_necessity, probability_of_sufficiency, probability_of_necessity_and_sufficiency

end # module Causals
