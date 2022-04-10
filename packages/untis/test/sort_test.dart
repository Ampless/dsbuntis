import 'package:untis/untis.dart';
import 'package:test/test.dart';

import '../../../testlib.dart';

TestCase sortTestCase(List<List> input, List<int> expected) => () async {
      if (input.length != expected.length) throw 'Invalid test.';
      final s = input.map((e) => Substitution(e[0], e[1], '', '')).toList()
        ..sort();
      for (var i = 0; i < s.length; i++) {
        expect(s[i].affectedClass, input[expected[i]][0]);
        expect(s[i].lesson, input[expected[i]][1]);
      }
    };

void main() {
  tests([
    sortTestCase(
      [
        ['11', 1],
        ['11', 3],
        ['11', 2],
      ],
      [0, 2, 1],
    ),
    sortTestCase(
      [
        ['12', 1337],
        ['5a', 12],
        ['10c', 12],
        ['8b', 2000000],
      ],
      [1, 3, 2, 0],
    ),
  ], 'sort');
}
