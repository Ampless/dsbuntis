import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dsbuntis/src/day.dart';
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:uuid/uuid.dart';
import 'package:dsbuntis/src/utils.dart';
import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;

const String _DSB_DEVICE = 'SM-G950F';
const String _DSB_VERSION = '2.5.9';
const String _DSB_OS_VERSION = '29 10.0';

class DsbSubstitution {
  String affectedClass;
  List<int> lessons;
  String orgTeacher;
  String subTeacher;
  String subject;
  String notes;
  bool isFree;

  DsbSubstitution(this.affectedClass, this.lessons, this.subTeacher,
      this.subject, this.notes, this.isFree, this.orgTeacher);

  DsbSubstitution.fromJson(Map<String, dynamic> json)
      : affectedClass = json['affectedClass'],
        lessons = List<int>.from(json['hours']),
        subTeacher = json['teacher'],
        orgTeacher = json.containsKey('oteacher') ? json['oteacher'] : null,
        subject = json['subject'],
        notes = json['notes'],
        isFree = json['isFree'];

  Map<String, dynamic> toJson() => {
        'affectedClass': affectedClass,
        'hours': lessons,
        'teacher': subTeacher,
        'oteacher': orgTeacher,
        'subject': subject,
        'notes': notes,
        'isFree': isFree,
      };

  static final _zero = '0'.codeUnitAt(0), _nine = '9'.codeUnitAt(0);

  static List<int> parseIntsFromString(String s) {
    final out = <int>[];
    var lastindex = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s[i].codeUnitAt(0);
      if (c < _zero || c > _nine) {
        if (lastindex != i) out.add(int.parse(s.substring(lastindex, i)));
        lastindex = i + 1;
      }
    }
    out.add(int.parse(s.substring(lastindex, s.length)));
    return out;
  }

  static DsbSubstitution fromStrings(String affectedClass, String hour,
      String subTeacher, String subject, String notes, String orgTeacher) {
    if (affectedClass.codeUnitAt(0) == _zero) {
      affectedClass = affectedClass.substring(1);
    }
    return DsbSubstitution(
      affectedClass.toLowerCase(),
      parseIntsFromString(hour),
      subTeacher,
      subject,
      notes,
      subTeacher.contains('---'),
      orgTeacher,
    );
  }

  static DsbSubstitution fromOldElements(
      dom.Element affectedClass,
      dom.Element lesson,
      dom.Element teacher,
      dom.Element subject,
      dom.Element notes) {
    return fromStrings(_str(affectedClass), _str(lesson), _str(teacher),
        _str(subject), _str(notes), null);
  }

  static DsbSubstitution fromNewElements(
    dom.Element affectedClass,
    dom.Element lesson,
    dom.Element subTeacher,
    dom.Element subject,
    dom.Element orgTeacher,
    dom.Element notes,
  ) {
    return fromStrings(_str(affectedClass), _str(lesson), _str(subTeacher),
        _str(subject), _str(notes), _str(orgTeacher));
  }

  static DsbSubstitution fromElementArray(List<dom.Element> e) {
    return e.length < 6
        ? fromOldElements(e[0], e[1], e[2], e[3], e[4])
        : fromNewElements(e[0], e[1], e[2], e[3], e[4], e[5]);
  }

  static final _tag = RegExp(r'</?.+?>');

  static String _str(dom.Element e) =>
      _unescape.convert(e.innerHtml.replaceAll(_tag, '')).trim();

  @override
  String toString() =>
      "['$affectedClass', $lessons, '$orgTeacher' → '$subTeacher', '$subject', '$notes', $isFree]";

  List<int> get actualLessons {
    final h = <int>[];
    for (var i = min(lessons); i <= max(lessons); i++) {
      h.add(i);
    }
    return h;
  }
}

class DsbPlan {
  Day day;
  String date;
  String url;
  List<DsbSubstitution> subs;

  DsbPlan(this.day, this.subs, this.date, this.url);

  DsbPlan.fromJson(Map<String, dynamic> json)
      : day = dayFromInt(json['day']),
        date = json['date'],
        subs = subsFromJson(json['subs']);

  dynamic toJson() => {
        'day': dayToInt(day),
        'date': date,
        'subs': subsToJson(),
      };

  List<Map<String, dynamic>> subsToJson() {
    final lessonsStrings = <Map<String, dynamic>>[];
    for (final sub in subs) {
      lessonsStrings.add(sub.toJson());
    }
    return lessonsStrings;
  }

  static List<DsbSubstitution> subsFromJson(dynamic subsStrings) {
    final subs = <DsbSubstitution>[];
    for (final s in subsStrings) {
      subs.add(DsbSubstitution.fromJson(s));
    }
    return subs;
  }

  @override
  String toString() => '$day: $subs';
}

