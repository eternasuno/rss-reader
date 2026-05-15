# AGENTS.md — rss-reader

## Quick start

```sh
pnpm install              # install all workspace deps
pnpm build                # turbo run build
pnpm test                 # turbo run test
pnpm check                # turbo run check (runs purs-tidy)
```

All commands run from root via Turbo. Workspace packages: `core`, `web`, `server`.

## Active package: `core` (PureScript 0.15)

Only `core/` has real code. `web/` and `server/` are empty stubs.

| Command | What it does |
|---|---|
| `pnpm --filter core build` | `spago build` — compiles PureScript to JS in `core/output/` |
| `pnpm --filter core test` | `spago test` — runs purescript-spec with auto-discovery (`Test\.Specs\..*`) |
| `pnpm --filter core check` | `purs-tidy check src/**/*.purs test/**/*.purs` — PureScript formatter check |
| `pnpm --filter core db:push` | `drizzle-kit push --force` |
| `pnpm --filter core db:studio` | `drizzle-kit studio` |

Browser entrypoint is `core/gateway` (`output/Gateway.Web/index.js`). It wires all adapters together and exports `Promise`-returning functions for JS/TS consumers. TypeScript types at `core/types/Gateway.Web.d.ts`.

The legacy compile artifact `output/Core/` does not exist — `core/package.json`'s `"./core"` export is unused.

## Architecture: Clean / Hexagonal with free monads

```
Entity/  →  Port/  →  Usecase/  →  Adapter/  (+ Infrastructure/)
```

- **Entity** — pure domain types, no deps
- **Port** — effect algebras as `Run` functors (interfaces)
- **Usecase** — business logic, depends only on Ports
- **Adapter** — interpreters wiring Ports to real effects (HTTP fetch, RxDB, Readability, Jina.ai)
- **Infrastructure** — JS-only side effects (RxDB init, DB schema)

All effects run inside the `Run` monad (free monad via `purescript-run`). Errors are a single `AppError` sum type wrapped in `Except`.

## Testing

- Framework: `purescript-spec` with auto-discovery (regex `Test\.Specs\..*` in `Test.Main`)
- Mocks: hand-written `Run` interpreters in `Test.Mock.*` — substitute each port with pure functions
- Artifacts: `.spec-results` (persisted test results for incremental runs)
- No FFI, no real DB, no network needed for tests

## Formatter & linter

| Tool | Scope | Config |
|---|---|---|
| **Biome** | JS, TS, JSON files | `biome.json` (space indent, single quotes, trailing es5 commas, lineWidth 98) |
| **purs-tidy** | PureScript (`.purs`) | No custom config file; run via `pnpm check` |

Run `pnpm check` before committing. Biome is VCS-aware — uses `.gitignore`.

## Style conventions (from `.github/copilot-instructions.md`)

- Use the `clean-code` skill for all development/review (see `.github/skills/clean-code/SKILL.md`)
- All docs and comments in English only
- Function names: verb phrases; Booleans: `is`/`has`/`can`/`should` prefix
- No abbreviations, no single-letter identifiers

## FFI pattern

JS files are co-located with their PureScript modules (same directory). Examples:
- `Adapter/HTTP/Fetch.purs` + `Fetch.js` (browser fetch)
- `Usecase/Identify.purs` + `Identify.js` (crypto.subtle SHA-256)
- `Usecase/URLNormalize.purs` + `URLNormalize.js` (URL constructor)
- `Adapter/Extractor/DOM.purs` + `DOM.js` (DOMParser)

## Environment

- Node 24, pnpm 10.33
- PureScript 0.15.x via `purescript` npm package
- Spago 1.x, purs-tidy 0.11.x
- RxDB 17.x for persistence, Mozilla Readability + Jina.ai for content extraction
- Devcontainer: Debian base, Node 24 installed via devcontainer features

## Known gotchas

- `core/output/` is gitignored but is the compiled JS entrypoint — build before consuming as a library
- `.spec-results` tracks test history — can cause stale pass/fail if test names change
- `Test.Specs.Usecase.SubscribeArticle` has 4/5 failing tests — likely a stale spec from a refactor (covered by `Test.Specs.Usecase.Article`)
- `web/` and `server/` are workspaces with no `package.json` or source code yet — just `.vscode/settings.json` with `biome.enabled: false`
