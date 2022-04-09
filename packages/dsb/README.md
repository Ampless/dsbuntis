# dsb

[![pub points](https://badges.bar/dsb/pub%20points)](https://pub.dev/packages/dsb/score)

This package allows you to crawl DSB's "Mobile API".

If you want a higher-level API and need to parse Untis, too, consider using
[dsbuntis](https://pub.dev/packages/dsbuntis).

## Usage

`Session`s are created in two ways: Logging in or using an existing token.

To log in, you call `Session.login`:

```dart
final session = await Session.login('187801', 'public');
```

To use an existing token, the `Session` constructor allows for passing them:

```dart
final session = Session('13ccccbb-e6a8-466a-addc-00bba830c6cf');
```

Then you can, for example, get the timetable information:

```dart
final timetables = await session.getTimetables();
```

### Caching and best practices

<!-- TODO: rephrase -->

A very important feature in `dsbuntis` from the beginning has been good caching. For documentation on
how to set it up for the actual requests, please refer to the `schttp` documentation, as it is our
HTTP backend. However, you can aditionally cache `Session`s.
[AFAIK](https://twitter.com/pixelcmtd/status/1464213128682610706) the login of DSBMobile is idempotent
(as indicated by it being a `GET` request) and always returns the same token. If it is, which you can
safely assume by now, you can cache the `Session`'s `token` forever. Otherwise you can still keep the
`Session` object around for a while.
