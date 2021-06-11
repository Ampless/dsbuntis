import 'dart:convert';

import 'package:dsbuntis/src/exceptions.dart';
import 'package:schttp/schttp.dart';

String _authUrl(String e, String a, String o, String u, String p) =>
    '$e/authid?bundleid=de.heinekingmedia.dsbmobile' +
    '&appversion=$a&osversion=$o&pushid&user=$u&password=$p';

class Session {
  String token;
  ScHttpClient http;

  Session(this.token, this.http);

  static Future<Session> login(
    String username,
    String password, {
    ScHttpClient? http,
    String endpoint = 'https://mobileapi.dsbcontrol.de',
    String appVersion = '36',
    String osVersion = '30',
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
    return Session(tkn, http);
  }

  Future<dynamic> getJson(
    String name, {
    String endpoint = 'https://mobileapi.dsbcontrol.de',
  }) async =>
      jsonDecode(await http.get(
        '$endpoint/$name?authid=$token',
        ttl: Duration(minutes: 15),
      ));
}
