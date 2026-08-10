---
name: flutter-add-cached-data
description: Cache an API response in the in-memory store, and invalidate it when the underlying data changes. Use when adding caching to a service or when a screen shows stale data after a write — invalidation here is fully manual and there is no TTL.
---

# Caching an API response

[caching.dart](../../../lib/data/services/caching.dart) is a **plain `List<Cache>` of key/value pairs** registered as a GetIt singleton in [main.dart](../../../lib/main.dart). Understand its limits before using it:

- **No TTL and no eviction.** An entry lives until someone calls `remove(key)` or the app restarts. Nothing expires on its own.
- **Not persisted.** Memory only — it does not survive a restart.
- **`fetch()` returns `dynamic`** and `null` when missing, so every read needs an `as T` cast.
- **`add()` removes the existing key first**, so re-adding is safe and is the idiomatic way to overwrite.
- Lookup is a linear scan. Fine for the dozens of entries in play, not for thousands.

## Where caching lives

In the **service** layer, not the repository — see [metrics.service.dart](../../../lib/data/services/metrics.service.dart), `category.service.metric.dart`, and `dashboard.service.dart`. The repository stays unaware that a response was cached.

## Steps

1. Take `Caching caching;` as a constructor parameter on the service and pass `GetIt.I<Caching>()` at its registration in `registerServices()`.
2. Declare the key as a field: `String cacheKey = 'overall';`. For per-entity entries, compose by concatenation the way `MetricService` does — `var key = cacheKey + accountId.toString();`. Keep the base key as a prefix so related entries are greppable.
3. Guard the fetch, then populate:
   ```dart
   if (this.caching.exists(key)) {
     return this.caching.fetch(key) as Overall;
   }
   var response = await httpGet(createUri('account/overall'), authenticationService.getUserToken());
   if (response.statusCode == 200) {
     var result = Overall.fromJson(json.decode(response.body));
     caching.add(key, result);
     return result;
   }
   throw Exception('Failed to fetch overall.');
   ```
   Only cache on success — never cache an error or an empty fallback.
4. **Write down the invalidation, in the same change.** Ask: which mutations make this key wrong? Every one of them must call `caching.remove(key)` (or `add` the fresh value). A cached read with no invalidation path is a stale-data bug you are shipping, not a performance win.
5. Because keys are composed by string concatenation, invalidating "all entries for account 7" means removing each composed key explicitly — there is no prefix/wildcard removal. If you need that, add it to `Caching` rather than open-coding a scan at the call site.
6. `flutter analyze`, then exercise the write path in the running app and confirm the screen reflects the change — a missing invalidation only shows up at runtime.

## Gotcha

Cached objects are stored **by reference**. If a view mutates a model it got from the cache, the cached entry changes too, and a later `fetch` returns the mutated object as if it came from the server. Either treat cached values as immutable or `add` a fresh copy after mutating.
