import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dsbuntis/day.dart';
import 'package:uuid/uuid.dart';
import 'package:dsbuntis/utils.dart';
import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

const String _DSB_BUNDLE_ID = 'de.heinekingmedia.dsbmobile';
const String _DSB_DEVICE = 'SM-G950F';
const String _DSB_VERSION = '2.5.9';
const String _DSB_OS_VERSION = '29 10.0';

class DsbSubstitution {
  String affectedClass;
  List<int> lessons;
  String teacher;
  String subject;
  String notes;
  bool isFree;

  DsbSubstitution(this.affectedClass, this.lessons, this.teacher, this.subject,
      this.notes, this.isFree);

  DsbSubstitution.fromJson(Map<String, dynamic> json)
      : affectedClass = json['affectedClass'],
        lessons = List<int>.from(json['hours']),
        teacher = json['teacher'],
        subject = json['subject'],
        notes = json['notes'],
        isFree = json['isFree'];

  Map<String, dynamic> toJson() => {
        'affectedClass': affectedClass,
        'hours': lessons,
        'teacher': teacher,
        'subject': subject,
        'notes': notes,
        'isFree': isFree,
      };

  static final _zero = '0'.codeUnitAt(0), _nine = '9'.codeUnitAt(0);

  static List<int> parseIntsFromString(String s) {
    var out = <int>[];
    var lastindex = 0;
    for (var i = 0; i < s.length; i++) {
      var c = s[i].codeUnitAt(0);
      if (c < _zero || c > _nine) {
        if (lastindex != i) out.add(int.parse(s.substring(lastindex, i)));
        lastindex = i + 1;
      }
    }
    out.add(int.parse(s.substring(lastindex, s.length)));
    return out;
  }

  static DsbSubstitution fromStrings(String affectedClass, String hour,
      String teacher, String subject, String notes) {
    if (affectedClass.codeUnitAt(0) == _zero) {
      affectedClass = affectedClass.substring(1);
    }
    return DsbSubstitution(
        affectedClass.toLowerCase(),
        parseIntsFromString(hour),
        teacher,
        subject,
        notes,
        teacher.contains('---'));
  }

  static DsbSubstitution fromElements(
      dom.Element affectedClass,
      dom.Element hour,
      dom.Element teacher,
      dom.Element subject,
      dom.Element notes) {
    return fromStrings(_str(affectedClass), _str(hour), _str(teacher),
        _str(subject), _str(notes));
  }

  static DsbSubstitution fromElementArray(List<dom.Element> e) {
    return fromElements(e[0], e[1], e[2], e[3], e[4]);
  }

  static final _tag = RegExp(r'</?.+?>');

  static String _str(dom.Element e) => e.innerHtml.replaceAll(_tag, '').trim();

  @override
  String toString() =>
      "['$affectedClass', $lessons, '$teacher', '$subject', '$notes', $isFree]";

  List<int> get actualLessons {
    var h = <int>[];
    for (var i = min(lessons); i <= max(lessons); i++) {
      h.add(i);
    }
    return h;
  }
}

class DsbPlan {
  Day day;
  String date;
  List<DsbSubstitution> subs;

  DsbPlan(this.day, this.subs, this.date);

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
    var lessonsStrings = <Map<String, dynamic>>[];
    for (var sub in subs) {
      lessonsStrings.add(sub.toJson());
    }
    return lessonsStrings;
  }

  static List<DsbSubstitution> subsFromJson(dynamic subsStrings) {
    var subs = <DsbSubstitution>[];
    for (var s in subsStrings) {
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
  bool cachePostRequests = true,
  String dsbLanguage = 'de',
}) async {
  if (username == null) throw '[dsbGetData] username = null';
  if (password == null) throw '[dsbGetData] password = null';
  if (httpPost == null) throw '[dsbGetData] httpPost = null';
  var datetime = DateTime.now().toIso8601String().substring(0, -3) + 'Z';
  var json = '{'
      '"UserId":"$username",'
      '"UserPw":"$password",'
      '"AppVersion":"$_DSB_VERSION",'
      '"Language":"$dsbLanguage",'
      '"OsVersion":"$_DSB_OS_VERSION",'
      '"AppId":"${Uuid().v4()}",'
      '"Device":"$_DSB_DEVICE",'
      '"BundleId":"$_DSB_BUNDLE_ID",'
      '"Date":"$datetime",'
      '"LastUpdate":"$datetime"'
      '}';
  var rawJson = await httpPost(
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
      base64.decode(jsonDecode(rawJson)['d']),
    ),
  );
}

