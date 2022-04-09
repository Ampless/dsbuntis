import 'dart:convert';
import 'dart:typed_data';

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
