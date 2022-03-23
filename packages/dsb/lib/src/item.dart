class Item {
  String id;
  String date;
  String title;
  String detail;
  String tags;
  int conType;
  int prio;
  int index;
  List<Item> childs;
  String preview;

  Item({
    required this.id,
    required this.date,
    required this.title,
    required this.detail,
    required this.tags,
    required this.conType,
    required this.prio,
    required this.index,
    required this.childs,
    required this.preview,
  });

  static Item fromJson(dynamic json) => Item(
        id: json['Id'],
        date: json['Date'],
        title: json['Title'],
        detail: json['Detail'],
        tags: json['Tags'],
        conType: json['ConType'],
        prio: json['Prio'],
        index: json['Index'],
        childs: List<Item>.from(json['Childs'].map(fromJson)),
        preview: json['Preview'],
      );

  dynamic toJson() => {
        'Id': id,
        'Date': date,
        'Title': title,
        'Detail': detail,
        'Tags': tags,
        'ConType': conType,
        'Prio': prio,
        'Index': index,
        'Childs': childs,
        'Preview': preview,
      };
}
