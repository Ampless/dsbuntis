## 0.5.0

* Removed unused parameters

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
