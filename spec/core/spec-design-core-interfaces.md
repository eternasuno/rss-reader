---
title: RSS Reader Core Port Interfaces Specification
version: 1.0
date_created: 2026-04-03
last_updated: 2026-04-03
owner: Core Domain Team
tags: [design, core, ports, run-monad, contracts]
---

# Introduction

This specification defines the external capability contracts for the Core layer using Run effect instructions.

## 1. Purpose & Scope

Purpose:
- Define stable interfaces between business use cases and infrastructure concerns.

Scope:
- `Core.Port` effect instructions and smart constructor contracts.
- Shared application error model for core workflows.

Out of scope:
- Interpreter implementation details.
- Transport, persistence, and protocol adapter specifics.

## 2. Definitions

- Port: Abstract boundary describing required capability.
- Smart constructor: Helper function that emits effect instructions.
- Effect row: Row-polymorphic set of required effects for Run programs.

## 3. Requirements, Constraints & Guidelines

- REQ-001: Repository capabilities shall be defined as `RepoF` effect instructions.
- REQ-002: HTTP capabilities shall be defined as `HttpF` effect instructions.
- REQ-003: Time capability shall be defined as `TimeF` effect instructions.
- REQ-004: A shared `AppError` domain shall be used in effect return contracts.
- REQ-005: Smart constructors shall expose use-case-oriented signatures.
- CON-001: Ports shall not include interpreter logic.
- CON-002: Effect constructors shall remain deterministic data descriptions.
- GUD-001: Keep error variants explicit and domain-relevant.
- GUD-002: Keep effect signatures minimal and composable.

## 4. Interfaces & Data Contracts

Error contract:

```purescript
data AppError = NetworkError | ParseError | NotFound | ExtractError
```

Repository effect contract:

```purescript
data RepoF a
  = SaveFeed Feed a
  | DeleteFeed FeedId a
  | GetFeed FeedId (Maybe Feed -> a)
  | GetActiveFeeds DateTime (List Feed -> a)
  | SaveArticles (List Article) a
  | GetArticlesByFeed FeedId (List Article -> a)
  | UpdateArticleState ArticleId ArticleState a
  | DeleteOldArticles FeedId Int a

type REPO r = (repo :: Proxy RepoF | r)
```

HTTP effect contract:

```purescript
data HttpF a
  = FetchRSS FeedUrl (Either AppError String -> a)
  | FetchHtml ArticleUrl (Either AppError String -> a)

type HTTP r = (http :: Proxy HttpF | r)
```

Time effect contract:

```purescript
data TimeF a = Now (DateTime -> a)
type TIME r = (time :: Proxy TimeF | r)
```

Required smart constructor signatures:

```purescript
getFeed :: forall r. FeedId -> Run (REPO r) (Maybe Feed)
saveArticles :: forall r. List Article -> Run (REPO r) Unit
fetchRSS :: forall r. FeedUrl -> Run (HTTP r) (Either AppError String)
fetchHtml :: forall r. ArticleUrl -> Run (HTTP r) (Either AppError String)
now :: forall r. Run (TIME r) DateTime
```

## 5. Acceptance Criteria

- AC-001: Given any use case, when it needs repository access, then it depends on `REPO` effect row entries only.
- AC-002: Given feed or article fetch operations, when represented, then results use `Either AppError String`.
- AC-003: Given current-time access, when represented, then it uses the `Now` instruction via `TIME`.
- AC-004: Given core error handling, when implemented, then failures map to `AppError` variants.

## 6. Test Automation Strategy

- Test Levels: Contract tests for each smart constructor and interpreter behavior tests.
- Frameworks: PureScript tests in repository toolchain.
- Test Data Management: Stub interpreters for deterministic behavior.
- CI/CD Integration: Include port contract tests in standard CI pipeline.
- Coverage Requirements: Cover all effect constructors and error branches.
- Performance Testing: Validate interpreter throughput in integration-level benchmarks.

## 7. Rationale & Context

Run effect instructions keep use-case dependencies explicit while preserving composability. Shared error contracts simplify failure handling and ensure consistent behavior across workflows.

## 8. Dependencies & External Integrations

### External Systems
- EXT-001: Remote RSS and HTML endpoints accessed through HTTP interpreters.

### Third-Party Services
- SVC-001: None mandatory at specification level.

### Infrastructure Dependencies
- INF-001: Repository interpreter for persistent storage.
- INF-002: HTTP interpreter for network retrieval.
- INF-003: Time interpreter for deterministic time source in tests.

### Data Dependencies
- DAT-001: RSS XML strings.
- DAT-002: HTML document strings.

### Technology Platform Dependencies
- PLT-001: Run monad and row-polymorphic effects.
- PLT-002: PureScript type-level row support.

### Compliance Dependencies
- COM-001: No explicit compliance dependencies in port contract scope.

## 9. Examples & Edge Cases

```purescript
-- A use case can request only what it needs
syncSingleFeed
  :: forall r
   . FeedId
  -> Run (repo :: REPO, http :: HTTP, time :: TIME | r) (Either AppError Unit)
```

Edge cases:
- `FetchHtml` must reject non-HTML payloads through `AppError`.
- `GetFeed` returns `Nothing` if no matching feed exists.

## 10. Validation Criteria

- Every effect constructor has a corresponding interpreter test double.
- Smart constructor signatures compile and align with effect rows.
- Use cases compile against port contracts without direct adapter imports.

## 11. Related Specifications / Further Reading

- `spec/spec-architecture-project-layout.md`
- `spec/core/spec-design-core-model.md`
- `spec/core/spec-process-core-use-cases.md`
