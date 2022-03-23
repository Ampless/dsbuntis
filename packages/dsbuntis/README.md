# dsbuntis

[![pub points](https://badges.bar/dsbuntis/pub%20points)](https://pub.dev/packages/dsbuntis/score)

This package allows you to crawl DSB's "Mobile API" and parse Untis's HTML. 

## Usage

For a basic example on how to get your substitutions, please refer to the [example](doc/main.dart).

### Lower-level APIs (`Session`)

`getAllSubs` only accounts for the most basic usage. For a more customizable experience, you'll want
to use the `Session` API.

`Session`s are created in two ways: Logging in or using an existing token.

To log in, you call `Session.login`:

```dart
final session = await Session.login('187801', 'public');
```

To use an existing token, you previously (6.1) used `Session.fromToken`. Now, the `Session`
constructor allows for passing them:

```dart
final session = Session('13ccccbb-e6a8-466a-addc-00bba830c6cf');
```

Then you can get the JSON with timetable information:

```dart
final ttJson = await session.getTimetableJson();
```

And download and parse the plans:

```dart
final downloadingPlans = session.downloadPlans(ttJson);
final plans = await parsePlans(downloadingPlans);
```

### Caching and best practices

<!-- TODO: rephrase -->

A very important feature in `dsbuntis` from the beginning has been good caching. For documentation on
how to set it up for the actual requests, please refer to the `schttp` documentation, as it is the
HTTP backend of `dsbuntis`. From version 6 on, however, you can aditionally cache `Session`s.
[AFAIK](https://twitter.com/pixelcmtd/status/1464213128682610706) the login of DSBMobile is idempotent
(as indicated by it being a `GET` request) and always returns the same token. If it is, which you can
safely assume by now, you can cache the `Session`'s `token` forever. Otherwise you can still keep the
`Session` object around for a while.
