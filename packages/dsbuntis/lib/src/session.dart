import 'dart:typed_data';

import 'package:dsb/dsb.dart' as dsb;
import 'package:dsbuntis/src/page.dart';
import 'package:untis/untis.dart' as untis;

class DownloadingPage {
  String htmlUrl, previewUrl;
  String? id, dsbDate, dsbTitle;
  Future<String> html;
  Future<Uint8List>? preview;

  DownloadingPage(this.htmlUrl, this.previewUrl, this.html, this.preview,
      this.id, this.dsbDate, this.dsbTitle);

  Future<Page?> parse(
      [untis.Parser parser = untis.Substitution.fromUntis]) async {
    final up = untis.Page.parsePage(await html, parser);
    return up != null
        ? Page.from(up, htmlUrl, previewUrl, await preview)
        : null;
  }
}

extension Downloading on dsb.Session {
  // TODO: completely rework this
  Iterable<Iterable<DownloadingPage>> downloadPlans(
    Iterable<dsb.Item> timetables, {
    bool downloadPreviews = false,
  }) =>
      timetables.map((p) => p.childs).map<Iterable<DownloadingPage>>((p) => p
          .where((x) => x.conType == 6)
          .map((p) => DownloadingPage(
              p.detail,
              p.preview,
              http.get(p.detail,
                  ttl: Duration(days: 4), defaultCharset: String.fromCharCodes),
              downloadPreviews
                  ? http.getBin('$previewEndpoint/${p.preview}')
                  : null,
              p.id,
              p.date,
              p.title)));
}
