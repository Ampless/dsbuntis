import 'dart:convert';

import 'package:schttp/schttp.dart';

/// An error was returned by DSBMobile.
class DsbException implements Exception {
  final String _message;
  DsbException(this._message);

  @override
  String toString() => _message;
}

/// The DSBMobile backend returned an empty token.
///
/// Usually this means that the username or password is invalid.
class AuthenticationException extends DsbException {
  AuthenticationException(
      [super._message = 'An authentication error has occurred.']);
}

/// A single `Item` from the DSBMobile API.
/// (https://github.com/Ampless/Adsignificamus#response-1)
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

  Item.fromJson(dynamic json)
      : id = json['Id'],
        date = json['Date'],
        title = json['Title'],
        detail = json['Detail'],
        tags = json['Tags'],
        conType = json['ConType'],
        prio = json['Prio'],
        index = json['Index'],
        childs = List<Item>.from(json['Childs'].map(Item.fromJson)),
        preview = json['Preview'];

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
  // TODO: maybe make this a uri in the next major
  static const defaultEndpoint = 'https://mobileapi.dsbcontrol.de';
  static const defaultPreviewEndpoint =
      'https://light.dsbcontrol.de/DSBlightWebsite/Data';
  static const defaultAppVersion = '36';
  static const defaultOsVersion = '30';
  static const defaultBundleId = 'de.heinekingmedia.dsbmobile';

  ScHttpClient http;
  String token;
  String endpoint;
  String previewEndpoint;

  Session(this.token,
      {this.endpoint = defaultEndpoint,
      http,
      this.previewEndpoint = defaultPreviewEndpoint})
      : http = http ?? ScHttpClient();

  /// Tries using the given [username] and [password] to log in.
  ///
  /// Makes an `Auth` request (https://github.com/Ampless/Adsignificamus#auth)
  /// to the [endpoint] using [http] with [appVersion], [osVersion] and
  /// [bundleId] encoded in the request. [previewEndpoint] is passed onto the
  /// raw constructor.
  static Future<Session> login(
    String username,
    String password, {
    ScHttpClient? http,
    String endpoint = defaultEndpoint,
    String appVersion = defaultAppVersion,
    String osVersion = defaultOsVersion,
    String bundleId = defaultBundleId,
    String previewEndpoint = defaultPreviewEndpoint,
    // TODO: support `pushid`
  }) async {
    http ??= ScHttpClient();
    final tkn = await http
        .get(
            '$endpoint/authid'
            '?bundleid=${Uri.encodeComponent(bundleId)}'
            '&appversion=${Uri.encodeComponent(appVersion)}'
            '&osversion=${Uri.encodeComponent(osVersion)}'
            '&pushid'
            '&user=${Uri.encodeComponent(username)}'
            '&password=${Uri.encodeComponent(password)}',
            ttl: Duration(days: 30))
        .then((tkn) {
      final json = jsonDecode(tkn);
      if (json is Map && json.containsKey('Message')) {
        throw DsbException(json['Message']);
      } else if (json == '') {
        throw AuthenticationException();
      }
      return json;
    });
    return Session(tkn,
        endpoint: endpoint, http: http, previewEndpoint: previewEndpoint);
  }

  Future<String> getJsonString(String name) => http.get(
        '$endpoint/${Uri.encodeComponent(name)}?authid=$token',
// TODO: think about ttl parameter
        ttl: Duration(minutes: 15),
        defaultCharset: String.fromCharCodes,
      );

  Future<dynamic> getJson(String name) async {
    final j = await getJsonString(name).then(jsonDecode);
    if (j is Map && j.containsKey('Message')) throw DsbException(j['Message']);
    return j;
  }

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
