## 0.2.1-alpha.1

- Upgraded to dsb `0.1.2-alpha.0`, dsbuntis `8.1.0-alpha.4` and schttp 5

## 0.2.0

- Simplified code because of new functions in `dsbuntis`
- Changed `--json` abbr to `-j`
- Added `--merge`/`-m` flag
- Removed the old `--timetable-json`/`-j` flag
- Added 3 new flags: `--timetables`/`-T`, `--documents`/`-D`, `--news`/`-N`

## 0.1.3

- Added the `--json`/`-J` option for getting JSONs other than the Timetable one.
This option is temporary and might be renamed, as well as `--timetable-json`/`-j`

## 0.1.2

- `--timetable-json`/`-j` now tries to prettify the Timetable JSON, if it can't,
it behaves like before
- Much better documentation
- Fixed a bug in the HTTP request logging where if `dsbuntis` was to issue a
`POST` request (which it currently doesn't), the `Body` would not have been
logged, the `URL` twice

## 0.1.1

- Introduced an ugly hack to reduce the time from the end of `main` until the
program actually exits (by calling `exit` manually)

## 0.1.0

- First release on `pub`
- Check Git for all the work leading up to it
