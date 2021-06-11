import 'dart:convert';

import 'package:dsbuntis/src/exceptions.dart';
import 'package:schttp/schttp.dart';

String _authUrl(String e, String a, String o, String u, String p) =>
    '$e/authid?bundleid=de.heinekingmedia.dsbmobile' +
    '&appversion=$a&osversion=$o&pushid&user=$u&password=$p';

class Session {
  String endpoint;
  String token;
  ScHttpClient http;
  String previewEndpoint;

  Session(this.endpoint, this.token, this.http, this.previewEndpoint);

  static Future<Session> login(
    String username,
    String password, {
    ScHttpClient? http,
    String endpoint = 'https://mobileapi.dsbcontrol.de',
    String appVersion = '36',
    String osVersion = '30',
    String previewEndpoint = 'https://light.dsbcontrol.de/DSBlightWebsite/Data',
  }) async {
    http ??= ScHttpClient();
    final tkn = await http
        .get(_authUrl(endpoint, appVersion, osVersion, username, password),
            readCache: false, writeCache: false)
        .then((tkn) {
      if (tkn.isEmpty) throw AuthenticationException();
      // TODO: this is a horrible piece of code, when im sober again, i should
      //       fix it
      try {
        throw jsonDecode(tkn)['Message'];
      } on Exception {
        return tkn.replaceAll('"', '');
      } on Error {
        return tkn.replaceAll('"', '');
      } on String catch (s) {
        throw AuthenticationException(s);
      }
    });
    return Session(endpoint, tkn, http, previewEndpoint);
  }

  Future<dynamic> getJson(String name) async => jsonDecode(await http.get(
        '$endpoint/$name?authid=$token',
        ttl: Duration(minutes: 15),
      ));

  Future<List> getTimetableJson() async {
    final json = await getJson('dsbtimetables');
    if (json is Map && json.containsKey('Message'))
      throw DsbException(json['Message']);
    return json;
  }
}
