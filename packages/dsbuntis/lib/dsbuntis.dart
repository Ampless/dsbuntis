import 'dart:convert';
import 'dart:typed_data';

import 'package:dsb/dsb.dart' as dsb;
import 'package:schttp/schttp.dart';
import 'package:untis/untis.dart' as untis;
import 'package:where_not_null/where_not_null.dart';

class Page extends untis.Page {
  String url;
  String previewUrl;
  Uint8List? preview;
  // TODO: more data from dsb

  Page(super.day, super.subs, super.date, this.url, this.previewUrl,
      this.preview);

  /// Creates a dsbuntis [Page] from an untis `Page`,
  /// and [url], [previewUrl] and [preview].
  Page.from(untis.Page page, this.url, this.previewUrl, [this.preview])
      : super(page.day, page.subs, page.date);

  Page.fromJson(super.json)
      : url = json['url'],
        previewUrl = json['preview_url'],
        preview = json['preview'] != null
            ? Uint8List.fromList(List<int>.from(json['preview']))
            : null,
        super.fromJson();

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
}

extension SearchInPlans on Iterable<Iterable<Page>> {
  Iterable<Iterable<Page>> search(bool Function(untis.Substitution) pred) =>
      map((p) => p.map((p) => Page(p.day, p.subs.where(pred).toList(), p.date,
          p.url, p.previewUrl, p.preview)));
}

class DownloadingPage {
  String htmlUrl;
  String previewUrl;
  Future<String> html;
  Future<Uint8List>? preview;

  DownloadingPage(this.htmlUrl, this.previewUrl, this.html, this.preview);

  Future<Page?> parse(
      [untis.ParserBuilder parser = untis.Substitution.fromUntis]) async {
    final up = untis.Page.parse(await html, parser);
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
                  : null)));

  Future<Iterable<Iterable<Page>>> downloadAndParsePlans(
    Iterable<dsb.Item> timetables, {
    bool downloadPreviews = false,
    untis.ParserBuilder parser = untis.Substitution.fromUntis,
  }) =>
      Future.wait(downloadPlans(timetables, downloadPreviews: downloadPreviews)
              .map((e) => Future.wait(e.map((p) => p.parse(parser)))
                  .then((x) => x.whereNotNull())))
          .then((x) => x.where((p) => p.isNotEmpty));
}

// TODO: put this into its own package, then deprecate, then remove
extension ToNestedList<T> on Iterable<Iterable<T>> {
  List<List<T>> toNestedList({bool growable = true}) =>
      map((x) => x.toList(growable: growable)).toList(growable: growable);
}

/// Logs into a DSBMobile account and downloads all timetables.
///
/// Uses [username] and [password] to `Session.login` (`package:dsb`) to the
/// given [endpoint]/[previewEndpoint] using [http].
///
/// Then it uses dsb `Session.getTimetables` with [downloadPreviews], and
/// [parser] and `Session.downloadAndParsePlans` to get the actual plans.
Future<List<List<Page>>> getAllSubs(
  String username,
  String password, {
  ScHttpClient? http,
  String endpoint = dsb.Session.defaultEndpoint,
  String previewEndpoint = dsb.Session.defaultPreviewEndpoint,
  bool downloadPreviews = false,
  untis.ParserBuilder parser = untis.Substitution.fromUntis,
}) =>
    dsb.Session.login(username, password,
            endpoint: endpoint, previewEndpoint: previewEndpoint, http: http)
        .then((s) => s.getTimetables().then(
              (t) => s
                  .downloadAndParsePlans(t,
                      downloadPreviews: downloadPreviews, parser: parser)
                  .then((x) => x.toNestedList()),
            ));

extension MergePlan on Iterable<Page> {
  /// Merges a plan consisting of multiple [Page]s into one that contains all
  /// `subs`, and `day` and `date` of the first one.
  untis.Page merge() => untis.Page(
      first.day, map((p) => p.subs).reduce((a, b) => [...a, ...b]), first.date);
}

extension MergePlans on Iterable<Iterable<Page>> {
  /// Merges plans consisting of multiple [Page]s into one that contains all
  /// `subs`, and `day` and `date` of the first one.
  Iterable<untis.Page> merge() =>
      where((e) => e.isNotEmpty).map((e) => e.merge());
}
