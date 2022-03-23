import 'dart:convert';
import 'dart:typed_data';

import 'package:untis/untis.dart' as untis;

// TODO: add A LOT more documentation
// TODO: this whole structure has to be rethought
class Plan extends untis.Plan {
  String url;
  String previewUrl;
  Uint8List? preview;
  // TODO: more data from dsb

  Plan(untis.Day? day, List<untis.Substitution> subs, String date, this.url,
      this.previewUrl, this.preview)
      : super(day, subs, date);

  Plan.from(untis.Plan p, this.url, this.previewUrl, this.preview)
      : super(p.day, p.subs, p.date);

  Plan.fromJson(Map<String, dynamic> json)
      : url = json['url'],
        previewUrl = json['preview_url'],
        preview = json.containsKey('preview')
            ? Uint8List.fromList(List<int>.from(json['preview']))
            : null,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'url': url,
      'preview_url': previewUrl,
      if (preview != null) 'preview': preview,
    });

  @override
  String toString([bool inclUrls = true]) => '$day${_cum(inclUrls)}: $subs';
  String _cum(bool iu) => iu ? '($url, $previewUrl)' : '';

  static List plansToJson(Iterable<Plan> plans) =>
      plans.map((e) => e.toJson()).toList();

  static List<Plan> plansFromJson(dynamic plans) =>
      plans.map<Plan>((e) => Plan.fromJson(e)).toList();

  static String plansToJsonString(List<Plan> plans) =>
      jsonEncode(plansToJson(plans));

  static List<Plan> plansFromJsonString(String plans) =>
      plansFromJson(jsonDecode(plans));

  static List<Plan> searchInPlans(
    Iterable<Plan> plans,
    bool Function(untis.Substitution) predicate,
  ) =>
      plans
          .map((p) => Plan(p.day, p.subs.where(predicate).toList(), p.date,
              p.url, p.previewUrl, p.preview))
          .toList();
}
