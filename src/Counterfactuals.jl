# SPDX-License-Identifier: PMPL-1.0-or-later
"""
Counterfactual reasoning: "What would have happened if...?"

Counterfactuals answer questions about alternate realities where
interventions were different, given observations in the actual world.
"""
module Counterfactuals

using Graphs: inneighbors, outneighbors
using ..CausalDAG
using ..DoCalculus: do_intervention

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
    counterfactual(g, outcome, intervention, observations; equations=nothing)

Evaluate counterfactual: what would outcome be under intervention,
given observations in actual world?

Uses three-step process:
1. Abduction: Infer unobserved variables U from observations
2. Action: Apply intervention (mutilate graph)
3. Prediction: Compute counterfactual outcome

Requires `equations`: Dict{Symbol, Function} where each function has signature:
    (parents::Dict{Symbol, Any}, noise::Dict{Symbol, Any}) -> value
"""
function counterfactual(
    g::CausalGraph,
    outcome::Symbol,
    intervention::Pair,
    observations::Dict;
    equations::Union{Nothing, Dict{Symbol, Function}} = nothing
)
    if equations === nothing
        @warn "counterfactual requires structural equations to compute actual counterfactuals"
        return nothing
    end

    X, x_value = intervention

    # Step 1: Abduction - infer noise terms U from observations
    # For each observed variable, solve equation backwards to get U
    U = Dict{Symbol, Any}()

    # Topological sort to process variables in order
    topo_order = topological_sort_nodes(g)

    for var in topo_order
        if haskey(observations, var) && haskey(equations, var)
            # Get parent values
            var_idx = g.name_to_index[var]
            parent_indices = inneighbors(g.graph, var_idx)
            parent_dict = Dict{Symbol, Any}()

            for p_idx in parent_indices
                p_name = g.names[p_idx]
                if haskey(observations, p_name)
                    parent_dict[p_name] = observations[p_name]
                else
                    # Parent not observed, use 0 as default
                    parent_dict[p_name] = 0.0
                end
            end

            # Infer noise: U_var = observed_value - f(parents, empty_noise)
            # Simplified approach: assume additive noise Y = f(parents) + U
            # So U = Y - f(parents, {})
            predicted = equations[var](parent_dict, Dict{Symbol, Any}())
            # Store noise with U_ prefix convention
            U[Symbol("U_", var)] = observations[var] - predicted
        end
    end

    # Step 2: Action - apply intervention
    # Create a new set of values with intervention applied
    intervened_values = copy(observations)
    intervened_values[X] = x_value

    # Step 3: Prediction - compute counterfactual outcome
    # Evaluate equations in topological order using inferred U
    counterfactual_values = Dict{Symbol, Any}()

    for var in topo_order
        if var == X
            # Intervention: set X to x_value
            counterfactual_values[X] = x_value
        elseif haskey(equations, var)
            # Get parent values from counterfactual world
            var_idx = g.name_to_index[var]
            parent_indices = inneighbors(g.graph, var_idx)
            parent_dict = Dict{Symbol, Any}()

            for p_idx in parent_indices
                p_name = g.names[p_idx]
                if haskey(counterfactual_values, p_name)
                    parent_dict[p_name] = counterfactual_values[p_name]
                else
                    parent_dict[p_name] = 0.0
                end
            end

            # Evaluate equation with inferred noise
            counterfactual_values[var] = equations[var](parent_dict, U)
        end
    end

    # Return counterfactual value of outcome
    get(counterfactual_values, outcome, nothing)
end

"""
    topological_sort_nodes(g)

Return nodes in topological order (parents before children).
"""
function topological_sort_nodes(g::CausalGraph)
    n = length(g.names)
    in_degree = zeros(Int, n)

    # Compute in-degrees
    for i in 1:n
        in_degree[i] = length(inneighbors(g.graph, i))
    end

    # BFS-based topological sort
    queue = Int[]
    for i in 1:n
        if in_degree[i] == 0
            push!(queue, i)
        end
    end

    result = Symbol[]

    while !isempty(queue)
        current = popfirst!(queue)
        push!(result, g.names[current])

        for neighbor in outneighbors(g.graph, current)
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0
                push!(queue, neighbor)
            end
        end
    end

    result
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
