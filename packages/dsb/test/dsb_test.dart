import 'package:dsb/dsb.dart';

import '../../../testlib.dart';

// TODO: proper tests

TestCase publicTestCase(
  String username,
  String password,
) =>
    () => Session.login(username, password).then((x) => x.getTimetable());

List<TestCase> publicTestCases = [
  publicTestCase('187801', 'public'),
  publicTestCase('152321', 'krsmrz21'), //THANKS @3liFi!
];

void main() {
  tests(publicTestCases, 'public');
}
