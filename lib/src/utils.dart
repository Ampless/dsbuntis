//TODO: remove this file in next major

@deprecated
int max(List<int> i) {
  var j = i[0];
  for (final k in i) {
    if (j < k) j = k;
  }
  return j;
}

@deprecated
int min(List<int> i) {
  var j = i[0];
  for (final k in i) {
    if (j > k) j = k;
  }
  return j;
}

@deprecated
String errorString(dynamic e) {
  if (e is Error) return '$e\n${e.stackTrace}';
  return e.toString();
}

@deprecated
bool strcontain(String s1, String s2) {
  s1 = s1.toLowerCase();
  s2 = s2.toLowerCase();
  return s1.contains(s2) || s2.contains(s1);
}

@deprecated
String removeLastChars(String s, int i) => s.substring(0, s.length - i);
