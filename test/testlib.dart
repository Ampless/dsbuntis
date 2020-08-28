import 'package:test/test.dart';

typedef testCase = Future<Null> Function();

void tests(List<testCase> testCases, String groupName) {
  group(groupName, () {
    var i = 1;
    for (var testCase in testCases) test('case ${i++}', testCase);
  });
}
