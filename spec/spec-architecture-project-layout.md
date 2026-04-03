---
title: RSS Reader Project Architecture and Directory Layout Specification
version: 1.0
date_created: 2026-04-03
last_updated: 2026-04-03
owner: Platform and Core Team
tags: [architecture, monorepo, clean-architecture, purescript, solid, hono]
---

# Introduction

This specification defines the project-wide architecture, repository layout, effect interpretation boundaries, and build workflow for the RSS Reader system. It merges system-level constraints with core-layer architecture rules so that implementation and review can rely on one authoritative architecture document.

## 1. Purpose & Scope

Purpose:
- Define the full-stack architecture that combines PureScript core logic with platform-specific delivery layers.
- Standardize repository layout and dependency direction in a monorepo.
- Preserve a strict separation between business logic and infrastructure.

Scope:
- Monorepo structure and package responsibilities.
- Clean Architecture dependency direction across Core, Glue, and Apps.
- Run-based dependency injection and effect interpretation model.
- Build and workflow constraints with Spago and Turborepo.
- FFI and data-boundary contracts.

Out of scope:
- Concrete implementation code for adapters and interpreters.
- Product-level UI behavior and visual design.
- Detailed deployment manifests.

## 2. Definitions

- SSOT: Single Source of Truth for shared types and rules.
- BFF: Backend for Frontend composition layer for delivery-specific concerns.
- Core: Pure business domain and use cases, platform-agnostic.
- Glue: Anti-corruption and assembly layer that interprets Run effects.
- Apps: Delivery layer applications built with framework-specific technology.
- Run monad: Extensible effect model using row-polymorphic effect signatures.

## 3. Requirements, Constraints & Guidelines

- REQ-001: The project shall follow Clean Architecture with strict dependency direction.
- REQ-002: Core business logic shall be implemented in PureScript and remain platform-agnostic.
- REQ-003: Side effects shall be modeled as Run effect instructions and interpreted outside Core.
- REQ-004: The repository shall be organized as a monorepo with pnpm workspaces and Spago workspace support.
- REQ-005: Frontend and backend delivery stacks shall consume Glue exports rather than Core internals directly.
- REQ-006: Shared domain types and validation rules shall be reused as SSOT between web and server flows.
- CON-001: `packages/core` shall not include FFI (`foreign import`) declarations.
- CON-002: Glue exports for JavaScript consumers shall not expose PureScript ADTs (`Maybe`, `Either`, `Aff`).
- CON-003: Core module boundaries shall remain strict:
  - `Core.Entity`: data structures and sub-domains only.
  - `Core.Port`: effect instruction contracts and smart constructors only.
  - `Core.UseCase`: pure logic and orchestration workflows only.
- CON-004: Core use cases shall not import concrete infrastructure adapters.
- CON-005: Build orchestration shall prevent concurrent `purs` lock collisions.
- GUD-001: Use row-polymorphic Run signatures to keep dependencies explicit.
- GUD-002: Keep app-layer files thin and focused on transport/render mapping.

## 4. Interfaces & Data Contracts

Repository layout contract:

```text
rss-reader/
├── pnpm-workspace.yaml
├── spago.yaml
├── turbo.json
├── packages/
│   ├── core/
│   ├── adapter-fetch/
│   ├── glue-web/
│   └── glue-server/
└── apps/
    ├── web/
    └── server/
```

Layer responsibilities:

| Layer | Primary Responsibility | Allowed Dependencies | Forbidden Dependencies |
|---|---|---|---|
| Core (`packages/core`) | Domain entities, ports, use cases | PureScript libraries and domain modules | Framework/runtime-specific adapters, FFI |
| Glue (`packages/glue-web`, `packages/glue-server`) | Run interpreters and boundary translation | Core + platform impl/adapters | UI/network framework business logic |
| Apps (`apps/web`, `apps/server`) | Delivery and transport orchestration | Glue package exports | Direct dependency on Core internals |

Core module boundary contract:

