import 'package:test/test.dart';

typedef TestCase = Future Function();

TestCase expectTestCase<T>(
  Future<T> Function() tfunc,
  T expct,
  bool error,
) =>
    () async {
      T res;
      try {
        res = await tfunc();
      } catch (e) {
        if (!error) {
          rethrow;
        } else {
          return;
        }
      }
      if (error) throw '[ETC($tfunc, $expct)] No error.';
      expect(res, expct);
    };

TestCase Function(A, B, bool) functionTestCase<A, B>(B Function(A) tfunc) =>
    (A input, B expct, bool error) =>
        expectTestCase(() async => tfunc(input), expct, error);

void tests(List<TestCase> testCases, String groupName) {
  group(groupName, () {
    var i = 1;
    for (var testCase in testCases) {
      test('case ${i++}', testCase);
    }
  });
}
