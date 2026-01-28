;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - Project relationship mapping
;; Media Type: application/vnd.ecosystem+scm

(ecosystem
  (version "1.0")
  (name "Causals.jl")
  (type "causal-inference-library")
  (purpose "Comprehensive causal inference toolkit unifying multiple approaches: Dempster-Shafer theory, Bradford Hill criteria, causal DAGs, do-calculus, Granger causality, propensity scores, and counterfactual reasoning")

  (position-in-ecosystem
    (role "causal-reasoning-foundation")
    (layer "core-library")
    (description "Provides unified causal inference framework for the hyperpolymath ecosystem, eclipsing fragmented existing Julia packages with production-grade implementations"))

  (related-projects
    ((name . "BowtieRisk.jl")
     (relationship . "sibling-standard")
     (description . "Risk modeling with event chains - Causals provides causal validation for risk pathways")
     (integration . "Validate bowtie threat→consequence chains using causal DAGs, test causal necessity of barriers"))
    ((name . "Axiom.jl")
     (relationship . "potential-consumer")
     (description . "ML reasoning system - can use Causals for causal discovery and intervention analysis")
     (integration . "Learn causal structures from ML training data, apply do-calculus for fair ML interventions"))
    ((name . "CausalInference.jl")
     (relationship . "inspiration")
     (description . "Existing Julia package - DAG-focused, Causals aims to eclipse with broader coverage")
     (integration . "Compatible DAG representations, Causals adds 6 additional methodologies"))
    ((name . "Exnovation.jl")
     (relationship . "sibling-standard")
     (description . "Strategic removal framework - Causals can validate causal impact of removals")
     (integration . "Use counterfactual reasoning to predict outcomes of exnovation strategies"))
    ((name . "HackenbushGames.jl")
     (relationship . "potential-consumer")
     (description . "Game theory framework - causal analysis of strategy outcomes")
     (integration . "Model game moves as interventions, use do-calculus for strategy evaluation"))
    ((name . "Turing.jl")
     (relationship . "potential-integration")
     (description . "Probabilistic programming - Bayesian causal inference integration point")
     (integration . "Combine SCMs with Bayesian inference for uncertainty quantification"))
    ((name . "GLM.jl")
     (relationship . "potential-integration")
     (description . "Generalized linear models - regression adjustment for causal effects")
     (integration . "Use GLM for propensity score estimation and outcome modeling")))

  (what-this-is
    "A comprehensive causal inference library unifying 7 major approaches"
    "Dempster-Shafer theory for combining uncertain evidence from multiple sources"
    "Bradford Hill criteria for assessing causality in observational studies"
    "Causal DAGs with d-separation, backdoor/frontdoor criteria, and identification"
    "Granger causality for time series causal analysis with VAR models"
    "Propensity score methods (matching, IPW, stratification, doubly-robust)"
    "Pearl's do-calculus for intervention effects and causal identification"
    "Counterfactual reasoning with twin networks for necessity/sufficiency"
    "Production-grade implementations with comprehensive documentation"
    "Designed to eclipse fragmented existing Julia causal packages")

  (what-this-is-not
    "Not limited to DAGs like CausalInference.jl - provides 7 methodologies"
    "Not simulation-only like Causal.jl - includes real data analysis methods"
    "Not basic statistics like CausalityTools.jl - implements advanced causal methods"
    "Not a specialized time series package - Granger causality is one component"
    "Not a probabilistic programming system - integrates with Turing.jl but separate"
    "Not a machine learning framework - provides causal analysis for ML, not ML itself"
    "Not focused on causal discovery algorithms - emphasizes effect estimation"
    "Not a GUI tool - library for programmatic causal analysis"
    "Not FIPS-certified or formally verified - research and analysis tool"))
