import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:untis/src/day.dart';
import 'package:untis/src/sub.dart';

typedef PlanParser = Substitution Function(int, List<String>);

final _tag = RegExp(r'</?.+?>');
final _unescape = HtmlUnescape();
String _str(dom.Element e) =>
    _unescape.convert(e.innerHtml.replaceAll(_tag, '')).trim();

List<int> _parseIntsFromString(String s) {
  final out = <int>[];
  var lastindex = 0;
  for (var i = 0; i < s.length; i++) {
    if (!'0123456789'.contains(s[i])) {
      if (lastindex != i) out.add(int.parse(s.substring(lastindex, i)));
      lastindex = i + 1;
    }
  }
  out.add(int.parse(s.substring(lastindex, s.length)));
  return out;
}

// TODO: add A LOT more documentation
// TODO: this whole structure has to be rethought
class Plan {
  Day? day;
  List<Substitution> subs;
  String date;

  Plan(this.day, this.subs, this.date);

  Plan.fromJson(Map<String, dynamic> json)
      : day = dayFromInt(json['day']),
        date = json['date'],
        subs = json['subs'].map<Substitution>(Substitution.fromJson).toList();

  Map<String, dynamic> toJson() => {
        if (day != null) 'day': day?.toInt(),
        'date': date,
        'subs': subs.map((sub) => sub.toJson()).toList(),
      };

  @override
  String toString() => '$day: $subs';

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
    bool Function(Substitution) predicate,
  ) =>
      plans
          .map((p) => Plan(p.day, p.subs.where(predicate).toList(), p.date))
          .toList();

  static Plan? parsePlan(
    String html, [
    PlanParser parser = Substitution.fromUntis,
  ]) {
    final rawHtml = html
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        //just fyi: these regexes only work because there are no more newlines
        .replaceAll(RegExp(r'<h1.*?</h1>'), '')
        .replaceAll(RegExp(r'</?p.*?>'), '')
        .replaceAll(RegExp(r'<th.*?</th>'), '')
        .replaceAll(RegExp(r'<head.*?</head>'), '')
        .replaceAll(RegExp(r'<script.*?</script>'), '')
        .replaceAll(RegExp(r'<style.*?</style>'), '')
        .replaceAll(RegExp(r'</?html.*?>'), '')
        .replaceAll(RegExp(r'</?body.*?>'), '')
        .replaceAll(RegExp(r'</?font.*?>'), '')
        .replaceAll(RegExp(r'</?span.*?>'), '')
        .replaceAll(RegExp(r'</?center.*?>'), '')
        .replaceAll(RegExp(r'</?a.*?>'), '')
        .replaceAll(RegExp(r'<tr.*?>'), '<tr>')
        .replaceAll(RegExp(r'<td.*?>'), '<td>')
        .replaceAll(RegExp(r'<th.*?>'), '<th>')
        .replaceAll(RegExp(r' +'), ' ')
        .replaceAll(RegExp(r'<br />'), '')
        .replaceAll(RegExp(r'<!-- .*? -->'), '');
    try {
      var html = parse(rawHtml).first.children[1].children; //body
      final planTitle =
          searchFirst(html, (e) => e.className.contains('mon_title'))!
              .innerHtml;
      html = searchFirst(html, (e) => e.className.contains('mon_list'))!
          .children
          .first //for some reason <table>s like to contain <tbody>s
          .children;
      final subs = <Substitution>[];
      for (var i = 1; i < html.length; i++) {
        final e = html[i].children.map(_str).toList();
        final allLessons = e[1];
        for (final lesson in _parseIntsFromString(allLessons)) {
          final sub = parser(lesson, e);
          subs.add(sub);
        }
      }
      return Plan(matchDay(planTitle), subs, planTitle);
    } catch (e) {
      return null;
    }
  }

  static Iterable<Plan> parsePlans(
    Iterable<String> htmls, [
    PlanParser parser = Substitution.fromUntis,
  ]) =>
      htmls.map(parsePlan).where((e) => e != null).map((e) => e!);
}
