# SPDX-License-Identifier: PMPL-1.0-or-later
"""
Basic Usage Example for Causals.jl

This example demonstrates the core functionality of the Causals package,
including Dempster-Shafer evidence combination, Bradford Hill criteria assessment,
and simple causal DAG operations.
"""

using Causals
using Causals.DempsterShafer
using Causals.BradfordHill
using Causals.CausalDAG
using Graphs

println("=" ^ 60)
println("Causals.jl - Basic Usage Example")
println("=" ^ 60)
println()

# Example 1: Dempster-Shafer Evidence Combination
println("1. Dempster-Shafer Evidence Combination")
println("-" ^ 40)

# Create evidence from two independent sources about a medical diagnosis
# Frame of discernment: {disease_a, disease_b, disease_c}
frame = [:disease_a, :disease_b, :disease_c]

# Source 1: Lab test suggests disease_a or disease_b with 0.7 confidence
evidence1 = MassAssignment(Dict(
    Set([:disease_a, :disease_b]) => 0.7,
    Set(frame) => 0.3  # Remaining uncertainty
))

# Source 2: Symptoms suggest disease_b or disease_c with 0.6 confidence
evidence2 = MassAssignment(Dict(
    Set([:disease_b, :disease_c]) => 0.6,
    Set(frame) => 0.4  # Remaining uncertainty
))

# Combine evidence using Dempster's rule
combined = combine_dempster(evidence1, evidence2)

println("Individual disease beliefs:")
println("  disease_a: belief=$(round(belief(combined, Set([:disease_a])), digits=3))")
println("  disease_b: belief=$(round(belief(combined, Set([:disease_b])), digits=3))")
println("  disease_c: belief=$(round(belief(combined, Set([:disease_c])), digits=3))")
println()

# Pignistic transformation for decision-making
probs = pignistic_transform(combined, frame)
println("Decision probabilities (pignistic):")
for (disease, prob) in sort(collect(probs), by=x->x[2], rev=true)
    println("  $(disease): $(round(prob, digits=3))")
end
println()

# Example 2: Bradford Hill Causal Assessment
println("2. Bradford Hill Causal Assessment")
println("-" ^ 40)

# Assess potential causal relationship: smoking → lung cancer
assessment = BradfordHillCriteria(
    strength = 0.9,          # Strong association (RR >> 1)
    consistency = 0.95,      # Consistent across many studies
    specificity = 0.7,       # Somewhat specific (other factors exist)
    temporality = 1.0,       # Clear temporal relationship
    biological_gradient = 0.85,  # Clear dose-response
    plausibility = 0.9,      # Biologically plausible mechanisms
    coherence = 0.9,         # Coherent with existing knowledge
    experiment = 0.6,        # Some experimental evidence (animal studies)
    analogy = 0.7           # Analogous to other carcinogen relationships
)

causality_score = assess_causality(assessment)
evidence_level = strength_of_evidence(assessment)

println("Smoking → Lung Cancer Assessment:")
println("  Causality score: $(round(causality_score, digits=3))")
println("  Evidence strength: $(evidence_level)")
println()

# Example 3: Simple Causal DAG Operations
println("3. Causal DAG Operations")
println("-" ^ 40)

# Build a simple causal graph:
#   Education → Income
#   Education → Health
#   Income → Health
cg = CausalGraph(DiGraph(4))

# Nodes: 1=Education, 2=Income, 3=Health, 4=Exercise
CausalDAG.add_edge!(cg, 1, 2)  # Education → Income
CausalDAG.add_edge!(cg, 1, 3)  # Education → Health
CausalDAG.add_edge!(cg, 2, 3)  # Income → Health
CausalDAG.add_edge!(cg, 4, 3)  # Exercise → Health

println("Causal graph structure:")
println("  Nodes: 1=Education, 2=Income, 3=Health, 4=Exercise")
println("  Edges: $(ne(cg.graph))")
println()

# Check d-separation: Is Education ⊥ Exercise given Income?
is_dsep = d_separation(cg, [1], [4], [2])
println("D-separation test:")
println("  Education ⊥ Exercise | Income? $(is_dsep)")
println()

# Find ancestors and descendants
println("Causal relationships:")
println("  Ancestors of Health (3): $(sort(collect(ancestors(cg, 3))))")
println("  Descendants of Education (1): $(sort(collect(descendants(cg, 1))))")
println()

# Check backdoor criterion for Income → Health effect
backdoor_ok = backdoor_criterion(cg, 2, 3, [1])
println("Backdoor criterion:")
println("  Can estimate Income → Health effect controlling for Education? $(backdoor_ok)")
println()

println("=" ^ 60)
println("Basic usage example completed successfully!")
println("=" ^ 60)
