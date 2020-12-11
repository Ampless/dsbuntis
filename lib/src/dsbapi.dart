import 'dart:async';
import 'dart:convert';

import 'package:dsbuntis/src/day.dart';
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:uuid/uuid.dart';
import 'package:dsbuntis/src/utils.dart';
import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;

class Substitution extends Comparable {
  String affectedClass;
  int lesson;
  String orgTeacher;
  String subTeacher;
  String subject;
  String notes;
  bool isFree;

  Substitution(this.affectedClass, this.lesson, this.subTeacher, this.subject,
      this.notes, this.isFree, this.orgTeacher);

  Substitution.fromJson(Map<String, dynamic> json)
      : affectedClass = json['class'],
        lesson = json['lesson'],
        subTeacher = json['sub_teacher'],
        orgTeacher = json['org_teacher'],
        subject = json['subject'],
        notes = json['notes'],
        isFree = json['free'];

  Map<String, dynamic> toJson() => {
        'class': affectedClass,
        'lesson': lesson,
        'sub_teacher': subTeacher,
        'org_teacher': orgTeacher,
        'subject': subject,
        'notes': notes,
        'free': isFree,
      };

  @override
  int compareTo(dynamic other) {
    if (!(other is Substitution)) return null;
    final tp = int.tryParse(this.affectedClass[1]) == null ? '0' : '';
    final op = int.tryParse(other.affectedClass[1]) == null ? '0' : '';
    final c = (tp + this.affectedClass).compareTo(op + other.affectedClass);
    return c != 0 ? c : this.lesson.compareTo(other.lesson);
  }

  @override
  String toString() =>
      "['$affectedClass', $lesson, '$orgTeacher' → '$subTeacher', '$subject', '$notes', $isFree]";
}

class Plan {
  Day day;
  String date;
  String url;
  List<Substitution> subs;

  Plan(this.day, this.subs, this.date, this.url);

  Plan.fromJson(Map<String, dynamic> json)
      : day = dayFromInt(json['day']),
        date = json['date'],
        subs = _subsFromJson(json['subs']),
        url = json['url'];

  dynamic toJson() => {
        'day': dayToInt(day),
        'date': date,
        'subs': _subsToJson(),
        'url': url,
      };

  List<Map<String, dynamic>> _subsToJson() {
    final lessonsStrings = <Map<String, dynamic>>[];
    for (final sub in subs) {
      lessonsStrings.add(sub.toJson());
    }
    return lessonsStrings;
  }

  static List<Substitution> _subsFromJson(dynamic subsStrings) {
    final subs = <Substitution>[];
    for (final s in subsStrings) {
      subs.add(Substitution.fromJson(s));
    }
    return subs;
  }

  @override
  String toString() => '$day: $subs';

  static String plansToJson(List<Plan> plans) {
    if (plans == null) return '[]';
    final planJsons = [];
    for (final plan in plans) {
      planJsons.add(plan.toJson());
    }
    return jsonEncode(planJsons);
  }

  static List<Plan> plansFromJson(String jsonPlans) {
    if (jsonPlans == null) return [];
    final plans = <Plan>[];
    for (final plan in jsonDecode(jsonPlans)) {
      plans.add(Plan.fromJson(plan));
    }
    return plans;
  }
}

