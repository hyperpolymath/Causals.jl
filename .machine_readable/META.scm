; SPDX-License-Identifier: MPL-2.0
; (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
; Causals.jl - Meta Information

(meta
  (philosophy
    "Provide rigorous, well-tested causal inference methods for Julia")

  (architecture-decisions
    (decision
      (title "Symbol-based graph API")
      (status accepted)
      (context "CausalGraph uses Symbol node names instead of integer indices")
      (rationale "More readable and less error-prone for users")
      (date "2026-02-12"))

    (decision
      (title "MPL-2.0 license (Julia ecosystem fallback)")
      (status accepted)
      (context "Use MPL-2.0 as required by Julia/GNAT ecosystem; PMPL-1.0-or-later preferred")
      (rationale "Julia ecosystem requires OSI-approved license")
      (date "2026-03-14")))

  (development-practices
    "All exported functions must have docstrings"
    "All functions must have test coverage"
    "Examples must demonstrate real use cases"))
