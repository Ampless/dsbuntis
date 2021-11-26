## 7.0.1

* Enabled caching for `Session.login` with a TTL of 30 days, based on
[findings](https://twitter.com/pixelcmtd/status/1464213128682610706)
from [aggregamus](https://github.com/Ampless/aggregamus)

## 7.0.0

* Removed the `Session.fromToken` initializer in favor of a revised `Session` constructor
* Added `Session.defaultEndpoint` and `Session.defaultPreviewEndpoint` for getting those
* Got rid of `getAuthToken`, since it is trivial and rarely used
* [Better documentation](README.md)
* Migrated from `pedantic` to `lints` for linting
* Renamed `planParser` to `PlanParser` (that seems to be the new convention)
* Extracted `parsePlans` out of `Session` (which also makes it static), because it doesn't
depend on any of its members
* Added `Session.getJsonString` and `Session.getTimetableJsonString`
* Removed `Day.Null`, camel-cased the other values, and used `Day?` wherever needed.

## 6.1.0

* Added `Session.fromToken` for quick-and-dirty construction of `Session`s

## 6.0.1

* `schttp` 4 support

## 6.0.0

* Removed some deprecated APIs
* Added `Session.downloadPlans` and `Session.parsePlans`
(as replacements for the removed `Session.getAndParse`)
* Stripped all values that are `null` from the JSONs
* Changed `Substitution.compareTo` to not throw at all

## 5.1.0

* Split the code up (breaking if you used it wrong)
* Finally added the `Session` API
* Deprecated `getTimetableJson` and `getAndParse`
* We now accept JSON that doesn't contain certain nullable keys

## 5.0.0

* Made the `notes`, `orgTeacher` and `room` parameters in the `Substitution`
constructor named
* When loading `Substitution`s from JSON, `room` is no longer optional
* Renamed `getJson` to `getTimetableJson` to allow for supporting other data
types in the future

## 4.4.0

* Added support for selecting a plan parser (or making a custom one) through
the optional `parser` parameter of `getAllSubs` and `getAndParse`
* Made `Substitution.toString` also print the `room`
* `Substitution.toJson` now also includes the `room`
* More testing due to the addition of the `parser` parameter

## 4.3.0

* Added `Substitution.fromUntis` and a few others for parsing substitutions
* Fixed a bug in `getAuthToken`
* Added `room` to `Substitution`, because some plans include it

## 4.2.0

* Made all errors throw `Exception`s/`Error`s,
instead of returning `null` or throwing Strings

## 4.1.0

* Added an optional parameter to not include the URLs in `Plan.toString`

## 4.0.1

* Fixed a bug in `Plan.fromJson`

## 4.0.0

* Changed the behavior of `getAllSubs` to return `null`
instead of throwing `1` on error
* The caching was sometimes wrong from `3.1.0` to `3.3.0`, now it is fixed
* Also made the `endpoint` configurable in `getAllSubs`
* Made the `ScHttpClient` passed to `getAllSubs` named: `http` (we had to)
* Added the `downloadPreviews` to `getAndParse` and `getAllSubs` to
automatically download the preview from `previewUrl` into `preview`
(`Substitution`)
* Changed the `searchInPlans` implementation to be non-destructive
* The JSON methods now also load/save the preview for `Plan`
* Renamed `plansFromJson` to `plansFromJsonString`
and `plansToJson` to `plansToJsonString` (in `Plan`)
* Renamed `plansFromRawJson` to `plansFromJson`
and `plansToRawJson` to `plansToJson` (in `Plan`)
* All of the changes in schttp `3.0.0` and `3.1.0` (like proxies)

## 3.3.0

* Added the `previewUrl` to the `Plan` when getting from the API

## 3.2.0

* Addition of `plansToRawJson` and `plansFromRawJson`
* Testing for the new Mobile API based backend
* schttp 2

## 3.1.0

* Support for controlled caching through schttp 1.1
* You can now leave out the `ScHttpClient` from `getAllSubs`
* Removed unused dependencies

## 3.0.0

* Migrated to DSB's Mobile API, because the Android API is dead.

## 2.0.1

* Sound null-safety
* Fixed a few test cases

## 2.0.0-nullsafety.0

* Unsound null safety
* Minor API changes where they made sense

## 1.1.2

* There was another, smaller bug in the comparison.

## 1.1.1

* The comparison in the previous version was broken.

## 1.1.0

* Made `Substitution`s `Comparable`

## 1.0.0

Many breaking API changes, like:

* Renamed basically everything, because the names were so broken.
* Moved `plansToJson` and `plansFromJson` to `Plan`.
* Every `Substitution` now only contains one `lesson`.

## 0.5.0

* Removed unused parameters.

## 0.4.0

* `DsbPlan` now also has `url`, which is the URL that the plan was fetched from.

## 0.3.2

* Switched to `html_search` for searching in HTML.

## 0.3.1

* Fixed HTML Escape-Codes not being automatically unescaped.

## 0.3.0

* Added support for another substitution plan format, which also means changing
`DsbSubstitution`. (it seems like Untis 2021 changed something there)

## 0.2.0

* Added `dsbCheckCredentials`
* Renamed `dsbSortAllByHour` → `dsbSortByLesson`

## 0.1.9

* The datetime sent to DSB was wrong and fixed now.

## 0.1.8

* Safer code.

## 0.1.7

* More tests.

## 0.1.6

* Wrote some documentation.

## 0.1.2 – 0.1.5

* Fixed some coding style things.

## 0.1.1

* Fixed the naming of `hours` and `actualHours` (`lessons`, `actualLessons`).

## 0.1.0

* The initial release.
* It is mostly just 1:1 copied from Amplessimus.
* It can crawl DSB and parse Untis-HTML.
