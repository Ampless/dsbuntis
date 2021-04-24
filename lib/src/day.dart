enum Day {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Null,
}

Day dayFromInt(int i) => Day.values[i == -1 ? 5 : i];
int dayToInt(Day day) => day == Day.Null ? -1 : Day.values.indexOf(day);

Day matchDay(String s) {
  if (s.isEmpty) return Day.Null;
  s = s.toLowerCase();
  if (s.contains('null') || s.contains('none')) {
    return Day.Null;
  } else if (s.contains('mo')) {
    return Day.Monday;
  } else if (s.contains('di') || s.contains('tue')) {
    return Day.Tuesday;
  } else if (s.contains('mi') || s.contains('wed')) {
    return Day.Wednesday;
  } else if (s.contains('do') || s.contains('thu')) {
    return Day.Thursday;
  } else if (s.contains('fr')) {
    return Day.Friday;
  } else {
    throw Error();
  }
}
