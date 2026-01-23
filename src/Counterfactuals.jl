# SPDX-License-Identifier: PMPL-1.0-or-later
"""
Counterfactual reasoning: "What would have happened if...?"

Counterfactuals answer questions about alternate realities where
interventions were different, given observations in the actual world.
"""
module Counterfactuals

using ..CausalDAG

export counterfactual, twin_network, probability_of_necessity
export probability_of_sufficiency, probability_of_necessity_and_sufficiency

"""
    Counterfactual

Represents a counterfactual query: Y_x(u) = value of Y in world where X=x.
"""
struct Counterfactual
    outcome::Symbol          # Y: outcome variable
    intervention::Pair       # X => x: intervention
    condition::Dict          # Observed values in actual world
end

"""
    counterfactual(g, outcome, intervention, observations)

Evaluate counterfactual: what would outcome be under intervention,
given observations in actual world?

Uses three-step process:
1. Abduction: Infer unobserved variables U from observations
2. Action: Apply intervention (mutilate graph)
3. Prediction: Compute counterfactual outcome
"""
function counterfactual(
    g::CausalGraph,
    outcome::Symbol,
    intervention::Pair{Symbol, Any},
    observations::Dict{Symbol, Any}
)
    # Step 1: Abduction - infer latent U from observations
    # (Requires structural equations, not just graph)
    U = Dict{Symbol, Any}()  # Placeholder

    # Step 2: Action - create mutilated graph
    X, x = intervention
    g_mutilated, _, _ = do_intervention(g, X, x)

    # Step 3: Prediction - compute Y in counterfactual world
    # (Requires evaluating structural equations forward)
    nothing  # Placeholder - requires SCM with equations
end

"""
    twin_network(g)

Create twin network for counterfactual reasoning.
Duplicates all nodes to represent factual and counterfactual worlds.
"""
function twin_network(g::CausalGraph)
    # Create graph with nodes {X, X'} for each X in original
    n = length(g.names)
    twin_names = vcat(g.names, [Symbol(string(name) * "'") for name in g.names])

    twin_g = CausalGraph(twin_names)

    # Copy edges in both factual and counterfactual worlds
    for i in 1:n
        for j in outneighbors(g.graph, i)
            add_edge!(twin_g, g.names[i], g.names[j])
            add_edge!(twin_g, Symbol(string(g.names[i]) * "'"), Symbol(string(g.names[j]) * "'"))
        end
    end

    # Share latent U variables between worlds
    twin_g
end

"""
    probability_of_necessity(treatment, outcome, data)

PN = P(Y_0=0 | X=1, Y=1): probability that treatment was necessary for outcome.
"Would the outcome have occurred without the treatment?"
"""
function probability_of_necessity(
    treatment::Symbol,
    outcome::Symbol,
    data::Dict{Symbol, Vector{Bool}}
)
    # Among those with treatment AND outcome, how many would lack outcome without treatment?
    # Requires counterfactual estimation

    treated_and_outcome = data[treatment] .& data[outcome]
    if sum(treated_and_outcome) == 0
        return 0.0
    end

    # Simplified: lower bound using observational data
    # PN >= P(Y=0|X=0)  (assumption: monotonicity)
    untreated = .!data[treatment]
    if sum(untreated) == 0
        return 0.0
    end

    1.0 - sum(data[outcome][untreated]) / sum(untreated)
end

"""
    probability_of_sufficiency(treatment, outcome, data)

PS = P(Y_1=1 | X=0, Y=0): probability that treatment would be sufficient for outcome.
"Would the treatment cause the outcome if applied?"
"""
function probability_of_sufficiency(
    treatment::Symbol,
    outcome::Symbol,
    data::Dict{Symbol, Vector{Bool}}
)
    # Among those without treatment AND without outcome, how many would have outcome with treatment?

    untreated_no_outcome = (.!data[treatment]) .& (.!data[outcome])
    if sum(untreated_no_outcome) == 0
        return 0.0
    end

    # Simplified: upper bound
    # PS <= P(Y=1|X=1)
    treated = data[treatment]
    if sum(treated) == 0
        return 0.0
    end

    sum(data[outcome][treated]) / sum(treated)
end

"""
    probability_of_necessity_and_sufficiency(treatment, outcome, data)

PNS = P(Y_1=1, Y_0=0): probability treatment is both necessary and sufficient.
"""
function probability_of_necessity_and_sufficiency(
    treatment::Symbol,
    outcome::Symbol,
    data::Dict{Symbol, Vector{Bool}}
)
    pn = probability_of_necessity(treatment, outcome, data)
    ps = probability_of_sufficiency(treatment, outcome, data)

    # Bound: max(0, PN + PS - 1) <= PNS <= min(PN, PS)
    # Return midpoint of bound as estimate
    lower = max(0.0, pn + ps - 1.0)
    upper = min(pn, ps)
    (lower + upper) / 2.0
end

end # module Counterfactuals
