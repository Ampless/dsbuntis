import 'package:untis/src/page.dart';

class Substitution extends Comparable {
  String affectedClass;
  int lesson;
  String? orgTeacher;
  String subTeacher;
  String subject;
  String notes;
  String? room;
  bool isFree;

  Substitution(
    this.affectedClass,
    this.lesson,
    this.subTeacher,
    this.subject,
    this.isFree, {
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
  })  : affectedClass = affectedClass.isNotEmpty && affectedClass[0] == '0'
            ? affectedClass.substring(1).toLowerCase()
            : affectedClass.toLowerCase(),
        isFree = subTeacher.contains('---');

  // TODO: more smarts
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
        isFree = json['free'],
        room = json['room'];

  Map<String, dynamic> toJson() => {
        'class': affectedClass,
        'lesson': lesson,
        'sub_teacher': subTeacher,
        'subject': subject,
        'notes': notes,
        'free': isFree,
        if (orgTeacher != null) 'org_teacher': orgTeacher,
        if (room != null) 'room': room,
      };

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
