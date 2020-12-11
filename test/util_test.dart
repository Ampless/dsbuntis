import 'package:dsbuntis/dsbuntis.dart';

import 'testlib.dart';

testCase utilTestCase(
        List<int> input, int output, int Function(List<int>) func) =>
    expectTestCase(() async => func(input), output, false);

main() {
  tests([
    utilTestCase([-12, 1337, -33, 0], -33, min),
    utilTestCase([-12, 1337, -33, 0], 1337, max),
  ], 'util');
}
