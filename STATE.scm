;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Project state tracking for Causals.jl

(define-module (state causals)
  #:use-module (ice-9 match)
  #:export (state get-completion-percentage get-blockers get-milestone))

(define state
  '((metadata
      (version . "0.1.0")
      (schema-version . "1.0.0")
      (created . "2026-01-28")
      (updated . "2026-01-28")
      (project . "Causals.jl")
      (repo . "https://github.com/hyperpolymath/Causals.jl"))

    (project-context
      (name . "Causals.jl")
      (tagline . "Comprehensive causal inference toolkit - eclipsing existing Julia packages with unified implementations")
      (tech-stack . ("Julia" "LinearAlgebra" "Statistics" "Distributions" "Graphs" "StatsBase"))
      (target-platforms . ("Linux" "macOS" "Windows" "BSD")))

    (current-position
      (phase . "alpha")
      (overall-completion . 70)
      (components
        ((name . "Dempster-Shafer theory")
         (status . "implemented")
         (completion . 85)
         (notes . "MassAssignment, belief/plausibility, combination, discount, pignistic transform - needs more test coverage"))
        ((name . "Bradford Hill criteria")
         (status . "implemented")
         (completion . 80)
         (notes . "9-criterion assessment framework with verdict/confidence scoring - needs validation against literature"))
        ((name . "Causal DAGs")
         (status . "implemented")
         (completion . 85)
         (notes . "CausalGraph, d-separation, backdoor/frontdoor criteria, ancestors/descendants - core complete"))
        ((name . "Granger causality")
         (status . "implemented")
         (completion . 75)
         (notes . "Time series VAR models, F-tests, optimal lag selection - needs more robust statistical tests"))
        ((name . "Propensity scores")
         (status . "implemented")
         (completion . 70)
         (notes . "Matching, IPW, stratification, doubly-robust - basic implementations, needs advanced methods"))
        ((name . "Do-calculus")
         (status . "basic")
         (completion . 60)
         (notes . "Intervention framework and identification rules - needs complete Pearl's rules implementation"))
        ((name . "Counterfactuals")
         (status . "basic")
         (completion . 60)
         (notes . "Twin networks, necessity/sufficiency - skeletal implementation, needs full SCM integration"))
        ((name . "Documentation")
         (status . "good")
         (completion . 80)
         (notes . "Comprehensive README with examples, all modules documented, needs full API reference"))
        ((name . "Test coverage")
         (status . "moderate")
         (completion . 65)
         (notes . "27 tests covering basic functionality, needs edge cases and integration tests"))))

      (working-features
        "Dempster-Shafer evidence combination"
        "Bradford Hill causal assessment"
        "Causal DAG with backdoor criterion"
        "Granger causality tests for time series"
        "Propensity score matching"
        "Basic do-calculus interventions"
        "Counterfactual probability calculation"
        "Complete module exports"))

    (route-to-mvp
      (milestones
        ((name . "Core implementations")
         (target-date . "2026-01-28")
         (status . "complete")
         (items
           "✓ Dempster-Shafer module with evidence combination"
           "✓ Bradford Hill criteria assessment"
           "✓ Causal DAG structure and queries"
           "✓ Granger causality tests"
           "✓ Propensity score methods"
           "✓ Basic do-calculus and counterfactuals"
           "✓ Module exports and integration"))
        ((name . "Enhanced implementations")
         (target-date . "2026-02-15")
         (status . "in-progress")
         (items
           "Complete Pearl's do-calculus rules (all three)"
           "Full counterfactual SCM with exogenous variables"
           "Advanced propensity methods (kernel matching, CBPS)"
           "Sensitivity analysis for unmeasured confounding"
           "Instrumental variables support"))
        ((name . "Validation and testing")
         (target-date . "2026-02-28")
         (status . "planned")
         (items
           "Expand test suite to >85% coverage"
           "Add test vectors from causal inference literature"
           "Property-based tests for probability invariants"
           "Integration tests across modules"
           "Benchmarks against reference implementations"))
        ((name . "Documentation and examples")
         (target-date . "2026-03-10")
         (status . "planned")
         (items
           "Full API reference documentation"
           "Tutorial notebooks for each module"
           "Real-world case studies (epidemiology, economics, ML)"
           "Comparison guide vs. CausalInference.jl"
           "Theory guide linking methods to literature"))
        ((name . "v0.2.0 Release")
         (target-date . "2026-03-31")
         (status . "planned")
         (items
           "All modules feature-complete"
           "Comprehensive test coverage"
           "Full documentation with examples"
           "Performance optimization"
           "Julia General registry submission"))))

    (blockers-and-issues
      (critical
        ())
      (high
        ("Do-calculus incomplete - missing rules 2 and 3 of Pearl's calculus"
         "Counterfactuals need full SCM implementation with exogenous variables"
         "Test coverage at 65% - needs expansion before v0.2.0"))
      (medium
        ("Granger causality needs more robust statistical tests (AIC/BIC, residual diagnostics)"
         "Propensity scores missing advanced methods (genetic matching, CBPS, entropy balancing)"
         "No sensitivity analysis for unmeasured confounding yet"
         "Bradford Hill needs validation against epidemiology literature"))
      (low
        ("No visualization support for DAGs yet (graphviz export planned)"
         "Performance profiling needed for large DAGs"
         "Missing instrumental variables implementation"
         "No integration with GLM.jl for regression adjustment")))

    (critical-next-actions
      (immediate
        "Complete Pearl's do-calculus rules 2 and 3"
        "Expand test coverage to 75%+ (focus on edge cases)"
        "Validate Bradford Hill scoring against literature examples")
      (this-week
        "Implement full counterfactual SCM with exogenous variables"
        "Add sensitivity analysis for unmeasured confounding"
        "Create tutorial notebook for each module")
      (this-month
        "Add advanced propensity score methods (CBPS, kernel matching)"
        "Implement instrumental variables"
        "Add DAG visualization export (Mermaid/GraphViz)"
        "Performance optimization and benchmarking"))

    (session-history
      ((date . "2026-01-28")
       (description . "Initial Causals.jl SCM file creation")
       (accomplishments
         "Analyzed existing codebase (7 modules, 27 tests)"
         "Created STATE.scm with accurate status tracking"
         "Identified working features and blockers"
         "Planned roadmap to v0.2.0 and registry submission")))))

;; Helper functions
(define (get-completion-percentage)
  (assoc-ref (assoc-ref state 'current-position) 'overall-completion))

(define (get-blockers)
  (assoc-ref state 'blockers-and-issues))

(define (get-milestone name)
  (let ((milestones (assoc-ref (assoc-ref state 'route-to-mvp) 'milestones)))
    (find (lambda (m) (equal? (assoc-ref m 'name) name)) milestones)))
