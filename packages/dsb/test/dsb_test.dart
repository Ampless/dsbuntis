import 'package:dsb/dsb.dart';
import 'package:schttp/schttp.dart';
import 'package:tested/tested.dart';

// TODO: proper tests

final http = ScHttpClient();

Iterable<TestCase> publicTestCases(
  String username,
  String password,
) =>
    [
      assertTestCase(() => Session.authcheck(username, password, http: http)),
      () => Session.login(username, password, http: http).then((x) => x.getTimetables()),
      () => Session.login(username, password, http: http).then((x) => x.getDocuments()),
      () => Session.login(username, password, http: http).then((x) => x.getNews()),
    ];

void main() {
  tests([
    ...publicTestCases('187801', 'public'),
    ...publicTestCases('152321', 'krsmrz21'), //THANKS @3liFi!
  ]);
}
