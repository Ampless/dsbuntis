enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

// The fact that this has to exist is a shame, but the Dart team is to blame,
// not me: https://github.com/dart-lang/language/issues/723
const dayFromInt = DayImpl.fromInt;
int dayToInt(Day d) => d.toInt();
const matchDay = DayImpl.match;

extension DayImpl on Day {
  static Day? fromInt(int? i) =>
      i == null || [-1, 5].contains(i) ? null : Day.values[i];

  int toInt() => Day.values.indexOf(this);

  static Day? match(String s) {
    if (s.isEmpty) return null;
    s = s.toLowerCase();
    if (s.contains('null') || s.contains('none')) {
      return null;
    } else if (s.contains('mo')) {
      return Day.monday;
    } else if (s.contains('di') || s.contains('tue')) {
      return Day.tuesday;
    } else if (s.contains('mi') || s.contains('wed')) {
      return Day.wednesday;
    } else if (s.contains('do') || s.contains('thu')) {
      return Day.thursday;
    } else if (s.contains('fr')) {
      return Day.friday;
    } else {
      throw Error();
    }
  }
}
