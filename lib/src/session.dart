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

String _authUrl(
        String ep, String av, String ov, String u, String pw, String bi) =>
    '$ep/authid'
    '?bundleid=$bi'
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

typedef PlanParser = Substitution Function(int, List<String>);

class DownloadingPlan {
  String htmlUrl, previewUrl;
  Future<String> html;
  Future<Uint8List>? preview;
  DownloadingPlan(this.htmlUrl, this.previewUrl, this.html, this.preview);
}

class Session {
  static const defaultEndpoint = 'https://mobileapi.dsbcontrol.de';
  static const defaultPreviewEndpoint =
      'https://light.dsbcontrol.de/DSBlightWebsite/Data';
  static const defaultAppVersion = '36';
  static const defaultOsVersion = '30';
  static const defaultBundleId = 'de.heinekingmedia.dsbmobile';

  String endpoint;
  String token;
  ScHttpClient http;
  String previewEndpoint;

  Session(this.token,
      {this.endpoint = defaultEndpoint,
      http,
      this.previewEndpoint = defaultPreviewEndpoint})
      : http = http ?? ScHttpClient();

  static Future<Session> login(
    String username,
    String password, {
    ScHttpClient? http,
    String endpoint = defaultEndpoint,
    String appVersion = defaultAppVersion,
    String osVersion = defaultOsVersion,
    String bundleId = defaultBundleId,
    String previewEndpoint = defaultPreviewEndpoint,
  }) async {
    http ??= ScHttpClient();
    final tkn = await http
        .get(
            _authUrl(
                endpoint, appVersion, osVersion, username, password, bundleId),
            ttl: Duration(days: 30))
        .then((tkn) {
      if (tkn.isEmpty) throw AuthenticationException();
      try {
        throw DsbException(jsonDecode(tkn)['Message']);
      } on DsbException {
        rethrow;
      } catch (e) {
        tkn = tkn.replaceAll('"', '');
        if (tkn.isEmpty) throw AuthenticationException();
        return tkn;
      }
    });
    return Session(tkn,
        endpoint: endpoint, http: http, previewEndpoint: previewEndpoint);
  }

  Future<String> getJsonString(String name) async => await http.get(
        '$endpoint/$name?authid=$token',
        ttl: Duration(minutes: 15),
        defaultCharset: (x) => String.fromCharCodes(x),
      );

  Future<dynamic> getJson(String name) => getJsonString(name).then(jsonDecode);

  Future<String> getTimetableJsonString() => getJsonString('dsbtimetables');
  Future<List> getTimetableJson() async {
    final j = await getJson('dsbtimetables');
    if (j is Map && j.containsKey('Message')) throw DsbException(j['Message']);
    return j;
  }

  Iterable<DownloadingPlan> downloadPlans(
    List json, {
    bool downloadPreviews = false,
  }) =>
      json.map((p) => p['Childs'][0]).map((p) => DownloadingPlan(
          p['Detail'],
          p['Preview'],
          http.get(p['Detail'],
              ttl: Duration(days: 4),
              defaultCharset: (x) => String.fromCharCodes(x)),
          downloadPreviews
              ? http.getBin('$previewEndpoint/${p['Preview']}')
              : null));
}

Iterable<Future<Plan?>> parsePlans(
  Iterable<DownloadingPlan> plans, {
  PlanParser parser = Substitution.fromUntis,
}) =>
    plans.map((p) async {
      final rawHtml = (await p.html)
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
        return Plan(matchDay(planTitle), subs, planTitle, p.htmlUrl,
            p.previewUrl, p.preview != null ? await p.preview : null);
      } catch (e) {
        return null;
      }
    });
