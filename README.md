<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

[![OpenSSF Best Practices](https://img.shields.io/badge/OpenSSF-Best_Practices-green?logo=opensourcesecurity)](https://www.bestpractices.dev/en/projects/new?repo_url=https://github.com/hyperpolymath/Causals.jl)
[![License: MPL-2.0](https://img.shields.io/badge/License-MPL--2.0-blue.svg)](https://www.mozilla.org/MPL/2.0/)
<embed
src="https://api.thegreenwebfoundation.org/greencheckimage/github.com"
data-link="https://www.thegreenwebfoundation.org/green-web-check/?url=github.com" />

<div class="lead" wrapper="1">

**Comprehensive causal inference toolkit for Julia - Eclipse all
existing causal packages with unified, production-grade
implementations.**

</div>

[![Topology](https://img.shields.io/badge/Project-Topology-9558B2)](TOPOLOGY.md)
[![95](https://img.shields.io/badge/Completion-95%25-green)](TOPOLOGY.md)

<div id="toc">

</div>

# What is Causals.jl?

Causals.jl brings together the major approaches to causal reasoning
under one roof:

- **Dempster-Shafer theory** - combine uncertain evidence from multiple
  experts

- **Bradford Hill criteria** - assess causality in observational studies

- **Causal DAGs** - graphical models, d-separation, identification

- **Granger causality** - time series causal analysis

- **Propensity scores** - matching, weighting, stratification for
  observational data

- **Do-calculus** - Pearl’s intervention framework

- **Counterfactuals** - "what if" reasoning about alternate realities

# Why Causals.jl?

**Existing Julia packages are fragmented:** - `CausalInference.jl` -
only DAGs - `Causal.jl` - simulation only - `CausalityTools.jl` - basic
stats only

**Causals.jl eclipses them with:** - Complete coverage of causal
inference methods - Production-grade implementations - Comprehensive
documentation - Active development - RSR compliance (Rust/Deno standards
adapted for Julia)

# Quick Examples

## Dempster-Shafer Evidence Combination

```julia
using Causals

# Expert 1: 60% confident in hypothesis A
frame = [:A, :B, :C]
expert1 = MassAssignment(frame, Dict(
    Set([:A]) => 0.6,
    Set([:A, :B, :C]) => 0.4  # ignorance
))

# Expert 2: 70% confident in A or B
expert2 = MassAssignment(frame, Dict(
    Set([:A, :B]) => 0.7,
    Set([:A, :B, :C]) => 0.3
))

# Combine evidence
combined = combine_dempster(expert1, expert2)
@show belief(combined, Set([:A]))       # Lower bound
@show plausibility(combined, Set([:A])) # Upper bound
```

## Bradford Hill Causal Assessment

```julia
criteria = BradfordHillCriteria(
    strength = 0.85,           # Strong correlation
    consistency = 0.90,        # Replicated across studies
    specificity = 0.60,        # Moderate specificity
    temporality = 1.0,         # Cause precedes effect (REQUIRED)
    biological_gradient = 0.75,# Clear dose-response
    plausibility = 0.80,       # Biologically plausible
    coherence = 0.70,          # Fits known facts
    experiment = 0.0,          # No RCT (observational)
    analogy = 0.65             # Similar known relationships
)

verdict, confidence = assess_causality(criteria)
# verdict: :strong, confidence: 0.78
```

## Granger Causality (Time Series)

```julia
# Does oil price Granger-cause inflation?
oil_price = [....]  # historical data
inflation = [....]

causes, F_stat, p_value, lag = granger_test(oil_price, inflation, max_lag=12)

if causes
    println("Oil price Granger-causes inflation with lag $lag months")
    println("F-statistic: $F_stat, p-value: $p_value")
end
```

## Causal DAG and Backdoor Criterion

```julia
# Build causal graph: Education → Income, Ability → Education, Ability → Income
g = CausalGraph([:Education, :Income, :Ability, :ParentIncome])
add_edge!(g, :Education, :Income)
add_edge!(g, :Ability, :Education)
add_edge!(g, :Ability, :Income)
add_edge!(g, :ParentIncome, :Education)

# To estimate effect of Education on Income, must control for Ability
@assert backdoor_criterion(g, :Education, :Income, Set([:Ability]))

# Ability blocks backdoor path: Education ← Ability → Income
```

## Propensity Score Matching

```julia
# Observational study: does training program increase wages?
treatment = [....]  # received training (Bool)
wages = [....]      # outcome
covariates = [....]  # age, education, experience (Matrix)

# Estimate propensity scores
ps = propensity_score(treatment, covariates)

# Match treated to similar controls
matches, ate, std_err = matching(treatment, wages, ps, caliper=0.1)

println("Average treatment effect: $(ate) ± $(1.96*std_err)")
```

## Counterfactual Reasoning

```julia
# Among those who got treatment and recovered, would they have recovered without it?
treatment = [:Treatment => true]
outcome = :Recovered
data = Dict(
    :Treatment => [...],  # Bool vector
    :Recovered => [...] # Bool vector
)

pn = probability_of_necessity(:Treatment, :Recovered, data)
println("Probability treatment was necessary: $(pn)")
```

# Installation

## From Julia REPL

```julia
using Pkg
Pkg.add("Causals")
```

## From Git (Development)

```julia
using Pkg
Pkg.add(url="https://github.com/hyperpolymath/Causals.jl")
```

# Quick Start

```julia
using Causals

# Combine evidence from multiple experts using Dempster-Shafer
frame = [:A, :B, :C]
expert1 = MassAssignment(frame, Dict(Set([:A]) => 0.6, Set([:A, :B, :C]) => 0.4))
expert2 = MassAssignment(frame, Dict(Set([:A, :B]) => 0.7, Set([:A, :B, :C]) => 0.3))

combined = combine_dempster(expert1, expert2)
println(belief(combined, Set([:A])))  # Lower bound on probability of A
```

# Documentation

Full documentation at: <https://hyperpolymath.github.io/Causals.jl>

# Modules

| Module            | Purpose                                        |
|-------------------|------------------------------------------------|
| `DempsterShafer`  | Belief functions, evidence combination         |
| `BradfordHill`    | 9-criterion causal assessment framework        |
| `CausalDAG`       | Graphical models, d-separation, identification |
| `Granger`         | Time series causality (VAR models, F-tests)    |
| `PropensityScore` | Matching, IPW, stratification, doubly-robust   |
| `DoCalculus`      | Intervention framework, effect identification  |
| `Counterfactuals` | Twin networks, necessity/sufficiency           |

# Comparison to Existing Packages

| Feature            | Causals.jl | CausalInference.jl | CausalityTools.jl | Causal.jl |
|--------------------|------------|--------------------|-------------------|-----------|
| Dempster-Shafer    | ✓          | ✗                  | ✗                 | ✗         |
| Bradford Hill      | ✓          | ✗                  | ✗                 | ✗         |
| Causal DAGs        | ✓          | ✓                  | ✗                 | ✗         |
| Granger causality  | ✓          | ✗                  | ✓                 | ✗         |
| Propensity scores  | ✓          | ✗                  | ✗                 | ✗         |
| Do-calculus        | ✓          | Partial            | ✗                 | ✗         |
| Counterfactuals    | ✓          | ✗                  | ✗                 | ✗         |
| Production docs    | ✓          | Partial            | Partial           | ✗         |
| Active maintenance | ✓          | ✓                  | ✓                 | ✗         |

# Status

**Alpha** - Core implementations complete, pending extensive testing and
validation against reference implementations.

# Contributing

See <a href="CONTRIBUTING.md" class="md">CONTRIBUTING</a> for
development guidelines.

# License

Palimpsest-MPL License v1.0 (MPL-2.0) - see [LICENSE](LICENSE).

PMPL-1.0 is MPL-2.0 compatible and accepted by Julia General registry.

# Citation

```bibtex
@software{causals_jl,
  title = {Causals.jl: Comprehensive Causal Inference for Julia},
  author = {Hyperpolymath},
  year = {2025},
  url = {https://github.com/hyperpolymath/Causals.jl}
}
```
