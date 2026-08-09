---
applyTo: "lib/data/**/*.dart"
---

# Data layer (services, repositories, models)

Layering is `service` (raw HTTP, one class per resource) → `repository`
(errors, aggregation, state) → view. **Views must never call a service directly.**

Full procedures: `.claude/skills/flutter-call-backend-endpoint/SKILL.md` and
`.claude/skills/flutter-add-cached-data/SKILL.md`. Read them before adding an
HTTP call or a cache entry.

## HTTP

Two helpers exist and are **not** interchangeable:

- `ApiServiceFactory` (injected) — all verbs, auto re-authenticates an expired
  token, sets JSON headers, throws on non-2xx. **This is the default.**
- `HttpApiServiceMixin` (`with`) — GET/PUT only, supports query parameters via
  `createUri(...)`, does **not** refresh an expired token, returns the raw
  `Response` for you to status-check.

Request bodies are always `jsonEncode(model)` — a `String`, not a `Map`.
`apiDelete(endpoint, id)` joins the path itself; pass the parts separately.
The base URL is hardcoded in both `api.service.factory.dart` and `api-mixin.dart`
— change both or neither.

## Errors

`ApiServiceFactory` throws a bare `Exception` and discards the status code and
body. User-facing messages are composed in the repository's `catch`, reported via
`NotifierService.notify(msg, isError: true)`, following every method in
`account.repository.dart`.

## Caching

`Caching` is an in-memory `List` with **no TTL, no eviction, and no persistence**.
It lives in the service layer. Every cached key needs an explicit
`caching.remove(key)` on the mutations that invalidate it — write the
invalidation in the same change, or you are shipping a stale-data bug. Values are
stored by reference; mutating a cached model mutates the cache.

## DI

Register new services and repositories by hand in `registerServices()` in
`lib/main.dart`. Do **not** add `@injectable` annotations — codegen is not wired up.
