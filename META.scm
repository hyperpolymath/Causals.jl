;; SPDX-License-Identifier: PMPL-1.0-or-later
;; META.scm - Causals.jl architectural decisions and design rationale
;; Media Type: application/meta+scheme

(define-module (meta causals)
  #:use-module (ice-9 match)
  #:export (meta get-adr))

(define meta
  '((metadata
      (version . "0.1.0")
      (schema-version . "1.0.0")
      (created . "2026-01-28")
      (updated . "2026-01-28")
      (project . "Causals.jl")
      (media-type . "application/meta+scheme"))

    (architecture-decisions
      ((adr-001
         (title . "Unified library covering multiple causal inference approaches")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Existing Julia packages are fragmented: CausalInference.jl (DAGs only), CausalityTools.jl (basic stats), Causal.jl (simulation). Users need multiple packages for comprehensive causal analysis. No single Julia package rivals Python's DoWhy or R's causal packages.")
         (decision . "Create Causals.jl as comprehensive toolkit unifying 7 approaches: Dempster-Shafer, Bradford Hill, DAGs, Granger, propensity scores, do-calculus, counterfactuals. Each in separate submodule, all exported from main namespace. Aim to eclipse existing packages.")
         (consequences . "Positive: One-stop solution for causal analysis, consistent API, easier maintenance. Negative: Large scope increases development time, risk of being 'jack of all trades', may compete with existing packages."))
       (adr-002
         (title . "Submodule architecture for methodological separation")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Different causal methods have distinct types, functions, and theories. Mixing in single namespace risks naming collisions and conceptual confusion. Need clear boundaries while maintaining usability.")
         (decision . "Implement each methodology in separate Julia module (DempsterShafer, BradfordHill, CausalDAG, etc.). Main Causals module re-exports key functions. Users can access via Causals.method() or import specific submodules. Note: add_edge! not re-exported to avoid Graphs.jl conflict.")
         (consequences . "Positive: Clear conceptual boundaries, prevents naming collisions, allows independent development. Negative: Deeper module tree, users need to know which submodule for advanced features."))
       (adr-003
         (title . "Explicit over implicit - no auto-causal-discovery")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Causal discovery algorithms (PC, FCI, GES) can infer DAG structure from data. However, they require strong assumptions (causal sufficiency, faithfulness) and are computationally expensive. Users often have domain knowledge superior to algorithmic discovery.")
         (decision . "Focus on causal effect estimation given known/hypothesized causal structure. Users manually specify DAGs, interventions, confounders. No automatic causal discovery in v0.1.0. May add as optional module later if demand exists.")
         (consequences . "Positive: Simpler scope, respects domain knowledge, avoids dubious automated claims about causality. Negative: Users without causal knowledge may struggle, no exploratory discovery tools."))
       (adr-004
         (title . "Dempster-Shafer for epistemic uncertainty about causality")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Causal inference requires combining evidence from multiple studies/experts. Bayesian methods force probabilistic interpretation. Dempster-Shafer explicitly models ignorance and conflicting evidence without requiring full probability assignments.")
         (decision . "Include Dempster-Shafer as first-class module for combining uncertain causal evidence. MassAssignment over hypotheses, Dempster's rule for combination, belief/plausibility bounds. Complements probabilistic methods.")
         (consequences . "Positive: Handles ignorance explicitly, combines conflicting expert opinions, theoretically grounded. Negative: Less familiar than Bayesian methods, computational complexity for large frames, may confuse users expecting pure probability."))
       (adr-005
         (title . "Bradford Hill criteria for observational causality assessment")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Observational studies (epidemiology, economics, social science) can't use RCTs. Bradford Hill's 9 criteria (strength, consistency, temporality, etc.) are standard for causal assessment. No existing Julia implementation.")
         (decision . "Implement BradfordHillCriteria struct with 9 criterion scores (0..1). assess_causality() returns verdict (:strong, :moderate, :weak, :none) and confidence score. Temporality required (must be 1.0). Scoring algorithm based on epidemiology literature.")
         (consequences . "Positive: Addresses observational study needs, standard methodology, interpretable. Negative: Subjective scoring, no universal weights for criteria, requires user judgment."))
       (adr-006
         (title . "Granger causality via VAR models and F-tests")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Time series causality needs different approach than cross-sectional DAGs. Granger causality (does X's past predict Y beyond Y's past?) is standard in econometrics and neuroscience. Missing from DAG-focused packages.")
         (decision . "Implement granger_test() with VAR model fitting, F-statistic computation, p-value calculation. Support lag selection via AIC/BIC. Return boolean cause indicator + statistics. Complements DAG methods for temporal data.")
         (consequences . "Positive: Handles time series, standard econometric method, easy interpretation. Negative: Not 'true' causality (prediction-based), requires stationarity assumptions, computationally expensive for high lags."))
       (adr-007
         (title . "Propensity scores for observational studies")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Randomized controlled trials infeasible for many questions. Propensity score methods (Rosenbaum & Rubin) approximate randomization by matching/weighting on treatment probability. Widely used in medicine, economics, policy.")
         (decision . "Implement propensity_score() for score estimation, plus four methods: matching, IPW, stratification, doubly-robust. Use logistic regression for propensity model. Support caliper matching and common support diagnostics.")
         (consequences . "Positive: Enables causal inference from observational data, standard methodology, flexible. Negative: Assumes unconfoundedness (no unmeasured confounding), sensitive to model specification, requires expertise."))
       (adr-008
         (title . "Pearl's do-calculus for intervention identification")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Causal DAGs alone don't identify effects - need rules to determine if effect is identifiable from observational data. Pearl's do-calculus provides three rules for manipulating interventional distributions. Essential for causal inference from graphs.")
         (decision . "Implement DoCalculus module with do_intervention(), identify_effect(), and Pearl's three rules. Support backdoor and frontdoor adjustment formulas. Check identifiability before estimation. Integrate with CausalDAG for graph queries.")
         (consequences . "Positive: Rigorous identification theory, sound basis for effect estimation, standard framework. Negative: Abstract theory may confuse practitioners, rules complex to implement fully, requires graph sophistication."))
       (adr-009
         (title . "Counterfactuals for necessity and sufficiency")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Interventional effects (ATE) don't answer 'was X necessary for Y?' or 'would Y occur with X?' questions. Counterfactuals (twin network framework) needed for causal explanation, mediation, fairness. Missing from most packages.")
         (decision . "Implement Counterfactuals module with twin_network(), probability_of_necessity(), probability_of_sufficiency(). Model exogenous variables for counterfactual inference. Support three-tiered SCM framework (association, intervention, counterfactual).")
         (consequences . "Positive: Enables causal explanation beyond prediction, supports fairness/mediation analysis, theoretically complete. Negative: Requires full SCM specification (not just DAG), strong untestable assumptions, computationally intensive."))
       (adr-010
         (title . "Pure Julia with minimal dependencies")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Causal inference not performance-critical like crypto or ML training. Julia's ecosystem provides needed functionality (Graphs.jl for DAGs, Distributions.jl for stats). Minimizing dependencies reduces maintenance burden and deployment complexity.")
         (decision . "Implement all causal methods in pure Julia. Core dependencies: LinearAlgebra, Statistics (stdlib), Distributions, Graphs, StatsBase. No C/Python bindings. Prioritize correctness and clarity over performance. Use Multiple Dispatch for extensibility.")
         (consequences . "Positive: Easy installation, no build toolchain, cross-platform, hackable. Negative: May be slower than specialized C implementations, can't leverage existing Python/R libraries directly."))
       (adr-011
         (title . "Separation of causal structure from statistical estimation")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Causal structure (DAG, assumptions) is separate concern from statistical estimation (regression, matching). Many packages conflate them. Clean separation allows reuse and testing.")
         (decision . "CausalDAG module handles structure (graph, d-separation, identification). Separate modules (PropensityScore, DoCalculus) handle estimation given structure. Users specify structure explicitly, then call estimation functions with data. No implicit structure inference from data.")
         (consequences . "Positive: Clear conceptual separation, testable without data, structure reusable across datasets. Negative: More verbose usage, users must understand both structure and estimation, no 'one-click' causal inference."))
       (adr-012
         (title . "No integration with GLM.jl in v0.1.0")
         (status . accepted)
         (date . "2026-01-28")
         (context . "Many causal effect estimators use regression models (outcome regression, propensity scores). GLM.jl provides flexible modeling. However, basic logistic regression sufficient for propensity scores, and dependency adds complexity.")
         (decision . "Implement simple logistic regression in PropensityScore module for propensity estimation. No GLM.jl dependency in v0.1.0. Document how users can substitute GLM models for advanced use. May add GLM integration in v0.2.0 if requested.")
         (consequences . "Positive: Fewer dependencies, simpler implementation, sufficient for common cases. Negative: Less flexible modeling, users can't easily use advanced GLM features, may need reimplementation later.")))

    (development-practices
      (code-style
        (formatter . "julia-format")
        (line-length . 100)
        (naming . "snake_case for functions, PascalCase for types")
        (comments . "Docstrings for all exported functions, inline for complex algorithms"))
      (security
        (data-validation . "Clamp probabilities to [0,1], check for NaN/Inf, validate DAG acyclicity")
        (input-sanitization . "Type assertions for struct construction, bounds checking")
        (threat-model . "Assumes trusted input data, focus on correct statistical computations"))
      (testing
        (unit-tests . "All exported functions, core algorithms")
        (property-tests . "Probability invariants, DAG properties, do-calculus rules")
        (test-vectors . "Examples from Pearl's Causality and epidemiology literature")
        (coverage-target . 85))
      (versioning
        (scheme . "SemVer")
        (compatibility . "Julia 1.9+"))
      (documentation
        (api-docs . "Docstrings in source, extracted to docs/")
        (examples . "README with quick start, one example per module")
        (theory . "Links to Pearl's Causality, Rosenbaum & Rubin papers")
        (integration . "Tutorial notebooks planned for v0.2.0"))
      (branching
        (main-branch . "main")
        (feature-branches . "feat/*, fix/*")
        (release-process . "GitHub releases, Julia General registry submission")))

    (design-rationale
      (why-comprehensive-not-specialized
        "Existing packages force users to install multiple libraries for causal analysis"
        "Fragmentation leads to inconsistent APIs and integration challenges"
        "Comprehensive toolkit enables end-to-end causal workflows in single package"
        "Mimics success of Python's DoWhy and R's causal ecosystem")
      (why-dempster-shafer
        "Causal inference from multiple studies requires evidence combination"
        "Bayesian methods force probabilistic interpretation of uncertainty"
        "D-S explicitly represents ignorance and conflicting evidence"
        "Standard in expert systems and uncertainty quantification")
      (why-bradford-hill
        "Observational studies dominate in epidemiology, economics, social science"
        "RCTs often unethical or infeasible for causal questions"
        "Bradford Hill criteria are standard assessment framework since 1965"
        "Provides structured approach to subjective causal judgment")
      (why-causal-dags
        "Visual representation of causal assumptions for communication and critique"
        "d-separation provides testable implications of causal structure"
        "Backdoor/frontdoor criteria identify when effects are estimable"
        "Foundation for do-calculus and identification theory")
      (why-granger-causality
        "Time series data requires different causal framework than cross-sectional"
        "Granger causality standard in econometrics, neuroscience, finance"
        "Prediction-based definition pragmatic for temporal processes"
        "Complements DAG methods which assume no feedback loops")
      (why-propensity-scores
        "Observational studies ubiquitous in social sciences and medicine"
        "Propensity scores reduce high-dimensional confounding to single score"
        "Matching approximates randomization for treatment effect estimation"
        "Doubly-robust methods combine outcome regression and propensity scores")
      (why-do-calculus
        "Interventional distributions differ from observational (Pearl's 'do' operator)"
        "Identification rules determine when effects computable from data"
        "Rigorous mathematical framework for causal reasoning"
        "Unifies backdoor, frontdoor, and instrumental variable approaches")
      (why-counterfactuals
        "Interventions answer 'what if everyone did X?' but not 'was X necessary for Y?'"
        "Counterfactuals required for causal explanation and attribution"
        "Mediation analysis and fairness require counterfactual reasoning"
        "Completes Pearl's causal hierarchy (association, intervention, counterfactual)")
      (why-explicit-structure
        "Automated causal discovery has strong untestable assumptions"
        "Domain knowledge about causality superior to algorithmic discovery"
        "Explicit structure makes assumptions transparent and debatable"
        "Separates causal assumptions from statistical estimation")
      (why-minimal-dependencies
        "Fewer dependencies reduce maintenance burden and security surface"
        "Julia ecosystem provides needed graph and statistical primitives"
        "Causal inference not performance-critical - clarity over speed"
        "Easier to audit and verify correctness without C/Python layers")
      (why-no-glm-initially
        "Simple logistic regression sufficient for basic propensity scores"
        "Avoiding dependency reduces installation complexity"
        "Users can always fit propensity models externally and pass scores"
        "Can add GLM integration later if demand exists")
      (why-no-causal-discovery
        "Causal discovery algorithms (PC, FCI) require strong assumptions"
        "Causal sufficiency assumption (no unmeasured confounders) often violated"
        "Discovery computationally expensive and results fragile"
        "Focus on estimation given structure - more practical for most users"))))

;; Helper function
(define (get-adr id)
  (let ((adrs (assoc-ref meta 'architecture-decisions)))
    (assoc-ref adrs id)))
