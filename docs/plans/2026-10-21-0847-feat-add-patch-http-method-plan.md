---
title: Add @Patch HTTP Method - Plan
type: feat
date: 2026-10-21
artifact_contract: ce-unified-plan/v1
product_contract_source: ce-plan-bootstrap
execution: code
---

# Add @Patch HTTP Method - Plan

## Goal Capsule

- **Objective:** A developer using cinch can declare a `PATCH` endpoint on a service the same way they declare `GET`, `POST`, `PUT`, and `DELETE`, and the generated client sends a real HTTP PATCH request.
- **Means:** A `Patch` annotation handled by `Service.request()` like `Put` (KTD1).
- **Authority:** Product Contract wins on behavior; Planning Contract wins on mechanism; units override neither.
- **Stop conditions:** Stop and ask if `cinch_gen` turns out to need generator changes for `@Patch` (research found none), or if `dio.patch` cannot take the same arguments as `dio.put`.
- **Execution profile:** Code change in `packages/cinch` and `packages/cinch_gen`, test-first for the `Service.request()` branch.
- **Finish and ship:** The implementer lands the change; releasing to pub.dev is a separate step (see Scope Boundaries).

---

## Product Contract

### Summary

Add an `@Patch` annotation to `cinch`. A method annotated with it is sent as an HTTP PATCH, with path, query, header, `@Body`, and `@Field` handling identical to `@Put`. Multipart is not supported in this version.

### Problem Frame

cinch lists GET, POST, PUT, and DELETE as its supported methods, so an API that uses PATCH for partial updates cannot be described with cinch annotations. Several doc comments already mention PATCH (for example on `Body`), which suggests it was expected to work. Today a user has to fall back to calling `dio` directly for those endpoints.

### Requirements

- R1. A public `Patch` annotation exists with the same shape as `Put`: a required `path` and an optional `validateStatus` list.
- R2. A service method annotated with `@Patch(path)` sends an HTTP PATCH to that path, with path parameters, query parameters, headers, `@Body`, and `@Field` handled the same way as for `@Put`.
- R3. `@Patch` does not support multipart. This matches `@Put` and `@Delete`; only `@Post` supports it today.
- R4. `cinch_gen` generates the client method for an `@Patch` method with the same output shape as for the other methods.
- R5. The README and the `cinch` changelog list PATCH as a supported method.

### Key Decisions

- **No multipart for `@Patch` in this version.** (session-settled: user-directed — chosen over matching `@Post` or extending `@Put` as well: keeps the change minimal and consistent with `@Put`; revisit together with `@Put` if an API needs file upload on update.) Governs R3.

### Scope Boundaries

- Not built: multipart support for `@Patch` or `@Put` (R3).
- Not built: JSON Patch or JSON Merge Patch helpers; `@Body` already carries any payload shape the caller serializes.
- Not changed: the generator's detection of `Http` subclasses.

#### Deferred to Follow-Up Work

- Publishing the new `cinch` version and a matching `cinch_gen` release. This needs the `tatsuyuki25` GitHub account active for the push and the pub.dev publish, then a switch back to `eb-tatsuyuki`.

---

## Planning Contract

### Key Technical Decisions

- KTD1. **`Patch extends Http`, handled by a new `method is Patch` branch in `Service.request()` that calls `dio.patch` with the same arguments as the `Put` branch** (`options`, `data: body ?? data`, `queryParameters: query`). `cinch_gen` needs no change, because it recognizes methods through a `TypeChecker` on the `Http` base type. Serves R1, R2, R3, R4.
- KTD2. **Bump `cinch` to 6.2.0 (minor; new public API) with a changelog entry, but do not touch `cinch_gen`'s version in this change.** The `cinch_gen` release is bundled with the unreleased constraint changes already on `master` and happens at publish time. Serves R5.
- KTD3. **Test `Service.request()` through its public `httpClientAdapter` setter with a recording fake adapter**, since `Service` exposes it and no `cinch` tests exist yet. This avoids network calls and checks the real HTTP method and payload dio would send.

### Research Notes

