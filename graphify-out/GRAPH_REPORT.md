# Graph Report - cinch  (2026-10-27)

## Corpus Check
- 29 files · ~12,335 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 376 nodes · 410 edges · 18 communities (16 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0a1e117e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Cinch changelog
- example2_service.dart
- cinch_generator.dart
- example_service.dart
- cinch_service.dart
- cinch_service_test.dart
- Cinch
- cinch_annotations.dart
- Cinch
- cinch_gen changelog
- Add @Patch HTTP Method - Plan
- cinch_generator_test.dart
- ApiService
- cinch.dart
- source_write.dart
- cinch_gen
- CHANGELOG.md
- example.dart

## God Nodes (most connected - your core abstractions)
1. `Cinch changelog` - 42 edges
2. `cinch_gen changelog` - 19 edges
3. `Cinch` - 10 edges
4. `Post` - 9 edges
5. `Cinch` - 9 edges
6. `Parameter` - 8 edges
7. `Advanced Features` - 8 edges
8. `Http` - 7 edges
9. `Add @Patch HTTP Method - Plan` - 7 edges
10. `Key Features` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Example2Service` --configures--> `ApiService`  [EXTRACTED]
  example/lib/example2_service.dart → packages/cinch/lib/src/cinch_annotations.dart
- `getArea` --configures--> `Get`  [EXTRACTED]
  example/lib/example2_service.dart → packages/cinch/lib/src/cinch_annotations.dart
- `upload` --configures--> `Post`  [EXTRACTED]
  example/lib/example2_service.dart → packages/cinch/lib/src/cinch_annotations.dart
- `multiUpload` --configures--> `Post`  [EXTRACTED]
  example/lib/example2_service.dart → packages/cinch/lib/src/cinch_annotations.dart
- `generic` --configures--> `Post`  [EXTRACTED]
  packages/cinch/example/test_service.dart → packages/cinch/lib/src/cinch_annotations.dart

## Import Cycles
- None detected.

## Communities (18 total, 2 thin omitted)

### Community 0 - "Cinch changelog"
Cohesion: 0.04
Nodes (44): 1.0.6, 1.0.7, 1.0.8, 1.0.9, 1.1.0, 1.1.1, 1.1.2, 1.1.3 (+36 more)

### Community 1 - "example2_service.dart"
Cohesion: 0.06
Nodes (37): @multipart, errMsg, Example, multiUpload, OtherAnnotation, Response, retCode, toString (+29 more)

### Community 2 - "cinch_generator.dart"
Cohesion: 0.05
Nodes (36): DartType, package:analyzer/dart/constant/value.dart, package:analyzer/dart/element/element.dart, package:analyzer/dart/element/type.dart, package:build/build.dart, package:source_gen/source_gen.dart, cinch, _buildFromJsonExpression (+28 more)

### Community 3 - "example_service.dart"
Cohesion: 0.07
Nodes (33): @Freezed, @gg, @JsonSerializable, _, fromJson, Global, Example, fromJson (+25 more)

### Community 4 - "cinch_service.dart"
Cohesion: 0.06
Nodes (33): cinch_annotations.dart, Dio, Duration, HttpClientAdapter get, Interceptors get, baseUrl, connectTimeout, dio (+25 more)

### Community 5 - "cinch_service_test.dart"
Cohesion: 0.07
Nodes (28): dart:typed_data, Exception, HttpClientAdapter, Service, ApiUrlMixin, url, adapter, close (+20 more)

### Community 6 - "Cinch"
Cohesion: 0.07
Nodes (25): Advanced Features, Basic Usage, Best Practices, Cinch, Custom Headers, Custom Status Code Validation, Dynamic URL Configuration, Error Handling (+17 more)

### Community 7 - "cinch_annotations.dart"
Cohesion: 0.12
Nodes (24): getArea, List, patchUser, Body, Delete, emptyUrl, Field, _FormUrlEncoded (+16 more)

### Community 8 - "Cinch"
Cohesion: 0.09
Nodes (22): Basic Usage, Best Practices, Cinch, Custom Status Code Validation, Documentation, Dynamic URL Configuration, Error Handling, Features (+14 more)

### Community 9 - "cinch_gen changelog"
Cohesion: 0.10
Nodes (19): 1.0.0, 1.0.1, 1.0.2, 2.0.0, 2.1.0, 2.1.1, 2.1.2, 2.2.0 (+11 more)

### Community 10 - "Add @Patch HTTP Method - Plan"
Cohesion: 0.11
Nodes (18): Add @Patch HTTP Method - Plan, Deferred to Follow-Up Work, Definition of Done, Goal Capsule, Implementation Units, Key Decisions, Key Technical Decisions, Planning Contract (+10 more)

### Community 11 - "cinch_generator_test.dart"
Cohesion: 0.17
Nodes (9): main, main, package:cinch_gen/src/cinch_generator.dart, package:example/example.dart, package:path/path.dart, package:source_gen_test/source_gen_test.dart, package:test/test.dart, main (+1 more)

### Community 12 - "ApiService"
Cohesion: 0.29
Nodes (8): _, Example2Service, ExampleService, GeneratorForAnnotation, TestService, CinchGenerator, TestService, ApiService

### Community 13 - "cinch.dart"
Cohesion: 0.29
Nodes (6): library, package:dio/dio.dart, cinch, src/cinch_annotations.dart, src/cinch_service.dart, src/utils.dart

### Community 14 - "source_write.dart"
Cohesion: 0.40
Nodes (4): clear, _source, toString, Write

### Community 15 - "cinch_gen"
Cohesion: 0.40
Nodes (4): cinch_gen, License, 🚀 Migration Guide to v6.0.0, What You Need to Do

## Knowledge Gaps
- **238 isolated node(s):** `main`, `calculate`, `_`, `OtherAnnotation`, `Example` (+233 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Service` connect `cinch_service_test.dart` to `cinch_service.dart`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Why does `Http` connect `cinch_annotations.dart` to `example2_service.dart`, `cinch_service.dart`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Why does `Post` connect `example2_service.dart` to `cinch_annotations.dart`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **What connects `main`, `calculate`, `_` to the rest of the system?**
  _238 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Cinch changelog` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._
- **Should `example2_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06219512195121951 - nodes in this community are weakly interconnected._
- **Should `cinch_generator.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05405405405405406 - nodes in this community are weakly interconnected._