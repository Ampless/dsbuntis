import 'dart:convert';

import 'package:schttp/schttp.dart';

class DsbException implements Exception {
  final String _message;
  DsbException([this._message = 'A DSB error has occurred.']);

  @override
  String toString() => _message;
}

class AuthenticationException extends DsbException {
  AuthenticationException(
      // TODO: use super-parameters (Dart feature 1855)
      [String _message = 'An authentication error has occurred.'])
      : super(_message);
}

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
            Uri.encodeFull('$endpoint/authid'
                '?bundleid=$bundleId'
                '&appversion=$appVersion'
                '&osversion=$osVersion'
                '&pushid'
                '&user=$username'
                '&password=$password'),
            ttl: Duration(days: 30))
        .then((tkn) {
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
        defaultCharset: String.fromCharCodes,
      );

  Future<dynamic> getJson(String name) async {
    final j = await getJsonString(name).then(jsonDecode);
    if (j is Map && j.containsKey('Message')) throw DsbException(j['Message']);
    return j;
  }

  // TODO: i think this can be done better
  Future<List<Item>> get(String name) =>
      getJson(name).then((x) => x.map<Item>(Item.fromJson).toList());

  Future<String> getTimetablesJsonString() => getJsonString('dsbtimetables');
  Future<dynamic> getTimetablesJson() => getJson('dsbtimetables');
  Future<List<Item>> getTimetables() => get('dsbtimetables');

  Future<String> getDocumentsJsonString() => getJsonString('dsbdocuments');
  Future<dynamic> getDocumentsJson() => getJson('dsbdocuments');
  Future<List<Item>> getDocuments() => get('dsbdocuments');

  Future<String> getNewsJsonString() => getJsonString('newstab');
  Future<dynamic> getNewsJson() => getJson('newstab');
  Future<List<Item>> getNews() => get('newstab');
}
