import 'dart:convert';
import 'dart:typed_data';

import 'package:dsbuntis/src/day.dart';
import 'package:dsbuntis/src/sub.dart';

class Plan {
  Day? day;
  List<Substitution> subs;
  String date;
  String url;
  String previewUrl;
  Uint8List? preview;
  // TODO: include more info from dsb

  Plan(this.day, this.subs, this.date, this.url, this.previewUrl, this.preview);

  Plan.fromJson(Map<String, dynamic> json)
      : day = dayFromInt(json['day']),
        date = json['date'],
        subs = _subsFromJson(json['subs']),
        url = json['url'],
        previewUrl = json['preview_url'],
        preview = json.containsKey('preview')
            ? Uint8List.fromList(List<int>.from(json['preview']))
            : null;

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'day': dayToInt(day),
      'date': date,
      'subs': _subsToJson(),
      'url': url,
      'preview_url': previewUrl,
    };
    if (preview != null) m['preview'] = preview;
    return m;
  }

  dynamic _subsToJson() => subs.map((sub) => sub.toJson()).toList();

  static List<Substitution> _subsFromJson(dynamic json) =>
      json.map<Substitution>((s) => Substitution.fromJson(s)).toList();

  @override
  String toString([bool inclUrls = true]) => '$day${_cum(inclUrls)}: $subs';
  String _cum(bool iu) => iu ? '($url, $previewUrl)' : '';

  static List plansToJson(List<Plan> plans) =>
      plans.map((e) => e.toJson()).toList();

  static List<Plan> plansFromJson(dynamic plans) =>
      plans.map<Plan>((e) => Plan.fromJson(e)).toList();

  static String plansToJsonString(List<Plan> plans) =>
      jsonEncode(plansToJson(plans));

  static List<Plan> plansFromJsonString(String plans) =>
      plansFromJson(jsonDecode(plans));

  static List<Plan> searchInPlans(
    List<Plan> plans,
    bool Function(Substitution) predicate,
  ) =>
      plans
          .map((p) => Plan(p.day, p.subs.where(predicate).toList(), p.date,
              p.url, p.previewUrl, p.preview))
          .toList();
}
