---
name: clean-code
description: "General engineering design guidelines emphasizing naming intent, cohesive directory structure, type-driven flows, and self-documenting code."
---

# Clean Code Skill — Universal Code Principles

## 1. Naming Philosophy

Code communicates intent through names alone. Every identifier must answer: "What does this hold or do, and why does it matter?"

### Functions — Use Verb Phrases

Functions perform actions. Names must be verb phrases that describe what the function does.

- Use: `fetchUserById`, `calculateMonthlyTotal`, `validateEmailFormat`
- Avoid nouns or vague names: `userById`, `process`, `handle`

### Variables — Use Intention-Revealing Nouns

A variable name must describe the concept, not the type.

- Use: `activeSubscriptions`, `daysSinceLastLogin`
- Avoid generic or cryptic names: `data`, `n`, `result`

### Booleans — Use `is` / `has` / `can` / `should` Prefix

- Use: `isEmailVerified`, `hasActiveSubscription`, `canProcessRefund`, `shouldRetryOnFailure`
- Avoid: `verified`, `active`, `retry`

### Types and Errors — Descriptive PascalCase Nouns

- Types describe domain concepts: `MonthlyInvoice`, `StripeCustomerId`
- Error names must describe the failure condition, not the mechanism: `UserNotFoundError`, `PaymentGatewayTimeoutError`
- Avoid generic error names: `NotFoundError`, `ApiError`

### No Abbreviations

Spell names in full. IDEs provide autocomplete; abbreviation destroys readability.

- Use: `organizationIdentifier`, `maximumRetryAttempts`, `requestTimestampMs`
- Avoid: `orgId`, `maxRetry`, `reqTs`

### No Single-Letter Identifiers

Single-letter names are forbidden outside mathematical formulas. Every binding must carry a domain-meaningful name.

- Use: `activeUsers.filter((user) => user.isActive)`
- Avoid: `users.filter((u) => u.a)`

---

## 2. File and Directory Structure

Project layout should reflect logical boundaries, not only technical categories.

- **Single responsibility per file**: each file represents one cohesive feature or unit.
- **Directory cohesion**: group related files by domain (for example, `validators/` contains only validation logic).
- **File size limit**: keep files under 150 lines. A file approaching this limit signals multiple concerns — decompose by functionality.
- **Small functions**: keep functions under 20 logical lines. Larger functions indicate missing decomposition.

---

## 3. Type-Driven Design

Define data and contracts before implementing logic.

- **Model first**: create data models and explicit error variants before writing any function.
- **Adhere to contracts**: implementations must strictly follow type definitions.
- **One level of abstraction**: orchestration functions must not see implementation details.

---

## 4. Comment Policy

- **Code is documentation**: prefer clear naming and structure over comments.
- **English only**: any necessary comments must be written in English.
- **No emoji** in code or documentation.
- If a comment feels necessary, the code or name typically needs improvement instead.

---

## 5. Language-specific References

This skill is a top-level guideline. Always consult the `references/` folder for language-specific rules. Language-specific rules take precedence over this skill for formatting and style.

| File | Language | Scope |
|------|----------|-------|
| [`references/typescript.md`](references/typescript.md) | TypeScript | Curried functional style, type aliases, immutability, paradigm constraints (no class, no interface) |

---

## Checklist

- [] **Naming**: Do functions use verb phrases? Do variables answer "what and why"? No abbreviations? Booleans prefixed?
- [] **Structure**: Does each file have a single cohesive responsibility? Functions under 20 lines? Files under 150 lines?
- [] **Order**: Are types and contracts defined before implementation?
- [] **Comments**: Are comments minimal, in English, and without emoji?
- [] **References**: Have language-specific rules in `references/` been consulted?
