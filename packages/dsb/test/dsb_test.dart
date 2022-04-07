import 'package:dsb/dsb.dart';

import '../../../testlib.dart';

// TODO: proper tests

List<TestCase> publicTestCases(
  String username,
  String password,
) =>
    [
      () => Session.login(username, password).then((x) => x.getTimetables()),
      () => Session.login(username, password).then((x) => x.getDocuments()),
      () => Session.login(username, password).then((x) => x.getNews()),
    ];

void main() {
  tests([
    ...publicTestCases('187801', 'public'),
    ...publicTestCases('152321', 'krsmrz21'), //THANKS @3liFi!
  ], 'public');
}
