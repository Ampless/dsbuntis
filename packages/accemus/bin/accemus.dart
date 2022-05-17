import 'dart:convert' show JsonEncoder, jsonDecode;
import 'dart:io';
import 'dart:typed_data';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/args.dart';
import 'package:dsb/dsb.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:hex/hex.dart';
import 'package:highlight/highlight.dart';
import 'package:schttp/schttp.dart';

final green = AnsiPen()..green(),
    yellow = AnsiPen()..yellow(),
    magenta = AnsiPen()..magenta(),
    red = AnsiPen()..red();

String skrcli(Result r) {
  var str = '';

  void _traverse(Node node, int? color) {
    if (node.className != null &&
        ((node.value != null && node.value!.isNotEmpty) ||
            (node.children != null && node.children!.isNotEmpty))) {
      color = node.className.hashCode % 256;
    }

    if (node.value != null) {
      str +=
          color != null ? (AnsiPen()..xterm(color))(node.value!) : node.value!;
    } else if (node.children != null) {
      node.children!.forEach((c) => _traverse(c, color));
    }
  }

  r.nodes!.forEach((c) => _traverse(c, null));
  return str;
}

const jsonEncoder = JsonEncoder.withIndent('  ');
String jsonEncode(Object o) => jsonEncoder.convert(o);

class LogHttpClient extends ScHttpClient {
  @override
  Future<Uint8List> getBinUri(Uri url,
      {Map<String, String> headers = const {},
      bool readCache = true,
      bool writeCache = true,
      Duration? ttl}) async {
    final res = await super.getBinUri(url,
        headers: headers,
        readCache: readCache,
        writeCache: writeCache,
        ttl: ttl);
    print('${green('GET_BIN')} ${yellow(url)} → ${HEX.encode(res)}');
    return res;
  }

  @override
  Future<String> getUri(Uri url,
      {bool readCache = true,
      bool writeCache = true,
      Duration? ttl,
      Map<String, String> headers = const {},
      String Function(List<int>)? defaultCharset,
      String Function(List<int>)? forcedCharset}) async {
    final res = await super.getUri(url,
        readCache: readCache,
        writeCache: writeCache,
        ttl: ttl,
        headers: headers,
        defaultCharset: defaultCharset,
        forcedCharset: forcedCharset);
    print('${green('GET')} ${yellow(url)} → $res');
    return res;
  }

  @override
  Future<String> postUri(Uri url, Object body,
      {Map<String, String> headers = const {},
      bool readCache = true,
      bool writeCache = true,
      Duration? ttl,
      String Function(List<int>)? defaultCharset,
      String Function(List<int>)? forcedCharset}) async {
    final res = await super.postUri(url, body,
        readCache: readCache,
        writeCache: writeCache,
        ttl: ttl,
        headers: headers,
        defaultCharset: defaultCharset,
        forcedCharset: forcedCharset);
    print('${green('POST')} ${yellow(body)} → ${magenta(url)} → $res');
    return res;
  }
}

