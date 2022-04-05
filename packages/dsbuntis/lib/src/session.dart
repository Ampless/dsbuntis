import 'dart:typed_data';

import 'package:dsb/dsb.dart' as dsb;
import 'package:dsbuntis/src/plan.dart';
import 'package:untis/untis.dart' as untis;

class DownloadingPlan {
  String htmlUrl, previewUrl;
  String? id, dsbDate, dsbTitle;
  Future<String> html;
  Future<Uint8List>? preview;

  DownloadingPlan(this.htmlUrl, this.previewUrl, this.html, this.preview,
      this.id, this.dsbDate, this.dsbTitle);

  Future<Plan?> parse(
      [untis.PlanParser parser = untis.Substitution.fromUntis]) async {
    final up = untis.Plan.parsePlan(await html, parser);
    return up != null
        ? Plan.from(up, htmlUrl, previewUrl, await preview)
        : null;
  }
}

extension UntisParsing on dsb.Session {
  // TODO: completely rework this
  Iterable<DownloadingPlan> downloadPlans(
    List json, {
    bool downloadPreviews = false,
  }) =>
      json
          .map((p) => p['Childs'])
          .reduce((v, e) => [...v, ...e])
          .where((x) => !x['Detail'].endsWith('.png'))
          .where((x) => !x['Detail'].endsWith('.jpg'))
          .map<DownloadingPlan>((p) => DownloadingPlan(
              p['Detail'],
              p['Preview'],
              http.get(p['Detail'],
                  ttl: Duration(days: 4), defaultCharset: String.fromCharCodes),
              downloadPreviews
                  ? http.getBin('$previewEndpoint/${p['Preview']}')
                  : null,
              p['Id'],
              p['Date'],
              p['Title']));
}
