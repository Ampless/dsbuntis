import 'dart:convert';
import 'dart:typed_data';

import 'package:dsbuntis/src/exceptions.dart';
import 'package:dsbuntis/src/day.dart';
import 'package:dsbuntis/src/plan.dart';
import 'package:dsbuntis/src/sub.dart';
import 'package:html/dom.dart' as dom;
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:schttp/schttp.dart';

String _authUrl(String ep, String av, String ov, String u, String pw) =>
    '$ep/authid'
    '?bundleid=de.heinekingmedia.dsbmobile'
    '&appversion=$av'
    '&osversion=$ov'
    '&pushid'
    '&user=$u'
    '&password=$pw';

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

typedef planParser = Substitution Function(int, List<String>);

class Session {
  String endpoint;
  String token;
  ScHttpClient http;
  String previewEndpoint;

  Session(this.endpoint, this.token, this.http, this.previewEndpoint);

  static Future<Session> login(
    String username,
    String password, {
    ScHttpClient? http,
    String endpoint = 'https://mobileapi.dsbcontrol.de',
    String appVersion = '36',
    String osVersion = '30',
    String previewEndpoint = 'https://light.dsbcontrol.de/DSBlightWebsite/Data',
  }) async {
    http ??= ScHttpClient();
    final tkn = await http
        .get(_authUrl(endpoint, appVersion, osVersion, username, password),
            readCache: false, writeCache: false)
        .then((tkn) {
      // TODO: check if all of this is correct dsb behavior and if it works
      if (tkn.isEmpty) throw AuthenticationException();
      String? error;
      try {
        error = jsonDecode(tkn)['Message'];
      } catch (s) {}
      if (error != null) throw DsbException(error);
      tkn = tkn.replaceAll('"', '');
      if (tkn.isEmpty) throw AuthenticationException();
      return tkn;
    });
    return Session(endpoint, tkn, http, previewEndpoint);
  }

  Future<dynamic> getJson(String name) async => jsonDecode(await http.get(
        '$endpoint/$name?authid=$token',
        ttl: Duration(minutes: 15),
      ));

  Future<List> timetableJson() async {
    final j = await getJson('dsbtimetables');
    if (j is Map && j.containsKey('Message')) throw DsbException(j['Message']);
    return j;
  }

// TODO: split up
  Future<List<Plan>> getAndParse(
    List json, {
    bool downloadPreviews = false,
    planParser parser = Substitution.fromUntis,
  }) async {
    final plans = <Plan>[];
    for (var plan in json) {
      plan = plan['Childs'][0];
      final String url = plan['Detail'];
      final previewUrl = '$previewEndpoint/${plan['Preview']}';
      final rawHtml = (await http.get(url, ttl: Duration(days: 4)))
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
            //TODO: just taking first isnt even standard-compliant
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
        plans.add(Plan(matchDay(planTitle), subs, planTitle, url, previewUrl,
            downloadPreviews ? await http.getBin(previewUrl) : Uint8List(0)));
      } catch (e) {}
    }
    return plans;
  }
}