void main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('session',
        abbr: 's',
        help: 'The session to be used instead of logging in',
        valueHelp: 'token')
    ..addOption('endpoint',
        abbr: 'e',
        help: 'The endpoint to use',
        valueHelp: 'backend',
        defaultsTo: Session.defaultEndpoint)
    ..addOption('preview-endpoint',
        abbr: 'p',
        help: 'The endpoint to use for previews',
        valueHelp: 'backend',
        defaultsTo: Session.defaultPreviewEndpoint)
    ..addOption('app-version',
        abbr: 'a',
        help: 'The DSBMobile version to report to the server',
        valueHelp: 'value',
        defaultsTo: Session.defaultAppVersion)
    ..addOption('os-version',
        abbr: 'o',
        help: 'The OS version to report to the server',
        valueHelp: 'value',
        defaultsTo: Session.defaultOsVersion)
    ..addOption('bundle-id',
        abbr: 'b',
        help: 'The bundle id to report to the server',
        valueHelp: 'value',
        defaultsTo: Session.defaultBundleId)
    ..addFlag('login-only',
        abbr: 'l', help: 'Only log in and print the session', negatable: false)
    ..addFlag('help',
        abbr: 'h', help: 'Display available options', negatable: false)
    ..addFlag('stack-traces',
        abbr: 't',
        help: 'Print full stack traces when an error occurs',
        negatable: false)
    ..addOption('json', abbr: 'j', help: 'Get a JSON by name')
    ..addFlag('timetables',
        abbr: 'T', help: 'Equivalent to --json dsbtimetables', negatable: false)
    ..addFlag('documents',
        abbr: 'D', help: 'Equivalent to --json dsbdocuments', negatable: false)
    ..addFlag('news',
        abbr: 'N', help: 'Equivalent to --json newstab', negatable: false)
    ..addFlag('merge',
        abbr: 'm', help: 'Merge all pages from each plan', negatable: false)
    ..addFlag('log-requests',
        abbr: 'r', help: 'Log all HTTP requests', negatable: false);

  var traces = false;
  try {
    final args = parser.parse(argv);
    final http = args['log-requests'] ? LogHttpClient() : ScHttpClient();
    traces = args['stack-traces'];
    if (args['help']) {
      stderr.writeln('accemus [options] [username] [password]');
      stderr.writeln('accemus [options] -s [session]');
      stderr.writeln();
      stderr.writeln(parser.usage);
    } else if (args['login-only']) {
      if (args.wasParsed('session')) {
        throw 'You can\'t log in with a session.';
      }
      if (args.rest.isEmpty) {
        throw 'No username/ID provided.';
      }
      if (args.rest.length < 2) {
        throw 'No password provided.';
      }
      final session = await Session.login(args.rest[0], args.rest[1],
          http: http,
          endpoint: args['endpoint'],
          appVersion: args['app-version'],
          bundleId: args['bundle-id'],
          osVersion: args['os-version'],
          previewEndpoint: args['preview-endpoint']);
      print(session.token);
    } else {
      if (!args.wasParsed('session') && args.rest.length != 2) {
        throw 'No credentials or session provided.';
      }
      final session = args.wasParsed('session')
          ? Session(args['session'],
              http: http,
              endpoint: args['endpoint'],
              previewEndpoint: args['preview-endpoint'])
          : await Session.login(args.rest[0], args.rest[1],
              http: http,
              endpoint: args['endpoint'],
              previewEndpoint: args['preview-endpoint'],
              appVersion: args['app-version'],
              osVersion: args['os-version'],
              bundleId: args['bundle-id']);
      if (args['timetables'] ||
          args['documents'] ||
          args['news'] ||
          args.wasParsed('json')) {
        var json = await session.getJsonString(
          args['timetables']
              ? 'dsbtimetables'
              : args['documents']
                  ? 'dsbdocuments'
                  : args['news']
                      ? 'newstab'
                      : args['json'],
        );
        try {
          json = jsonEncode(jsonDecode(json));
        } catch (e) {
          stderr.writeln(red(
              'Timetable JSON is actually not valid JSON: ${traces && e is Error ? '$e\n\n${e.stackTrace}' : '$e'}'));
        }
        print(skrcli(highlight.parse(json, language: 'json')));
      } else {
        final p =
            await session.getTimetables().then(session.downloadAndParsePlans);
        print(skrcli(highlight.parse(
            jsonEncode(args['merge'] ? p.merge().toList() : p.toNestedList()),
            language: 'json')));
      }
    }
    exit(0);
  } catch (e) {
    stderr.writeln('accemus [options] [username] [password]');
    stderr.writeln('accemus [options] -s [session]');
    stderr.writeln();
    stderr.writeln(parser.usage);
    stderr.writeln();
    stderr.writeln(red(traces && e is Error ? '$e\n\n${e.stackTrace}' : e));
    exit(1);
  }
}
