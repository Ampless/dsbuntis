# Accemus

> Tool for fetching substitution plans from DSB/DSBMobile and parsing Untis
> HTML, as well as debugging dsbuntis.

> More information: <https://github.com/Ampless/Adsignificamus#1-the-mobile-api>.

- List your substitution plans in the current `dsbuntis` JSON format:

`accemus {{187801}} {{public}}`

- List your substitution plans and print all HTTP requests made while doing so:

`accemus --log-requests {{id}} {{password}}`

- Only log into DSB and print the session:

`accemus --login-only {{id}} {{password}}`

- Get the Timetable JSON of your substitution plans from DSB:

`accemus --timetable-json {{id}} {{password}}`

- Try to get substitutions from another DSB server and, if it fails, print full stack traces for debugging:

`accemus --endpoint={{https://dsb.example.org}} --preview-endpoint={{https://images.example.org/dsbpreviews}} --stack-traces {{id}} {{password}}`

## Installation

```sh
dart pub global activate accemus
```
