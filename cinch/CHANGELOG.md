# Cinch changelog

## 5.0.1

- Add Default content-type: `application/json`.

## 5.0.0

- Add `Body` annotation to allow API body to accept JSON objects.
- Update dependencies:
  - `dio: ^5.8.0+1`
  - `meta: ^1.16.0`

## 4.1.1

- Updated package versions.

## 4.1.0

- Add Header annotation

## 4.0.0

- Update Dart SDK to 3.0.0
- *BREAK CHANGE*:
  - Remove `Pair`、`Triple`。

## 3.0.0

- Update dio to 5.0.0
- Http method add `validateStatus`.
- Service Add params `sendTimeout` and `validateStatus`.

## 2.2.2

- Add Super Class with param.

## 2.2.1

- Fix List type Field & Query.

## 2.2.0

- update dio
- remove check Field and FormUrlEncoded

## 2.1.1

- dio with test public

## 2.1.0

- Query and Field support List data and keepNull

## 2.0.1

- remove char

## 2.0.0

- Support Nullsafety
- Update Dio version

## 1.4.1

- Fix return type to `Response`

## 1.4.0

- Separate generate pub `cinch_gen`

## 1.3.8

- fix analysis issue

## 1.3.7

- support js

## 1.3.6

- 擴大支援範圍

## 1.3.5

- 修正錯誤

## 1.3.4

- 修正錯誤

## 1.3.3

- 更新library
- 修正錯誤

## 1.3.2

- 增加`ApiService.uncheckUrl()` 忽略Url檢查

## 1.3.1

- Service 繼承 ApiUrlMixin

## 1.3.0

- 增加ApiUrlMixin

## 1.2.0

- 更新dio

## 1.1.4+1

- 更新dio

## 1.1.4

- 修復未加上`<dynamic>`問題

## 1.1.3

- 增加`transformer`功能

## 1.1.2

- 修改程式碼符合code style及lint

## 1.1.1

- 增加設置`httpClientAdapter`功能

## 1.1.0

### Fix

- 修正拼音錯誤`formUrlEncoded`

### Feature

- 支援`Multipart`，並可上傳檔案

## 1.0.9

- 更新pub

## 1.0.8

- 增加支援 `httpClientAdapter`

## 1.0.7

- 更新版本^0.34.0

## 1.0.6

- 增加修改URL功能
