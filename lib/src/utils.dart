int max(List<int> i) {
  if (i == null || i.isEmpty) return null;
  var j = i[0];
  for (var k in i) {
    if (j < k) j = k;
  }
  return j;
}

int min(List<int> i) {
  if (i == null || i.isEmpty) return null;
  var j = i[0];
  for (var k in i) {
    if (j > k) j = k;
  }
  return j;
}

String errorString(dynamic e) {
  if (e is Error) return '$e\n${e.stackTrace}';
  return e.toString();
}

bool strcontain(String s1, String s2) {
  if (s1 == null) return s2 == null;
  if (s2 == null) return false;
  s1 = s1.toLowerCase();
  s2 = s2.toLowerCase();
  return s1.contains(s2) || s2.contains(s1);
}

String removeLastChars(String s, int i) => s.substring(0, s.length - i);
