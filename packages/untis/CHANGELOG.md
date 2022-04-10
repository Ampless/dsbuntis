## 0.1.0-alpha.6

- Added the `WhereNotNull` extension on `Iterable<T?>` to temporarily mitigate
the Dart language having problems
- Added `UnknownDayException` to throw from `Day.match`/`matchDay`
- Got a proper Haiku
- Removed the `isFree` attribute from `Substitution` and made it a getter instead
- Added the `date` to the `toString` of `Page` (why wasn't it there?!)

## 0.1.0-alpha.5

- Fixed some incorrect tests (oh god)
- Fixed parser throwing when the raw lesson doesn't end with a letter
- Got rid of the multi-file architecture

## 0.1.0-alpha.4

- Introduced the new `Parser`/`ParserBuilder` API to allow for smarter parsing

## 0.1.0-alpha.3

- Removed `Page.toJson`, `Page.toJsonString`, `Page.fromJson` and `Page.fromJsonString`,
because they were practically unnecessary

## 0.1.0-alpha.2

- Renamed `Plan` → `Page`

## 0.1.0-alpha.1

- Made `Substitution.raw` more robust to empty classes

## 0.1.0-alpha.0

- Initial attempt at making a DSB independent Untis parser
