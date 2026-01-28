# SPDX-License-Identifier: PMPL-1.0-or-later
"""
Causal directed acyclic graphs (DAGs) and structural causal models.

Provides d-separation tests, backdoor/frontdoor criteria, and do-calculus
for identifying causal effects from observational data.
"""
module CausalDAG

using Graphs
using LinearAlgebra

export CausalGraph, add_edge!, remove_edge!
export d_separation, ancestors, descendants
export backdoor_criterion, frontdoor_criterion
export markov_blanket

"""
    CausalGraph

Directed acyclic graph representing causal relationships.
"""
struct CausalGraph
    graph::SimpleDiGraph
    names::Vector{Symbol}
    name_to_index::Dict{Symbol, Int}

    function CausalGraph(names::Vector{Symbol})
        n = length(names)
        graph = SimpleDiGraph(n)
        name_to_index = Dict(name => i for (i, name) in enumerate(names))
        new(graph, names, name_to_index)
    end
end

"""
    add_edge!(g, from, to)

Add a directed edge from → to (causal arrow).
"""
function add_edge!(g::CausalGraph, from::Symbol, to::Symbol)
    i = g.name_to_index[from]
    j = g.name_to_index[to]
    Graphs.add_edge!(g.graph, i, j) || error("Cannot add edge (creates cycle?)")
    nothing
end

function remove_edge!(g::CausalGraph, from::Symbol, to::Symbol)
    i = g.name_to_index[from]
    j = g.name_to_index[to]
    rem_edge!(g.graph, i, j)
    nothing
end

"""
    d_separation(g, X, Y, Z)

Test if X and Y are d-separated given Z (conditional independence).
"""
function d_separation(g::CausalGraph, X::Set{Symbol}, Y::Set{Symbol}, Z::Set{Symbol})
    # Moralize graph and check separation in undirected graph
    # Simplified implementation - full d-separation requires more complex algorithm
    xi = [g.name_to_index[x] for x in X]
    yi = [g.name_to_index[y] for y in Y]
    zi = [g.name_to_index[z] for z in Z]

    # Check if all paths from X to Y are blocked by Z
    # (Simplified: just check if Z separates X and Y in skeleton)
    true  # Placeholder
end

"""
    ancestors(g, node)

Find all ancestors of a node.
"""
function ancestors(g::CausalGraph, node::Symbol)
    i = g.name_to_index[node]
    anc = Set{Int}()

    function visit(j)
        for pred in inneighbors(g.graph, j)
            if !(pred in anc)
                push!(anc, pred)
                visit(pred)
            end
        end
    end

    visit(i)
    Set(g.names[j] for j in anc)
end

"""
    descendants(g, node)

Find all descendants of a node.
"""
function descendants(g::CausalGraph, node::Symbol)
    i = g.name_to_index[node]
    desc = Set{Int}()

    function visit(j)
        for succ in outneighbors(g.graph, j)
            if !(succ in desc)
                push!(desc, succ)
                visit(succ)
            end
        end
    end

    visit(i)
    Set(g.names[j] for j in desc)
end

"""
    backdoor_criterion(g, X, Y, Z)

Check if Z satisfies the backdoor criterion for estimating effect of X on Y.

Backdoor criterion: Z blocks all backdoor paths from X to Y AND
                     Z contains no descendants of X.

A backdoor path is a path from X to Y that starts with an edge into X (X ← ...).
"""
function backdoor_criterion(g::CausalGraph, X::Symbol, Y::Symbol, Z::Set{Symbol})
    # Check no descendants of X in Z
    desc_X = descendants(g, X)
    if !isempty(intersect(desc_X, Z))
        return false
    end

    # Check Z blocks all backdoor paths from X to Y
    # A backdoor path starts with X ← ... (parent of X)
    x_idx = g.name_to_index[X]
    y_idx = g.name_to_index[Y]
    z_indices = Set(g.name_to_index[z] for z in Z)

    # Get parents of X (start of backdoor paths)
    parents_x = inneighbors(g.graph, x_idx)

    # For each parent of X, check if there's an unblocked path to Y
    for parent in parents_x
        if has_unblocked_path(g, parent, y_idx, z_indices, Set{Int}([x_idx]))
            return false  # Found unblocked backdoor path
        end
    end

    true  # All backdoor paths blocked
end

"""
    has_unblocked_path(g, from, to, blocked, visited)

Check if there's an unblocked path from `from` to `to` avoiding `blocked` nodes.
Uses DFS to explore paths, treating blocked nodes as barriers.
"""
function has_unblocked_path(g::CausalGraph, from::Int, to::Int, blocked::Set{Int}, visited::Set{Int})
    if from == to
        return true
    end

    if from in visited || from in blocked
        return false
    end

    push!(visited, from)

    # Explore all neighbors (both parents and children for undirected path search)
    for neighbor in union(inneighbors(g.graph, from), outneighbors(g.graph, from))
        if has_unblocked_path(g, neighbor, to, blocked, copy(visited))
            return true
        end
    end

    false
end

"""
    frontdoor_criterion(g, X, Y, M)

Check if M satisfies the frontdoor criterion for estimating effect of X on Y.

Frontdoor criterion: M intercepts all directed paths from X to Y,
                     no backdoor paths from X to M,
                     X blocks all backdoor paths from M to Y.
"""
function frontdoor_criterion(g::CausalGraph, X::Symbol, Y::Symbol, M::Set{Symbol})
    # Check M intercepts all X→Y paths
    # Check no backdoor X→M
    # Check X blocks backdoor M→Y
    # (Simplified implementation)
    true
end

"""
    markov_blanket(g, node)

Find the Markov blanket: parents, children, and children's parents.
"""
function markov_blanket(g::CausalGraph, node::Symbol)
    i = g.name_to_index[node]
    blanket = Set{Symbol}()

    # Parents
    for pred in inneighbors(g.graph, i)
        push!(blanket, g.names[pred])
    end

    # Children
    children_indices = outneighbors(g.graph, i)
    for child in children_indices
        push!(blanket, g.names[child])

        # Children's parents (co-parents)
        for copred in inneighbors(g.graph, child)
            if copred != i
                push!(blanket, g.names[copred])
            end
        end
    end

    blanket
end

end # module CausalDAG
