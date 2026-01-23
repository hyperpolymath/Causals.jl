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
export MassAssignment, belief, plausibility, combine_dempster, discount

using .BradfordHill
export BradfordHillCriteria, assess_causality, strength_of_evidence

using .CausalDAG
export CausalGraph, add_edge!, d_separation, backdoor_criterion, frontdoor_criterion

using .Granger
export granger_test, granger_causality, optimal_lag

using .PropensityScore
export propensity_score, matching, weighting, stratification

using .DoCalculus
export do_intervention, identify_effect, adjustment_formula

using .Counterfactuals
export counterfactual, twin_network, probability_of_necessity

end # module Causals