| Module | Responsibility | Allowed Content | Forbidden Content |
|---|---|---|---|
| `Core.Entity` | Domain model and sub-domain data | ADTs, newtypes, records | Effectful behavior, I/O |
| `Core.Port` | External capability contracts | Effect functors, smart constructors, shared error ADT | DB/HTTP concrete adapters |
| `Core.UseCase` | Business rules and orchestration | Pure functions, Run workflows | Adapter wiring, framework-specific code |

FFI and boundary conversion contract:
- `Maybe` to JavaScript `null` via nullable conversion.
- `Aff` to JavaScript `Promise` for async interop.
- Records to JavaScript objects through stable JSON mapping strategy.

## 5. Acceptance Criteria

- AC-001: Given any core module import graph, when analyzed, then dependencies follow `Entity <- Port <- UseCase` constraints.
- AC-002: Given a use case with external interactions, when implemented, then it emits Run effects and does not call infrastructure directly.
- AC-003: Given JavaScript-facing Glue APIs, when inspected, then no PureScript-specific ADTs are exposed in exported signatures.
- AC-004: Given `packages/core`, when inspected, then no `foreign import` declarations exist.
- AC-005: Given build orchestration, when Turbo runs full build, then PureScript compilation order prevents lock conflicts.
- AC-006: Given app packages, when dependency graphs are inspected, then apps depend on Glue packages rather than Core internals.

## 6. Test Automation Strategy

- Test Levels: Unit (pure logic), contract (ports/interpreters), integration (Glue-to-App boundary), end-to-end (delivery flows).
- Frameworks: PureScript test runner for Core and interpreter contract suites; JavaScript test stack for app-level boundaries.
- Test Data Management: Deterministic fixtures for URL normalization, parser outcomes, effect interpreter stubs, and boundary serialization.
- CI/CD Integration: `pnpm turbo run build` and test pipelines with cache-aware task graph.
- Coverage Requirements: Near-complete coverage for pure core logic; high branch coverage for error mapping and boundary conversion.
- Performance Testing: Validate scheduler throughput and sync execution behavior on large feed/article datasets.

## 7. Rationale & Context

The architecture isolates business policy from delivery concerns, maximizing testability and portability. Run-based effect modeling keeps use-case dependency surfaces explicit and composable. The monorepo strategy enables shared type contracts and build-level coordination across PureScript and JavaScript ecosystems.

## 8. Dependencies & External Integrations

### External Systems
- EXT-001: RSS and HTML content endpoints.

### Third-Party Services
- SVC-001: No mandatory managed service at architecture-spec level.

### Infrastructure Dependencies
- INF-001: Repository, HTTP, and time interpreters in Glue/adapter layers.
- INF-002: Node.js runtime for server and build execution.

### Data Dependencies
- DAT-001: RSS XML payloads.
- DAT-002: Article HTML payloads.

### Technology Platform Dependencies
- PLT-001: PureScript for core domain and use-case logic.
- PLT-002: Run monad effect model.
- PLT-003: Solid + Vite for web delivery.
- PLT-004: Hono + Node.js for server delivery.
- PLT-005: pnpm workspaces + Turborepo + Spago for dependency and build orchestration.

### Compliance Dependencies
- COM-001: No explicit regulatory requirement in current architecture scope.

## 9. Examples & Edge Cases

```purescript
-- Explicit effect dependency declaration in Core use cases
subscribeFeed
  :: forall r
   . String
  -> Run (repo :: REPO, http :: HTTP, time :: TIME | r) (Either AppError FeedId)
```

```text
-- Build ordering intent (illustrative)
build:ps(core) -> build:ps(glue-*) -> build(apps)
```

Edge cases:
- Non-HTML article fetch responses must be rejected at boundary mapping.
- Orphan bookmarked articles must survive feed unsubscribe lifecycle.
- Cross-package path shortcuts used in development must not break production module resolution.

## 10. Validation Criteria

- Architecture dependency rules are checkable from import graphs.
- Core layer compiles without platform-specific or FFI contamination.
- Glue API signatures are JavaScript-native at boundary level.
- Build graph enforces deterministic and collision-safe PureScript compilation order.

## 11. Related Specifications / Further Reading

- `spec/core/spec-design-core-model.md`
- `spec/core/spec-design-core-interfaces.md`
- `spec/core/spec-process-core-use-cases.md`
