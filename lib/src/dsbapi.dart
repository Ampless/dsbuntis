import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dsbuntis/src/day.dart';
import 'package:dsbuntis/src/exceptions.dart';
import 'package:dsbuntis/src/plan.dart';
import 'package:dsbuntis/src/sub.dart';
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:schttp/schttp.dart';
import 'package:html/dom.dart' as dom;

String _authUrl(String e, String a, String o, String u, String p) =>
    '$e/authid?bundleid=de.heinekingmedia.dsbmobile' +
    '&appversion=$a&osversion=$o&pushid&user=$u&password=$p';

Future<String> getAuthToken(
  String username,
  String password,
  ScHttpClient http, {
  String endpoint = 'https://mobileapi.dsbcontrol.de',
  String appVersion = '36',
  String osVersion = '30',
}) =>
    http
        .get(_authUrl(endpoint, appVersion, osVersion, username, password),
            readCache: false, writeCache: false)
        .then((tkn) {
      if (tkn.isEmpty) throw AuthenticationException();
      // TODO: this is a horrible piece of code, when im sober again, i should
      //       fix it
      try {
        throw jsonDecode(tkn)['Message'];
      } on Exception {
        return tkn.replaceAll('"', '');
      } on Error {
        return tkn.replaceAll('"', '');
      } on String catch (s) {
        throw AuthenticationException(s);
      }
    });

Future<List> getTimetableJson(
  String token,
  ScHttpClient http, {
  String endpoint = 'https://mobileapi.dsbcontrol.de',
}) async {
  final json = jsonDecode(await http.get(
    '$endpoint/dsbtimetables?authid=$token',
    ttl: Duration(minutes: 15),
  ));
  if (json is Map && json.containsKey('Message'))
    throw DsbException(json['Message']);
  return json;
}

final _unescape = HtmlUnescape();

Future<List<Plan>> getAndParse(
  List json,
  ScHttpClient http, {
  bool downloadPreviews = false,
  String previewEndpoint = 'https://light.dsbcontrol.de/DSBlightWebsite/Data',
  planParser parser = Substitution.fromUntis,
}) async {
  final plans = <Plan>[];
  for (var plan in json) {
    plan = plan['Childs'][0];
    String url = plan['Detail'];
    String previewUrl = '$previewEndpoint/${plan['Preview']}';
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

final _tag = RegExp(r'</?.+?>');

String _str(dom.Element e) =>
    _unescape.convert(e.innerHtml.replaceAll(_tag, '')).trim();

List<int> _parseIntsFromString(String s) {
  final out = <int>[];
  var lastindex = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i].codeUnitAt(0);
    if (c < 0x30 || c > 0x39) {
      if (lastindex != i) out.add(int.parse(s.substring(lastindex, i)));
      lastindex = i + 1;
    }
  }
  out.add(int.parse(s.substring(lastindex, s.length)));
  return out;
}

typedef planParser = Substitution Function(int, List<String>);

Future<List<Plan>> getAllSubs(
  String username,
  String password, {
  ScHttpClient? http,
  String endpoint = 'https://mobileapi.dsbcontrol.de',
  String previewEndpoint = 'https://light.dsbcontrol.de/DSBlightWebsite/Data',
  bool downloadPreviews = false,
  planParser parser = Substitution.fromUntis,
}) async {
  http ??= ScHttpClient();
  final tkn = await getAuthToken(username, password, http, endpoint: endpoint);
  final json = await getTimetableJson(tkn, http, endpoint: endpoint);
  return getAndParse(
    json,
    http,
    previewEndpoint: previewEndpoint,
    downloadPreviews: downloadPreviews,
    parser: parser,
  );
}
