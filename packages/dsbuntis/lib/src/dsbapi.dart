import 'dart:async';

import 'package:dsb/dsb.dart' as dsb;
import 'package:dsbuntis/src/plan.dart';
import 'package:dsbuntis/src/session.dart';
import 'package:schttp/schttp.dart';
import 'package:untis/untis.dart' as untis;

Future<List<Plan>> getAllSubs(
  String username,
  String password, {
  ScHttpClient? http,
  String endpoint = dsb.Session.defaultEndpoint,
  String previewEndpoint = dsb.Session.defaultPreviewEndpoint,
  bool downloadPreviews = false,
  untis.PlanParser parser = untis.Substitution.fromUntis,
}) async {
  final session = await dsb.Session.login(username, password,
      endpoint: endpoint,
      previewEndpoint: previewEndpoint,
      http: http ?? ScHttpClient());
  final dp = session.downloadPlans(await session.getTimetableJson(),
      downloadPreviews: downloadPreviews);
  final plans = <Plan>[];
  for (final p in dp.map((p) => p.parse(parser))) {
    final plan = await p;
    if (plan != null) plans.add(plan);
  }
  return plans;
}
