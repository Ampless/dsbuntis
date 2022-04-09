import 'dart:convert';
import 'dart:typed_data';

import 'package:dsb/dsb.dart' as dsb;
import 'package:schttp/schttp.dart';
import 'package:untis/untis.dart' as untis;

// TODO: add A LOT more documentation (also check readmes)
class Page extends untis.Page {
  String url;
  String previewUrl;
  Uint8List? preview;
  // TODO: more data from dsb

  Page(untis.Day? day, List<untis.Substitution> subs, String date, this.url,
      this.previewUrl, this.preview)
      : super(day, subs, date);

  Page.from(untis.Page p, this.url, this.previewUrl, this.preview)
      : super(p.day, p.subs, p.date);

  Page.fromJson(dynamic json)
      : url = json['url'],
        previewUrl = json['preview_url'],
        preview = json.containsKey('preview')
            ? Uint8List.fromList(List<int>.from(json['preview']))
            : null,
        super.fromJson(json);

  @override
  dynamic toJson() => super.toJson()
    ..addAll({
      'url': url,
      'preview_url': previewUrl,
      if (preview != null) 'preview': preview,
    });

  @override
  String toString([bool inclUrls = true]) => '$day${_cum(inclUrls)}: $subs';
  String _cum(bool iu) => iu ? '($url, $previewUrl)' : '';

  static Iterable<Iterable<Page>> plansFromJsonString(String json) =>
      jsonDecode(json).map<Iterable<Page>>(
          (p) => p.map<Page>(Page.fromJson) as Iterable<Page>);

  static Iterable<Iterable<Page>> searchInPlans(
    Iterable<Iterable<Page>> pages,
    bool Function(untis.Substitution) predicate,
  ) =>
      pages.map((p) => p.map((p) => Page(
          p.day,
          p.subs.where(predicate).toList(),
          p.date,
          p.url,
          p.previewUrl,
          p.preview)));
}

class DownloadingPage {
  String htmlUrl, previewUrl;
  String? id, dsbDate, dsbTitle;
  Future<String> html;
  Future<Uint8List>? preview;

  DownloadingPage(this.htmlUrl, this.previewUrl, this.html, this.preview,
      this.id, this.dsbDate, this.dsbTitle);

  Future<Page?> parse(
      [untis.ParserBuilder parser = untis.Substitution.fromUntis]) async {
    final up = untis.Page.parsePage(await html, parser);
    return up != null
        ? Page.from(up, htmlUrl, previewUrl, await preview)
        : null;
  }
}

extension Downloading on dsb.Session {
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

Future<List<List<Page>>> getAllSubs(
  String username,
  String password, {
  ScHttpClient? http,
  String endpoint = dsb.Session.defaultEndpoint,
  String previewEndpoint = dsb.Session.defaultPreviewEndpoint,
  bool downloadPreviews = false,
  untis.ParserBuilder parser = untis.Substitution.fromUntis,
}) async {
  final session = await dsb.Session.login(username, password,
      endpoint: endpoint,
      previewEndpoint: previewEndpoint,
      http: http ?? ScHttpClient());
  final dp = session
      .downloadPlans(await session.getTimetables(),
          downloadPreviews: downloadPreviews)
      .map((p) => p.map((p) => p.parse(parser)));
  final plans = <List<Page>>[];
  for (final p in dp) {
    final pages = <Page>[];
    for (final p in p) {
      final page = await p;
      if (page != null) pages.add(page);
    }
    if (pages.isNotEmpty) {
      plans.add(pages);
    }
  }
  return plans;
}

extension MergePlans on Iterable<Iterable<Page>> {
  Iterable<untis.Page> merge() =>
      where((e) => e.isNotEmpty).map((e) => untis.Page(e.first.day,
          e.map((p) => p.subs).reduce((a, b) => [...a, ...b]), e.first.date));
}
