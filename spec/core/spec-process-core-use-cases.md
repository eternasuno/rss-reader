---
title: RSS Reader Core Use Case Specification
version: 1.0
date_created: 2026-04-03
last_updated: 2026-04-03
owner: Core Domain Team
tags: [process, core, use-cases, orchestration, pure-logic]
---

# Introduction

This specification defines the core business use cases, including pure logic functions and Run-based orchestration workflows.

## 1. Purpose & Scope

Purpose:
- Define behavior contracts for subscription, reading, and syncing workflows.
- Separate deterministic pure logic from effectful orchestration.

Scope:
- `Core.UseCase.PureLogic`
- `Core.UseCase.Subscription`
- `Core.UseCase.Reading`
- `Core.UseCase.Syncing`

Out of scope:
- Adapter implementation and runtime wiring.
- UI-level interaction patterns.

## 2. Definitions

- Pure logic: Total or deterministic business computation without effects.
- Orchestration: Workflow composition across Repo/Http/Time effects.
- Sync diff: Computed change set between existing and fetched articles.
- Retention policy: Rule for physical deletion of old articles.

## 3. Requirements, Constraints & Guidelines

- REQ-001: URL normalization functions shall be pure and deterministic.
- REQ-002: Article identifier generation shall be derived from normalized article URL.
- REQ-003: Content extraction shall return either parsed payload or `AppError`.
- REQ-004: Sync diff calculation shall emit explicit actions (`ToInsert`, `ToUpdate`, `ToDelete`).
- REQ-005: Adaptive schedule calculation shall depend on new-content signal and unread pressure.
- REQ-006: Subscription and reading workflows shall orchestrate through Run effects.
- REQ-007: Sync workflow shall update articles, schedule, and retention state coherently.
- CON-001: Pure logic modules shall not reference effect rows or interpreter concerns.
- CON-002: Orchestration signatures shall declare only required effects.
- CON-003: Unsubscribe workflow shall preserve independent starred/bookmarked content.
- GUD-001: Keep use cases small and composable.

## 4. Interfaces & Data Contracts

Pure logic contracts:

```purescript
normalizeFeedUrl :: String -> FeedUrl
normalizeArticleUrl :: String -> ArticleUrl
generateArticleId :: ArticleUrl -> ArticleId
extractContent :: ArticleUrl -> String -> Either AppError ContentPayload

data SyncAction = ToInsert Article | ToUpdate Article | ToDelete ArticleId

calculateSyncDiff :: List Article -> List Article -> List SyncAction

calculateNextSchedule
  :: Minutes
  -> Boolean
  -> Int
  -> Int
  -> Minutes
```

Subscription contracts:

```purescript
subscribeFeed
  :: forall r
   . String
  -> Run (repo :: REPO, http :: HTTP, time :: TIME | r) (Either AppError FeedId)

unsubscribeFeed
  :: forall r
   . FeedId
  -> Run (repo :: REPO | r) Unit
```

Reading contracts:

```purescript
addBookmarkDirectly
  :: forall r
   . String
  -> Run (repo :: REPO, http :: HTTP, time :: TIME | r) (Either AppError ArticleId)

toggleReadStatus
  :: forall r
   . ArticleId
  -> Run (repo :: REPO, time :: TIME | r) Unit

toggleStarStatus
  :: forall r
   . ArticleId
  -> Run (repo :: REPO | r) Unit
```

Syncing contracts:

```purescript
syncSingleFeed
  :: forall r
   . FeedId
  -> Run (repo :: REPO, http :: HTTP, time :: TIME | r) (Either AppError Unit)

fetchDueFeeds
  :: forall r
   . Run (repo :: REPO, http :: HTTP, time :: TIME | r) Unit

enforceRetentionPolicy
  :: forall r
   . FeedId
  -> Run (repo :: REPO | r) Unit
```

## 5. Acceptance Criteria

- AC-001: Given the same input URL, when normalization runs repeatedly, then output is identical.
- AC-002: Given fetched and existing article lists, when sync diff is computed, then only explicit actions are emitted.
- AC-003: Given `subscribeFeed`, when network probe fails, then the result is `Left AppError` and no inconsistent persistence state is committed.
- AC-004: Given `unsubscribeFeed`, when executed, then feed-owned normal articles are removed and independent bookmarks remain valid.
- AC-005: Given `syncSingleFeed`, when new articles are found, then schedule and retention policy are both applied in the same workflow.
- AC-006: Given an orphan article with star toggled off, when policy requires deletion, then physical deletion is triggered.

## 6. Test Automation Strategy

- Test Levels: Unit tests for pure logic, integration tests for orchestration with stub interpreters.
- Frameworks: PureScript test framework in workspace.
- Test Data Management: Fixture sets for URL cases, RSS payloads, and article diffs.
- CI/CD Integration: Run pure and integration suites in standard build pipeline.
- Coverage Requirements: Target full branch coverage for pure logic and error pathways.
- Performance Testing: Validate `fetchDueFeeds` behavior with large due-feed sets.

## 7. Rationale & Context

The split between pure logic and orchestration maximizes testability and maintainability. Pure functions form the decision engine, while orchestration provides explicit interaction with external capabilities.

## 8. Dependencies & External Integrations

### External Systems
- EXT-001: RSS and article web resources.

### Third-Party Services
- SVC-001: No mandatory third-party service in use-case contracts.

### Infrastructure Dependencies
- INF-001: Repository interpreter.
- INF-002: HTTP interpreter.
- INF-003: Time interpreter.

### Data Dependencies
- DAT-001: Feed URL and article URL inputs from user/system scheduling.
- DAT-002: RSS and HTML payloads used for parsing and extraction.

### Technology Platform Dependencies
- PLT-001: Run monad for effect orchestration.
- PLT-002: PureScript functional module system.

### Compliance Dependencies
- COM-001: No explicit compliance dependency in this scope.

## 9. Examples & Edge Cases

```purescript
-- Adaptive schedule behavior sketch
calculateNextSchedule currentInterval hasNewContent unreadCount unreadThreshold
```

Edge cases:
- Invalid URL input should fail early in subscribe/bookmark flows.
- Sync with zero fetched items should still evaluate retention and schedule transitions.
- Toggle operations on missing article IDs should map to consistent not-found handling.

## 10. Validation Criteria

- All listed function signatures exist in corresponding modules.
- Pure logic functions compile without effect dependencies.
- Orchestration functions expose minimal effect rows.
- Acceptance criteria are covered by automated tests.

## 11. Related Specifications / Further Reading

- `spec/spec-architecture-project-layout.md`
- `spec/core/spec-design-core-model.md`
- `spec/core/spec-design-core-interfaces.md`
