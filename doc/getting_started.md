# Getting Started – dsbuntis

There are multiple ways to use `dsbuntis`: The older function-based API and the
newer `Session` API.

## The simple, old, function-based API

From the initial API only 2 functions have stayed around: `getAuthToken` can be
used to just get a DSB auth token, this is useful for testing, if you want to
do the actual API requests yourself. If you just want to get your substitutions,
`getAllSubs` is where you should look.

## The new `Session` API

For more complicated invocations of `dsbuntis` you should use the `Session` API.
A new `Session` is instantiated by calling `Session.login`, then you can use its
methods, like `getJson` or `downloadPlans` to continue your journey.
