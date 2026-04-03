---
title: RSS Reader Core Domain Model Specification
version: 1.0
date_created: 2026-04-03
last_updated: 2026-04-03
owner: Core Domain Team
tags: [design, core, domain-model, entities]
---

# Introduction

This specification defines the domain model for the RSS Reader Core layer, including value objects, state ADTs, sub-domains, and aggregate entities.

## 1. Purpose & Scope

Purpose:
- Provide an explicit, type-driven, implementation-ready data model.

Scope:
- Definitions under `Core.Entity`.
- Identifiers, URLs, state ADTs, sub-domain records, and aggregate records.

Out of scope:
- Behavior implementation.
- Persistence schema.
- Adapter-level serialization formats.

## 2. Definitions

- Value object: Immutable type encoding domain meaning.
- Primitive obsession: Overusing primitive types where domain-specific types are required.
- ADT: Algebraic data type representing closed domain states.
- Sub-domain: Cohesive conceptual area nested in an entity.

## 3. Requirements, Constraints & Guidelines

- REQ-001: Identifiers shall be modeled using newtypes.
- REQ-002: URL values shall be modeled using dedicated newtypes.
- REQ-003: Read and star status shall be modeled as ADTs.
- REQ-004: Article state shall be represented as a dedicated sub-domain record.
- REQ-005: Feed scheduling shall be represented as a dedicated sub-domain record.
- REQ-006: Article content payload shall be represented as a dedicated sub-domain record.
- CON-001: `Core.Entity` shall remain behavior-free.
- CON-002: `Article.feedId` may be absent to represent independent bookmarks.
- CON-003: `ArticleId` shall be derived from normalized article URLs (UUID v5 strategy).
- GUD-001: Keep all field semantics explicit and stable across use cases.

## 4. Interfaces & Data Contracts

Canonical domain model contracts:

```purescript
newtype FolderId = FolderId String
newtype FeedId = FeedId String
newtype ArticleId = ArticleId String

newtype FeedUrl = FeedUrl String
newtype ArticleUrl = ArticleUrl String

data ReadStatus = Read | Unread
data StarStatus = Starred | Unstarred

type ArticleState =
  { read :: ReadStatus
  , star :: StarStatus
  }

type FetchSchedule =
  { currentInterval :: Minutes
  , nextFetchAt :: DateTime
  , unreadThreshold :: Int
  , retentionLimit :: Int
  }

type ContentPayload =
  { title :: String
  , htmlBody :: String
  , textSnippet :: Maybe String
  }

type Folder =
  { id :: FolderId
  , name :: String
  , sortOrder :: Int
  }

type Feed =
  { id :: FeedId
  , folderId :: Maybe FolderId
  , title :: String
  , url :: FeedUrl
  , siteUrl :: String
  , schedule :: FetchSchedule
  }

type Article =
  { id :: ArticleId
  , feedId :: Maybe FeedId
  , url :: ArticleUrl
  , content :: ContentPayload
  , state :: ArticleState
  , publishedAt :: DateTime
  , savedAt :: DateTime
  }
```

## 5. Acceptance Criteria

- AC-001: Given any identifier type, when inspected, then it is represented as a dedicated newtype.
- AC-002: Given read/star status values, when modeled, then only ADT constructors are valid states.
- AC-003: Given an independently saved article, when modeled, then `feedId` is `Nothing`.
- AC-004: Given a feed entity, when modeled, then schedule metadata is encapsulated in `FetchSchedule`.

## 6. Test Automation Strategy

- Test Levels: Unit tests for value construction and normalization assumptions.
- Frameworks: PureScript tests in current workspace toolchain.
- Test Data Management: Shared fixtures for valid and edge-case entities.
- CI/CD Integration: Type check and tests executed in standard pipeline.
- Coverage Requirements: Full constructor and field-level contract coverage.
- Performance Testing: Not primary for data-only model; validate memory usage indirectly through use-case tests.

## 7. Rationale & Context

The model encodes domain meaning directly in types. This reduces invalid states, improves readability, and stabilizes business rules across use cases and adapters.

## 8. Dependencies & External Integrations

### External Systems
- EXT-001: None required at pure model layer.

### Third-Party Services
- SVC-001: None required at pure model layer.

### Infrastructure Dependencies
- INF-001: Date/time and duration primitive types used by the model.

### Data Dependencies
- DAT-001: URL and content values sourced from upstream HTTP/RSS processing.

### Technology Platform Dependencies
- PLT-001: PureScript type system features (newtype, ADT, records, Maybe).

### Compliance Dependencies
- COM-001: No explicit compliance dependency in this model scope.

## 9. Examples & Edge Cases

```purescript
-- Independent bookmarked article
{ id: articleId
, feedId: Nothing
, url: articleUrl
, content: payload
, state: { read: Unread, star: Starred }
, publishedAt: timestamp
, savedAt: timestamp
}
```

Edge cases:
- Empty `textSnippet` is represented as `Nothing`.
- Feed can exist without folder assignment (`folderId = Nothing`).

## 10. Validation Criteria

- All required contracts compile and expose expected fields.
- No behavior functions are added in `Core.Entity`.
- New domain states must extend ADTs rather than introducing booleans.

## 11. Related Specifications / Further Reading

- `spec/spec-architecture-project-layout.md`
- `spec/core/spec-design-core-interfaces.md`
- `spec/core/spec-process-core-use-cases.md`
