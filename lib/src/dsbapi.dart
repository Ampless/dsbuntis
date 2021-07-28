import 'dart:async';

import 'package:dsbuntis/src/plan.dart';
import 'package:dsbuntis/src/session.dart';
import 'package:dsbuntis/src/sub.dart';
import 'package:schttp/schttp.dart';

Future<String> getAuthToken(
  String username,
  String password,
  ScHttpClient http, {
  String endpoint = 'https://mobileapi.dsbcontrol.de',
  String appVersion = '36',
  String osVersion = '30',
}) =>
    Session.login(
      username,
      password,
      http: http,
      endpoint: endpoint,
      appVersion: appVersion,
      osVersion: osVersion,
    ).then((session) => session.token);

Future<List<Plan>> getAllSubs(
  String username,
  String password, {
  ScHttpClient? http,
  String endpoint = 'https://mobileapi.dsbcontrol.de',
  String previewEndpoint = 'https://light.dsbcontrol.de/DSBlightWebsite/Data',
  bool downloadPreviews = false,
  planParser parser = Substitution.fromUntis,
}) async {
  final session = await Session.login(username, password,
      endpoint: endpoint,
      previewEndpoint: previewEndpoint,
      http: http ?? ScHttpClient());
  return session.getAndParse(await session.getTimetableJson(),
      downloadPreviews: downloadPreviews, parser: parser);
}
