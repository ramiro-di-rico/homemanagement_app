---
name: flutter-call-backend-endpoint
description: Call a backend API endpoint from a service, and surface its result or failure to the user. Use when adding or changing any HTTP call — the repo has two competing HTTP helpers and a specific error-to-toast path that is easy to get wrong.
---

# Calling a backend endpoint

The backend base URL is hardcoded in **two** places, and they must stay identical:
`Uri.https('www.ramiro-di-rico.dev', 'homemanagementapi/api/')` in
[api.service.factory.dart](../../../lib/data/services/api.service.factory.dart) and
[api-mixin.dart](../../../lib/data/services/api-mixin.dart). If you change one, change both.

## Pick the right helper

There are two, and they are not interchangeable:

| | `ApiServiceFactory` (injected) | `HttpApiServiceMixin` (`with`) |
|---|---|---|
| Verbs | get / post / put / patch / delete / upload | **get and put only** |
| Query params | no | yes, via `createUri(api, queryParameters: …)` |
| Auth | automatic — calls `autoAuthenticate()` if the token expired | none; you pass `authenticationService.getUserToken()` yourself |
| Headers | Authorization + Content-Type + Accept | Authorization only |
| Non-2xx | throws `Exception` for you | returns the raw `Response`; you check `statusCode` |

**Default to `ApiServiceFactory`.** Reach for the mixin only when you need query-string parameters or the raw `Response`. Note the auth asymmetry: the mixin does **not** refresh an expired token, so a mixin-based call can 401 where a factory call would have silently re-authenticated.

## Steps

1. **Service** — one class per resource in `lib/data/services/<name>.service.dart`, holding `final endpoint = '<resource>';`. Copy the shape of [account.service.dart](../../../lib/data/services/account.service.dart):
   ```dart
   Future<List<AccountModel>> fetchAccounts() async {
     var list = await this.apiServiceFactory.fetchList(endpoint);
     return list.map((e) => AccountModel.fromJson(e)).toList();
   }

   Future add(AccountModel model) async =>
       await this.apiServiceFactory.apiPost(endpoint, jsonEncode(model));
   ```
   Bodies are always `jsonEncode(model)` — pass a `String`, not a `Map`. `apiPut`/`apiPatch` are typed `String body`; `apiPost` is `dynamic` but still expects encoded JSON.
2. **Deserialize in the service, not the repository.** The service returns domain/data models; the repository never sees raw JSON.
3. **Repository** — wrap every mutating call in `try/catch` and report through `NotifierService`, the pattern every method in [account.repository.dart](../../../lib/data/repositories/account.repository.dart) follows:
   ```dart
   try {
     await service.add(model);
     notifyListeners();
     notifierService.notify('X added successfully');
   } catch (ex) {
     notifierService.notify('Failed to add X', isError: true);
   }
   ```
   The repository extends `ChangeNotifier` and holds the list the views render — mutate the in-memory list and call `notifyListeners()` after a successful write instead of re-fetching.
4. **Register both** in `registerServices()` in [main.dart](../../../lib/main.dart) — see [flutter-new-feature](../flutter-new-feature/SKILL.md).
5. `flutter analyze`.

## Gotchas

- `ApiServiceFactory` throws a bare `Exception('Failed to post to $api')` — the status code and response body are **discarded** for every verb except `uploadWithReturn`, which appends the body. Any user-facing message must be composed in the repository's `catch`; you cannot branch on 404 vs 500 without changing the factory first.
- `apiDelete(api, id)` builds `'$api/$id'` itself — pass the endpoint and the id separately, not a pre-joined path.
- **File uploads use `_getAuthHeaders()`, not `_getHeaders()`.** `MultipartRequest` sets its own `Content-Type` with the multipart boundary; overwriting it with `application/json` leaves the server unable to parse the form. Use `upload()` / `uploadWithReturn()` rather than hand-rolling a multipart request.
- New user-facing strings from step 3 go through [flutter-add-locale-string](../flutter-add-locale-string/SKILL.md) — the existing `notify(...)` calls are hardcoded English, which is a known gap, not the pattern to follow for new code.
