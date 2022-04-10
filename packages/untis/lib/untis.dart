import 'package:html/dom.dart' as dom;
import 'package:html_search/html_search.dart';
import 'package:html_unescape/html_unescape.dart';

// TODO: put this into its own package
extension WhereNotNull<T> on Iterable<T?> {
  Iterable<T> whereNotNull() => where((x) => x != null).map((x) => x!);
}

typedef Parser = Substitution Function(int, List<String>);
typedef ParserBuilder = Parser Function(List<String>);

enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
}

class UnknownDayException implements Exception {
  final String _day;
  UnknownDayException(this._day);

  @override
  String toString() => 'Unknown day: $_day';
}

// This code is a shame
// But the Dart team is to blame
// Spam their whole GitHub
//
// https://github.com/dart-lang/language/issues/723
const dayFromInt = DayImpl.fromInt;
int dayToInt(Day d) => d.toInt();
const matchDay = DayImpl.match;

extension DayImpl on Day {
  static Day? fromInt(int? i) =>
      i == null || [-1, 5].contains(i) ? null : Day.values[i];

  int toInt() => Day.values.indexOf(this);

  static Day? match(String s) {
    s = s.toLowerCase();
    if (s.isEmpty || s.contains('null') || s.contains('none')) {
      return null;
    } else if (s.contains('mo')) {
      return Day.monday;
    } else if (s.contains('di') || s.contains('tue')) {
      return Day.tuesday;
    } else if (s.contains('mi') || s.contains('wed')) {
      return Day.wednesday;
    } else if (s.contains('do') || s.contains('thu')) {
      return Day.thursday;
    } else if (s.contains('fr')) {
      return Day.friday;
    } else {
      throw UnknownDayException(s);
    }
  }
}

class Substitution extends Comparable {
  // TODO: think about the ordering of attributes
  String affectedClass;
  int lesson;
  String? orgTeacher;
  String subTeacher;
  String subject;
  String notes;
  String? room;

  Substitution(
    this.affectedClass,
    this.lesson,
    this.subTeacher,
    this.subject, {
    this.notes = '',
    this.orgTeacher,
    this.room,
  });

  Substitution.raw(
    this.lesson, {
    required String affectedClass,
    required this.subTeacher,
    required this.subject,
    required this.notes,
    this.orgTeacher,
    this.room,
  }) : affectedClass = affectedClass.isNotEmpty && affectedClass[0] == '0'
            ? affectedClass.substring(1).toLowerCase()
            : affectedClass.toLowerCase();

  // TODO: more smarts (see #13)
  static Parser fromUntis(List<String> h) =>
      h.length < 6 ? fromUntis2020(h) : fromUntis2021(h);

  static Parser fromUntis2021(_) => (lesson, e) => Substitution.raw(
        lesson,
        affectedClass: e[0],
        subTeacher: e[2],
        subject: e[3],
        notes: e[5],
        orgTeacher: e[4],
      );

  static Parser fromUntis2020(_) => (lesson, e) => Substitution.raw(
        lesson,
        affectedClass: e[0],
        subTeacher: e[2],
        subject: e[3],
        notes: e[4],
      );

  static Parser fromUntis2019(_) => (lesson, e) => Substitution.raw(
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
        room = json['room'];

  dynamic toJson() => {
        'class': affectedClass,
        'lesson': lesson,
        'sub_teacher': subTeacher,
        'subject': subject,
        'notes': notes,
        // TODO: remove?
        'free': isFree,
        if (orgTeacher != null) 'org_teacher': orgTeacher,
        if (room != null) 'room': room,
      };

  bool get isFree => subTeacher.contains('---');

// TODO: scream at dart people about algebraic data types
  @override
  int compareTo(dynamic other) {
    if (other is int) {
      return lesson.compareTo(other);
    } else if (other is Substitution) {
      var tc = affectedClass, oc = other.affectedClass;
      if (tc.length > 1 && !'0123456789'.contains(tc[1])) tc = '0' + tc;
      if (oc.length > 1 && !'0123456789'.contains(oc[1])) oc = '0' + oc;
      final c = tc.compareTo(oc);
      return c != 0 ? c : lesson.compareTo(other.lesson);
    } else {
      return 0;
    }
  }

  @override
  String toString() =>
      "['$affectedClass', $lesson, '$orgTeacher' → '$subTeacher' at '$room', '$subject', '$notes', $isFree]";
}

final _tag = RegExp(r'</?.+?>');
final _unescape = HtmlUnescape();
String _str(dom.Element e) =>
    _unescape.convert(e.innerHtml.replaceAll(_tag, '')).trim();

// TODO: try to come up with a better, more functional algorithm
List<int> _parseIntsFromString(String s) {
  final out = <int>[];
  var lastindex = 0;
  for (var i = 0; i < s.length; i++) {
    if (!'0123456789'.contains(s[i])) {
      if (lastindex != i) out.add(int.parse(s.substring(lastindex, i)));
      lastindex = i + 1;
    }
  }
  final i = int.tryParse(s.substring(lastindex));
  if (i != null) out.add(i);
  return out;
}

class Page {
  Day? day;
  List<Substitution> subs;
  String date;
  // TODO: add info from above the table

  Page(this.day, this.subs, this.date);

  Page.fromJson(dynamic json)
      : day = dayFromInt(json['day']),
        date = json['date'],
        subs = json['subs'].map<Substitution>(Substitution.fromJson).toList();

  dynamic toJson() => {
        // TODO: scream at the dart team
        if (day != null) 'day': day?.toInt(),
        'date': date,
        'subs': subs.map((sub) => sub.toJson()).toList(),
      };

  @override
  String toString() => '$day ($date): $subs';

  // TODO: is this just badly named or a bad function?
  static List<Page> searchInPages(
    Iterable<Page> pages,
    bool Function(Substitution) predicate,
  ) =>
      pages
          .map((p) => Page(p.day, p.subs.where(predicate).toList(), p.date))
          .toList();

  static Page? parsePage(
    String html, [
    ParserBuilder parser = Substitution.fromUntis,
  ]) {
    final rawHtml = html
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        //just fyi: these regexes only work because there are no more newlines
        // TODO: rethink all the regexes
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
    // TODO: try to find a way to have less in this try block
    try {
      // TODO: let's also rethink the parsing code in general
      var html = parse(rawHtml).first.children[1].children; //body
      final pageTitle =
          searchFirst(html, (e) => e.className.contains('mon_title'))!
              .innerHtml;
      html = searchFirst(html, (e) => e.className.contains('mon_list'))!
          .children
          .first //for some reason <table>s like to contain <tbody>s
          .children;
      final subs = <Substitution>[];
      final p = parser(html[0].children.map(_str).toList());
      for (var i = 1; i < html.length; i++) {
        final e = html[i].children.map(_str).toList();
        // TODO: find a way for the `parser` to determine what the lesson is
        for (final lesson in _parseIntsFromString(e[1])) {
          subs.add(p(lesson, e));
        }
      }
      return Page(matchDay(pageTitle), subs, pageTitle);
    } catch (e) {
      return null;
    }
  }

  static Iterable<Page> parsePages(
    Iterable<String> htmls, [
    ParserBuilder parser = Substitution.fromUntis,
  ]) =>
      htmls.map(parsePage).whereNotNull();
}