Future<String> getData(
  String username,
  String password,
  Future<String> Function(Uri, Object, String, Map<String, String>) httpPost, {
  String apiEndpoint = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData',
  String version = '2.5.9',
  String device = 'SM-G950F',
  String os = '29 10.0',
  String language = 'de',
}) async {
  if (username == null) throw '[dsbGetData] username = null';
  if (password == null) throw '[dsbGetData] password = null';
  if (httpPost == null) throw '[dsbGetData] httpPost = null';
  final datetime = removeLastChars(DateTime.now().toIso8601String(), 3) + 'Z';
  final json = '{'
      '"UserId":"$username",'
      '"UserPw":"$password",'
      '"AppVersion":"$version",'
      '"Language":"$language",'
      '"OsVersion":"$os",'
      '"AppId":"${Uuid().v4()}",'
      '"Device":"$device",'
      '"BundleId":"de.heinekingmedia.dsbmobile",'
      '"Date":"$datetime",'
      '"LastUpdate":"$datetime"'
      '}';
  final rawJson = await httpPost(
    Uri.parse(apiEndpoint),
    '{"req":{'
        '"Data":"${base64.encode(GZipEncoder().encode(utf8.encode(json)))}",'
        '"DataType":1}}',
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

Future<List<Plan>> getAndParse(
  String jsontext,
  Future<String> Function(Uri) httpGet,
) async {
  if (jsontext == null) throw '[dsbGetAndParse] jsontext = null';
  if (httpGet == null) throw '[dsbGetAndParse] httpGet = null';
  var json = jsonDecode(jsontext);
  if (json['Resultcode'] != 0) throw json['ResultStatusInfo'];
  json = json['ResultMenuItems'][0]['Childs'][0];
  final plans = <Plan>[];
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
      final subs = <Substitution>[];
      for (var i = 1; i < html.length; i++) {
        final e = html[i].children;
        final allLessons = _str(e[1]);
        for (final lesson in _parseIntsFromString(allLessons)) {
          final sub = e.length < 6
              ? _plsBuildMeASub(
                  _str(e[0]), lesson, _str(e[2]), _str(e[3]), _str(e[4]), null)
              : _plsBuildMeASub(_str(e[0]), lesson, _str(e[2]), _str(e[3]),
                  _str(e[5]), _str(e[4]));
          subs.add(sub);
        }
      }
      plans.add(Plan(matchDay(planTitle), subs, planTitle, url));
    } catch (e) {
      plans.add(null);
    }
  }
  return plans;
}

Substitution _plsBuildMeASub(String affectedClass, int lesson,
    String subTeacher, String subject, String notes, String orgTeacher) {
  if (affectedClass.codeUnitAt(0) == _zero) {
    affectedClass = affectedClass.substring(1);
  }
  return Substitution(
    affectedClass.toLowerCase(),
    lesson,
    subTeacher,
    subject,
    notes,
    subTeacher.contains('---'),
    orgTeacher,
  );
}

final _tag = RegExp(r'</?.+?>');

String _str(dom.Element e) =>
    _unescape.convert(e.innerHtml.replaceAll(_tag, '')).trim();

final _zero = '0'.codeUnitAt(0), _nine = '9'.codeUnitAt(0);

List<int> _parseIntsFromString(String s) {
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

Future<List<Plan>> getAllSubs(
  String username,
  String password,
  Future<String> Function(Uri) httpGet,
  Future<String> Function(Uri, Object, String, Map<String, String>) httpPost, {
  String language = 'de',
}) async {
  final json = await getData(username, password, httpPost, language: language);
  return getAndParse(json, httpGet);
}

//TODO: rename in next major
List<Plan> searchClass(List<Plan> plans, String grade, String char) {
  if (plans == null) return [];
  grade ??= '';
  char ??= '';
  for (final plan in plans) {
    final subs = <Substitution>[];
    for (final sub in plan.subs) {
      if (sub.affectedClass.contains(grade) &&
          sub.affectedClass.contains(char)) {
        subs.add(sub);
      }
    }
    plan.subs = subs;
  }
  return plans;
}

//TODO: remove in next major
List<Plan> sortByLesson(List<Plan> plans) {
  if (plans == null) return [];
  for (final plan in plans) {
    plan.subs.sort((a, b) => a.lesson.compareTo(b.lesson));
  }
  return plans;
}

Future<String> checkCredentials(
  String username,
  String password,
  Future<String> Function(Uri, Object, String, Map<String, String>) httpPost,
) async {
  Map<String, dynamic> map = jsonDecode(await getData(
    username,
    password,
    httpPost,
  ));
  if (map['Resultcode'] != 0) return map['ResultStatusInfo'];
  return null;
}
