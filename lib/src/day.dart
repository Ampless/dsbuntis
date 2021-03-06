enum Day {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Null,
}

Day dayFromInt(int i) {
  switch (i) {
    case 0:
      return Day.Monday;
    case 1:
      return Day.Tuesday;
    case 2:
      return Day.Wednesday;
    case 3:
      return Day.Thursday;
    case 4:
      return Day.Friday;
    case -1:
      return Day.Null;
    default:
      throw UnimplementedError();
  }
}

int dayToInt(Day day) {
  switch (day) {
    case Day.Monday:
      return 0;
    case Day.Tuesday:
      return 1;
    case Day.Wednesday:
      return 2;
    case Day.Thursday:
      return 3;
    case Day.Friday:
      return 4;
    case Day.Null:
      return -1;
    default:
      throw UnimplementedError();
  }
}

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
    throw '[matchDay] Unknown day: $s';
  }
}
