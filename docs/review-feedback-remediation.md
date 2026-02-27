# Review Feedback Remediation

## 1) SwiftLint opt-in rules coverage and ordering

- Added `fatal_error_message`, `overridden_super_call`, `redundant_string_enum_value`, and `trailing_comma`.
- Enforced alphabetical ordering for `opt_in_rules` to reduce merge noise and make drift obvious in reviews.

## 2) Tighter function size and complexity thresholds

- Tightened `function_body_length` from `80/150` to `60/100` (`warning/error`).
- Tightened `cyclomatic_complexity` from `15/25` to `12/20` (`warning/error`).
- Purpose: nudge code toward smaller, easier-to-review functions before complexity spikes.

## 3) Identifier exclusions for common loop counters

- Added `i`, `j`, and `k` to `identifier_name.excluded` (alongside `id`, `x`, `y`).
- This keeps lint signal focused on meaningful naming issues instead of common index variables.

## 4) Workflow action pinning for supply-chain hardening

- Replaced mutable action tags (`@v*`) with immutable full commit SHAs in:
  - `.github/workflows/ci.yml`
  - `.github/workflows/release.yml`
- Validation approach: rely on normal GitHub Actions execution in CI after merge/push.