- `Put` and `Delete` ignore `@multipart`: only the `Post` branch builds `FormData`. A `@multipart` + `@Part` method on `@Patch` therefore behaves as it does on `@Put` today.
- `packages/cinch/lib/cinch.dart` exports `cinch_annotations.dart`, so `Patch` becomes public without export changes.
- The root `README.md` and `packages/cinch/README.md` both carry the "Supported HTTP Methods" list.

---

## Implementation Units

### U1. Add the `Patch` annotation and the request branch

- **Goal:** `@Patch` exists and `Service.request()` sends PATCH.
- **Requirements:** R1, R2, R3 (KTD1, KTD3)
- **Dependencies:** none
- **Files:** `packages/cinch/lib/src/cinch_annotations.dart`, `packages/cinch/lib/src/cinch_service.dart`, `packages/cinch/test/cinch_service_test.dart` (new)
- **Approach:**
  - Add `Patch` next to `Put`, with the same doc-comment style and constructor shape.
  - Add the `method is Patch` branch beside the `Put` branch.
  - Create a small test `Service` subclass and a recording `HttpClientAdapter` that returns a canned JSON response and keeps the last `RequestOptions`.
- **Execution note:** Write the failing request-dispatch test first.
- **Patterns to follow:** The `Put` class and branch.
- **Test scenarios:**
  - `@Patch('users/{id}')` with a `@Path('id')` argument sends method `PATCH` to the substituted path.
  - `@Patch` with a `@Body` argument sends that object as the request data.
  - `@Patch` with `@Field` arguments sends the fields as the data map.
  - `@Patch` with `@Query` arguments sends them as query parameters.
  - `@Patch('x', validateStatus: [404])` treats a 404 response as success.
  - Regression: `@Put` still sends method `PUT`.
  - `@Patch` combined with `@Get` on one method throws the existing "Only one HTTP method can be set." error.
- **Verification:** The new tests pass and `dart analyze` reports no new issues in `packages/cinch`.

### U2. Cover `@Patch` in the generator test

- **Goal:** Confirm `cinch_gen` produces the client method for `@Patch` without generator changes.
- **Requirements:** R4 (KTD1)
- **Dependencies:** U1
- **Files:** `packages/cinch_gen/test/src/part_input.dart`
- **Approach:**
  - Add one `@Patch` method to `TestService` and extend the expected `@ShouldGenerate` output with its generated `_$` method, formatted as the current generator emits it.
- **Test scenarios:**
  - A `@Patch('...')` method with a `@Path` and a `@Body` (or `@Field`) argument appears in the generated `_$TestService` with the same `request(<dynamic>[const Patch(...)], [...])` shape as the other methods.
- **Verification:** `dart test` in `packages/cinch_gen` passes. If the generator rejects `@Patch`, stop and report it (Goal Capsule stop condition).

### U3. Docs, changelog, and version

- **Goal:** The new method is documented and versioned.
- **Requirements:** R5 (KTD2)
- **Dependencies:** U1
- **Files:** `README.md`, `packages/cinch/README.md`, `packages/cinch/CHANGELOG.md`, `packages/cinch/pubspec.yaml`
- **Approach:**
  - Add `PATCH` to both "Supported HTTP Methods" lists (for example "Partially update existing resources") and, where useful, a short usage snippet.
  - Add a `## 6.2.0` changelog entry for `@Patch`.
  - Set the `cinch` version to 6.2.0.
  - Update every `cinch: ^...` dependency snippet in `README.md` and `packages/cinch/README.md` to `^6.2.0`.
- **Test expectation:** none -- documentation and version metadata only.
- **Verification:** Both README lists include PATCH, and the changelog and `pubspec.yaml` agree on 6.2.0.

---

## Verification Contract

| Check | Command | Applies to |
|---|---|---|
| `cinch` unit tests | `dart test` in `packages/cinch` | U1 |
| Generator test | `dart test` in `packages/cinch_gen` | U2 |
| Static analysis | `dart analyze` in `packages/cinch` and `packages/cinch_gen` | U1, U2 |

## Definition of Done

- R1 to R5 are met, and the U1 to U3 verifications pass.
- `cinch_gen` needed no generator code change, or the stop condition was raised.
- No experimental or abandoned code remains in the diff.
- Nothing is pushed or published as part of this work.
