import 'package:test/test.dart';

typedef testCase = Future Function();

testCase expectTestCase<T>(
  Future<T> Function() tfunc,
  T expct,
  bool error,
) =>
    () async {
      T res;
      try {
        res = await tfunc();
      } catch (e) {
        if (!error)
          rethrow;
        else
          return;
      }
      if (error) throw '[ETC($tfunc, $expct)] No error.';
      expect(res, expct);
    };

void tests(List<testCase> testCases, String groupName) {
  group(groupName, () {
    var i = 1;
    for (var testCase in testCases) test('case ${i++}', testCase);
  });
}
