## 0.2.0-alpha.0

- Replaced `dayFromInt`, `dayToInt`, `matchDay` and `DayImpl` with methods on
`Day` (thanks Dart 2.17!)

## 0.1.1

- Optimized `Page.parsePage`
- Upgraded to `html_search` 0.3

## 0.1.0

- Initial attempt at making a DSB-independent Untis parser
- Renamed `Plan` → `Page`
- Added `UnknownDayException` to throw from `Day.match`/`matchDay`
- Removed the `isFree` attribute from `Substitution` and made it a getter instead
- Added the `date` to the `toString` of `Page` (why wasn't it there?!)
- Fixed some incorrect tests (oh god)
- Fixed parser throwing when the raw lesson doesn't end with a letter
- Introduced the new `Parser`/`ParserBuilder` API to allow for smarter parsing
- Removed `Page.toJsonString`, `Page.fromJsonString`
- Made `Substitution.raw` more robust to empty classes
- Made searching through `Page`s an `extension`
