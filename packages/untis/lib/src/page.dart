import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:untis/src/day.dart';
import 'package:untis/src/sub.dart';

typedef Parser = Substitution Function(int, List<String>);

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
class Page {
  Day? day;
  List<Substitution> subs;
  String date;

  Page(this.day, this.subs, this.date);

  Page.fromJson(dynamic json)
      : day = dayFromInt(json['day']),
        date = json['date'],
        subs = json['subs'].map<Substitution>(Substitution.fromJson).toList();

  dynamic toJson() => {
        if (day != null) 'day': day?.toInt(),
        'date': date,
        'subs': subs.map((sub) => sub.toJson()).toList(),
      };

  @override
  String toString() => '$day: $subs';

  static List<Page> searchInPages(
    Iterable<Page> pages,
    bool Function(Substitution) predicate,
  ) =>
      pages
          .map((p) => Page(p.day, p.subs.where(predicate).toList(), p.date))
          .toList();

  static Page? parsePage(
    String html, [
    Parser parser = Substitution.fromUntis,
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
      final pageTitle =
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
      return Page(matchDay(pageTitle), subs, pageTitle);
    } catch (e) {
      return null;
    }
  }

  static Iterable<Page> parsePages(
    Iterable<String> htmls, [
    Parser parser = Substitution.fromUntis,
  ]) =>
      htmls.map(parsePage).where((e) => e != null).map((e) => e!);
}
