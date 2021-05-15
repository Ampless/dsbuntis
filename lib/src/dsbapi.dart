import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dsbuntis/src/day.dart';
import 'package:dsbuntis/src/exceptions.dart';
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:schttp/schttp.dart';
import 'package:html/dom.dart' as dom;

class Substitution extends Comparable {
  String affectedClass;
  int lesson;
  String? orgTeacher;
  String subTeacher;
  String subject;
  String notes;
  String? room;
  bool isFree;

  //TODO: in next major either make room non-optional or make everything named
  Substitution(this.affectedClass, this.lesson, this.subTeacher, this.subject,
      this.notes, this.isFree, this.orgTeacher,
      [this.room]);

  Substitution.raw(
    int lesson, {
    required String affectedClass,
    required String subTeacher,
    required String subject,
    required String notes,
    String? orgTeacher,
    String? room,
  })  : this.affectedClass = affectedClass[0] == '0'
            ? affectedClass.substring(1).toLowerCase()
            : affectedClass.toLowerCase(),
        this.lesson = lesson,
        this.subTeacher = subTeacher,
        this.subject = subject,
        this.notes = notes,
        this.isFree = subTeacher.contains('---'),
        this.orgTeacher = orgTeacher,
        this.room = room;

  static Substitution fromUntis(int lesson, List<String> e) =>
      e.length < 6 ? fromUntis2020(lesson, e) : fromUntis2021(lesson, e);

  static Substitution fromUntis2021(int lesson, List<String> e) =>
      Substitution.raw(
        lesson,
        affectedClass: e[0],
        subTeacher: e[2],
        subject: e[3],
        notes: e[5],
        orgTeacher: e[4],
      );

  static Substitution fromUntis2020(int lesson, List<String> e) =>
      Substitution.raw(
        lesson,
        affectedClass: e[0],
        subTeacher: e[2],
        subject: e[3],
        notes: e[4],
      );

  static Substitution fromUntis2019(int lesson, List<String> e) =>
      Substitution.raw(
        lesson,
        affectedClass: e[0],
        subject: e[2],
        subTeacher: e[3],
        orgTeacher: e[4],
        room: e[5],
        notes: e[6],
      );

  Substitution.fromJson(dynamic json)
      : affectedClass = json['class'],
        lesson = json['lesson'],
        subTeacher = json['sub_teacher'],
        orgTeacher = json['org_teacher'],
        subject = json['subject'],
        notes = json['notes'],
        isFree = json['free'],
        //TODO: make this normal in the next major
        room = json.containsKey('room') ? json['room'] : null;

  dynamic toJson() => {
        'class': affectedClass,
        'lesson': lesson,
        'sub_teacher': subTeacher,
        'org_teacher': orgTeacher,
        'subject': subject,
        'notes': notes,
        'free': isFree,
        'room': room,
      };

  @override
  int compareTo(dynamic other) {
    if (!(other is Substitution)) throw ArgumentError('not comparable');
    final tp = int.tryParse(this.affectedClass[1]) == null ? '0' : '';
    final op = int.tryParse(other.affectedClass[1]) == null ? '0' : '';
    final c = (tp + this.affectedClass).compareTo(op + other.affectedClass);
    return c != 0 ? c : this.lesson.compareTo(other.lesson);
  }

  @override
  String toString() =>
      "['$affectedClass', $lesson, '$orgTeacher' → '$subTeacher' at '$room', '$subject', '$notes', $isFree]";
}

class Plan {
  Day day;
  List<Substitution> subs;
  String date;
  String url;
  String previewUrl;
  Uint8List preview;

  Plan(this.day, this.subs, this.date, this.url, this.previewUrl, this.preview);

  Plan.fromJson(Map<String, dynamic> json)
      : day = dayFromInt(json['day']),
        date = json['date'],
        subs = _subsFromJson(json['subs']),
        url = json['url'],
        previewUrl = json['preview_url'],
        preview = Uint8List.fromList(List<int>.from(json['preview']));

  dynamic toJson() => {
        'day': dayToInt(day),
        'date': date,
        'subs': _subsToJson(),
        'url': url,
        'preview_url': previewUrl,
        'preview': preview,
      };

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

//TODO: in next major rename to support other data types
Future<List> getJson(
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
          //FIXME: just taking first isnt even standard-compliant
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
  final json = await getJson(tkn, http, endpoint: endpoint);
  return getAndParse(
    json,
    http,
    previewEndpoint: previewEndpoint,
    downloadPreviews: downloadPreviews,
    parser: parser,
  );
}
