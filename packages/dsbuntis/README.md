# dsbuntis

This package allows you to crawl DSB's "Mobile API" and parse Untis's HTML.

## Usage

The one-stop function provided by this package is `getAllSubs`. You can call it
like this:

```dart
final plans = await getAllSubs('187801', 'public');
```

### Lower-level APIs

For everything more advanced than
[the optional arguments of `getAllSubs`](https://pub.dev/documentation/dsbuntis/latest/dsbuntis/getAllSubs.html),
you will have to reach into the lower-level APIs of the `dsb` and `untis`
packages. Please consult their documentation for details.

To log in, you call `Session.login`:

```dart
final session = await Session.login('187801', 'public');
```

To use an existing token, you pass it to the `Session` constructor:

```dart
final session = Session('13ccccbb-e6a8-466a-addc-00bba830c6cf');
```

Then you can get the timetable information:

```dart
final timetables = await session.getTimetables();
```

And download and parse the plans, with the extension provided by this package:

```dart
final plans = await session.downloadAndParsePlans(timetables);
```

### Caching and best practices

A very important feature in `dsbuntis` from the beginning has been good caching.
For documentation on how to set it up for the actual requests, please refer to
the `schttp` documentation, as it is the HTTP backend of `dsbuntis`. In recent
versions, however, you can aditionally cache the `Session` objects from `dsb`.
The "login" of DSBMobile is idempotent (as indicated by it being a `GET`
request) and always returns the same token. Therefore, you can cache the
`Session`'s `token` "forever".
