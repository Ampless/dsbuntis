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
        room = json['room'];

  Map<String, dynamic> toJson() => {
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
    // TODO: for convenience we might not want to throw when there is a weirdly
    //       formatted class. so let's just make this safe.
    final tp = int.tryParse(affectedClass[1]) == null ? '0' : '';
    final op = int.tryParse(other.affectedClass[1]) == null ? '0' : '';
    final c = (tp + affectedClass).compareTo(op + other.affectedClass);
    return c != 0 ? c : lesson.compareTo(other.lesson);
  }

  @override
  String toString() =>
      "['$affectedClass', $lesson, '$orgTeacher' → '$subTeacher' at '$room', '$subject', '$notes', $isFree]";
}