Future<String> dsbGetData(
  String username,
  String password,
  Future<String> Function(Uri, Object, String, Map<String, String>) httpPost, {
  String apiEndpoint = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData',
  String dsbLanguage = 'de',
}) async {
  if (username == null) throw '[dsbGetData] username = null';
  if (password == null) throw '[dsbGetData] password = null';
  if (httpPost == null) throw '[dsbGetData] httpPost = null';
  final datetime = removeLastChars(DateTime.now().toIso8601String(), 3) + 'Z';
  final json = '{'
      '"UserId":"$username",'
      '"UserPw":"$password",'
      '"AppVersion":"$_DSB_VERSION",'
      '"Language":"$dsbLanguage",'
      '"OsVersion":"$_DSB_OS_VERSION",'
      '"AppId":"${Uuid().v4()}",'
      '"Device":"$_DSB_DEVICE",'
      '"BundleId":"de.heinekingmedia.dsbmobile",'
      '"Date":"$datetime",'
      '"LastUpdate":"$datetime"'
      '}';
  final rawJson = await httpPost(
    Uri.parse(apiEndpoint),
    '{'
        '"req": {'
        '"Data": "${base64.encode(GZipEncoder().encode(utf8.encode(json)))}", '
        '"DataType": 1'
        '}'
        '}',
    '$apiEndpoint\t$username\t$password',
    {'content-type': 'application/json'},
  );
  if (rawJson == null) throw '[dsbGetData] httpPost returned null.';
  return utf8.decode(
    GZipDecoder().decodeBytes(
      base64.decode(
        jsonDecode(rawJson)['d'],
      ),
    ),
  );
}

final _unescape = HtmlUnescape();

Future<List<DsbPlan>> dsbGetAndParse(
  String jsontext,
  Future<String> Function(Uri) httpGet,
) async {
  if (jsontext == null) throw '[dsbGetAndParse] jsontext = null';
  if (httpGet == null) throw '[dsbGetAndParse] httpGet = null';
  var json = jsonDecode(jsontext);
  if (json['Resultcode'] != 0) throw json['ResultStatusInfo'];
  json = json['ResultMenuItems'][0]['Childs'][0];
  final plans = <DsbPlan>[];
  for (final plan in json['Root']['Childs']) {
    String url = plan['Childs'][0]['Detail'];
    var rawHtml = await httpGet(Uri.parse(url));
    if (rawHtml == null) throw '[dsbGetAndParse] httpGet returned null.';
    rawHtml = rawHtml
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
      var html = htmlParse(rawHtml).first.children[1].children; //body
      final planTitle = htmlSearchByClass(html, 'mon_title').innerHtml;
      html = htmlSearchByClass(html, 'mon_list')
          .children
          .first //for some reason <table>s like to contain <tbody>s
          //(just taking first isnt even standard-compliant, but it works rn)
          .children;
      final subs = <DsbSubstitution>[];
      for (var i = 1; i < html.length; i++) {
        subs.add(DsbSubstitution.fromElementArray(html[i].children));
      }
      plans.add(DsbPlan(matchDay(planTitle), subs, planTitle, url));
    } catch (e) {
      plans.add(null);
    }
  }
  return plans;
}

Future<List<DsbPlan>> dsbGetAllSubs(
  String username,
  String password,
  Future<String> Function(Uri) httpGet,
  Future<String> Function(Uri, Object, String, Map<String, String>) httpPost, {
  String dsbLanguage = 'de',
}) async {
  final json =
      await dsbGetData(username, password, httpPost, dsbLanguage: dsbLanguage);
  return dsbGetAndParse(json, httpGet);
}

List<DsbPlan> dsbSearchClass(List<DsbPlan> plans, String stage, String char) {
  if (plans == null) return [];
  stage ??= '';
  char ??= '';
  for (final plan in plans) {
    final subs = <DsbSubstitution>[];
    for (final sub in plan.subs) {
      if (sub.affectedClass.contains(stage) &&
          sub.affectedClass.contains(char)) {
        subs.add(sub);
      }
    }
    plan.subs = subs;
  }
  return plans;
}

List<DsbPlan> dsbSortByLesson(List<DsbPlan> plans) {
  if (plans == null) return [];
  for (final plan in plans) {
    plan.subs.sort((a, b) => max(a.lessons).compareTo(max(b.lessons)));
  }
  return plans;
}

Future<String> dsbCheckCredentials(
  String username,
  String password,
  Future<String> Function(Uri, Object, String, Map<String, String>) httpPost,
) async {
  Map<String, dynamic> map = jsonDecode(await dsbGetData(
    username,
    password,
    httpPost,
  ));
  if (map['Resultcode'] != 0) return map['ResultStatusInfo'];
  return null;
}

String plansToJson(List<DsbPlan> plans) {
  if (plans == null) return '[]';
  final planJsons = [];
  for (final plan in plans) {
    planJsons.add(plan.toJson());
  }
  return jsonEncode(planJsons);
}

List<DsbPlan> plansFromJson(String jsonPlans) {
  if (jsonPlans == null) return [];
  final plans = <DsbPlan>[];
  for (final plan in jsonDecode(jsonPlans)) {
    plans.add(DsbPlan.fromJson(plan));
  }
  return plans;
}
