# TypeScript Reference — Strict Functional Style

## 1. Naming and Case

- Files and directories: use kebab-case (for example, `user-service/`, `get-auth-token.ts`).
- Identifiers: use `camelCase` for variables and functions, `PascalCase` for type names.
- Directory-level unified exports: avoid `index.ts`; use a file named after the directory instead (for example, `user-service/user-service.ts`).

---

## 2. Paradigm Constraints (Functional Only)

Enforce a non-OOP, explicit-state functional style.

- **No `class` or `this`**: implement logic with pure functions and composition.
- **No `interface`**: prefer `type` aliases for all object shapes.
- **No pseudo-objects**: functions must not return objects that expose methods hiding internal state.
- **Pure functions**: operations must be explicit and operate on passed data.

### ❌ Disallowed (Pseudo-Object)

Do not return method-bearing objects to simulate classes:

```typescript
const getCounter = (initial: number) => ({
  getValue: () => initial,
  increment: () => initial + 1,
});
```

### ✅ Recommended (Pure Logic)

Model data as `type` and implement operations as independent functions:

```typescript
type Counter = { readonly count: number };

const getCounterValue = (counter: Counter) => counter.count;
const incrementCounter = (counter: Counter) => ({ ...counter, count: counter.count + 1 });
```

---

## 3. Function Implementation

- **Curried functions**: multi-argument functions must use nested unary arrow form: `(a) => (b) => ...`. This enables partial application and composition.
- **No `function` keyword**: use `const` with arrow functions only.
- **No explicit return types**: rely on TypeScript inference. Annotate only at module or public API boundaries.
- **Single-parameter objects**: when many parameters form a domain model, or when currying becomes genuinely unergonomic, accept a single record argument.

```typescript
// ✅ Curried
const fetchUserById = (userId: UserId) => (database: Database) => ...

// ✅ Domain-model record when parameters form a single cohesive concept
const createInvoice = (params: InvoiceParams) => ...
```

---

## 4. Type Implementation

- **Semantic aliases**: declare domain aliases for primitives (for example, `type StripeCustomerId = string`).
- **Immutability**: prefer `readonly` properties and immutable updates (`{ ...original, field: newValue }`).
- **Use `type`, not `interface`**: all object shapes must use `type` aliases.

---

## 5. Imports

- **Prefer namespace imports when many named imports are used**: if a module is imported with many individual named bindings, prefer a single namespace import with an alias. This keeps import lists readable, groups related APIs under a clear namespace, and makes it easier to refactor or rename usages.

  ❌ Wrong (many named imports):

```typescript
import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
```

  ✅ Right (namespace alias):

```typescript
import * as fs from 'fs';

const files = fs.readdirSync('/tmp');
const content = fs.readFileSync('/tmp/file.txt', 'utf8');
```

  Another common example for utility libraries:

```typescript
// Wrong
import { map, filter, reduce, cloneDeep } from 'lodash';

// Right
import * as _ from 'lodash';
```

---

## TypeScript Checklist

- [ ] Are `class`, `this`, and `interface` fully avoided?
- [ ] Are pseudo-objects avoided (no returned method-bearing objects)?
- [ ] Are files and directories named in kebab-case?
- [ ] For directory-level unified exports, is `index.ts` avoided in favor of a same-name file?
- [ ] Are multi-argument functions curried with nested arrow functions?
- [ ] Are explicit return types omitted (inferred, except at public API boundaries)?
- [ ] Are domain primitives wrapped in semantic type aliases?
- [ ] Are object shapes immutable (`readonly`)?
