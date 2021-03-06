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
* Minor API where they made sense

## 1.1.2

* There was another, much smaller bug in the comparison.

## 1.1.1

* The comparison in the previous version was broken.

## 1.1.0

* `Substitution.compareTo`

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

* Switched to html_search for searching in HTML.

## 0.3.1

* Fixed HTML Escape-Codes not being automatically unescaped.

## 0.3.0

* Added support for another substitution plan format, which also means changing DsbSubstitution. (it seems like Untis 2021 changed something there)

## 0.2.0

* Added dsbCheckCredentials
* Renamed dsbSortAllByHour → dsbSortByLesson

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