Future<List<DsbPlan>> dsbGetAndParse(
  String jsontext,
  Future<String> Function(Uri) httpGet, {
  bool cacheGetRequests = true,
}) async {
  if (jsontext == null) throw '[dsbGetAndParse] jsontext = null';
  if (httpGet == null) throw '[dsbGetAndParse] httpGet = null';
  if (cacheGetRequests == null)
    throw '[dsbGetAndParse] cacheGetRequests = null';
  var json = jsonDecode(jsontext);
  if (json['Resultcode'] != 0) throw json['ResultStatusInfo'];
  json = json['ResultMenuItems'][0]['Childs'][0];
  var plans = <DsbPlan>[];
  for (var plan in json['Root']['Childs']) {
    String url = plan['Childs'][0]['Detail'];
    var rawHtml = await httpGet(Uri.parse(url));
    if (rawHtml == null) throw '[dsbGetAndParse] httpGet returned null.';
    try {
      var html = HtmlParser(rawHtml)
          .parse()
          .children
          .first
          .children[1]
          .children; //body
      var planTitle = _searchHtml(html, 'mon_title').innerHtml;
      html = _searchHtml(html, 'mon_list')
          .children
          .first //for some reason <table>s like to contain <tbody>s
          //(just taking first isnt even standard-compliant, but it works rn)
          .children;
      var subs = <DsbSubstitution>[];
      for (var i = 1; i < html.length; i++) {
        subs.add(DsbSubstitution.fromElementArray(html[i].children));
      }
      plans.add(DsbPlan(matchDay(planTitle), subs, planTitle));
    } catch (e) {
      plans.add(null);
    }
  }
  return plans;
}

dom.Element _searchHtml(List<dom.Element> rootNode, String className) {
  for (var e in rootNode) {
    if (e.className.contains(className)) return e;
    var found = _searchHtml(e.children, className);
    if (found != null) return found;
  }
  return null;
}

Future<List<DsbPlan>> dsbGetAllSubs(
  String username,
  String password,
  Future<String> Function(Uri) httpGet,
  Future<String> Function(Uri, Object, String, Map<String, String>) httpPost, {
  bool cacheGetRequests = true,
  bool cachePostRequests = true,
  String dsbLanguage = 'de',
}) async {
  var json = await dsbGetData(username, password, httpPost,
      cachePostRequests: cachePostRequests, dsbLanguage: dsbLanguage);
  return dsbGetAndParse(json, httpGet, cacheGetRequests: cacheGetRequests);
}

List<DsbPlan> dsbSearchClass(List<DsbPlan> plans, String stage, String char) {
  if (plans == null) return [];
  stage ??= '';
  char ??= '';
  for (var plan in plans) {
    var subs = <DsbSubstitution>[];
    for (var sub in plan.subs) {
      if (sub.affectedClass.contains(stage) &&
          sub.affectedClass.contains(char)) {
        subs.add(sub);
      }
    }
    plan.subs = subs;
  }
  return plans;
}

List<DsbPlan> dsbSortAllByHour(List<DsbPlan> plans) {
  if (plans == null) return [];
  for (var plan in plans) {
    plan.subs.sort((a, b) => max(a.lessons).compareTo(max(b.lessons)));
  }
  return plans;
}

String plansToJson(List<DsbPlan> plans) {
  if (plans == null) return '[]';
  var planJsons = [];
  for (var plan in plans) {
    planJsons.add(plan.toJson());
  }
  return jsonEncode(planJsons);
}

List<DsbPlan> plansFromJson(String jsonPlans) {
  if (jsonPlans == null) return [];
  var plans = <DsbPlan>[];
  for (var plan in jsonDecode(jsonPlans)) {
    plans.add(DsbPlan.fromJson(plan));
  }
  return plans;
}
