enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

Day? dayFromInt(int i) => [-1, 5].contains(i) ? null : Day.values[i];
int dayToInt(Day? day) => day == null ? -1 : Day.values.indexOf(day);

Day? matchDay(String s) {
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
