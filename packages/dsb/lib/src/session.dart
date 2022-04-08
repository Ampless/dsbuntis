import 'dart:convert';

import 'package:dsb/src/exceptions.dart';
import 'package:dsb/src/item.dart';
import 'package:schttp/schttp.dart';

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
