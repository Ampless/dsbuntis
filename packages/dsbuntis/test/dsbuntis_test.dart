import 'dart:convert';

import 'package:dsbuntis/dsbuntis.dart';
import 'package:schttp/schttp.dart';
import 'package:test/test.dart';
import 'package:untis/untis.dart' as untis;

import '../../../testlib.dart';

final Map<String, String> dsbTest1Cache = {
  '/authid': 'randomauthid',
  // TODO: make these correct
  '/dsbtimetables': '['
      '{"Childs":[{"Detail":"44a7def4-aaa3-4177-959d-e2921176cde9.htm","Preview":"asdf.png"}]},'
      '{"Childs":[{"Detail":"58424b67-1ebf-4152-8c37-17814ef93775.htm","Preview":"qwerty.jpg"}]}'
      ']',
  '44a7def4-aaa3-4177-959d-e2921176cde9.htm':
      '<table class="mon_head"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">23.6.2020 Dienstag</div><table class="info" ><tr></tr><tr><td>Betroffene Klassen </td><td>11Q</td></tr></table><table class="mon_list" ><tr></tr><tr><td>11Q</td><td> 7 &nbsp; 8 </td><td>---</td><td>1sk1</td><td>&nbsp;Aschi</td><td> </td></tr></table>Untis Stundenplan Software',
  '58424b67-1ebf-4152-8c37-17814ef93775.htm':
      '<table class="mon_head"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">24.6.2020 Mittwoch</div><table class="info" ><tr></tr><tr><td>Betroffene Klassen </td><td>05a, 05b, 05c, 05d, Heim</td></tr></table><table class="mon_list" ><tr></tr><tr><td>05abcd</td><td>6</td><td>---</td><td>Ethik</td><td> </td></tr></table>Untis Stundenplan Software',
};

final List<List<Page>> dsbTest1Expct = [
  [
    Page(
      untis.Day.tuesday,
      [
        untis.Substitution('11q', 7, '---', '1sk1', orgTeacher: 'Aschi'),
        untis.Substitution('11q', 8, '---', '1sk1', orgTeacher: 'Aschi'),
      ],
      '23.6.2020 Dienstag',
      '',
      'https://light.dsbcontrol.de/DSBlightWebsite/Data/asdf.png',
      null,
    ),
  ],
  [
    Page(
      untis.Day.wednesday,
      [],
      '24.6.2020 Mittwoch',
      '',
      'https://light.dsbcontrol.de/DSBlightWebsite/Data/qwerty.jpg',
      null,
    ),
  ],
];

final Map<String, String> dsbTest2Cache = {
  '/authid': 'randomauthid',
  '/dsbtimetables': '['
      '{"Childs":[{"Detail":"44a7def4-aaa3-4177-959d-e2921176cde9.htm","Preview":"lol.gif"}]},'
      '{"Childs":[{"Detail":"58424b67-1ebf-4152-8c37-17814ef93775.htm","Preview":"lel.bmp"}]}'
      ']',
  '44a7def4-aaa3-4177-959d-e2921176cde9.htm':
      '<table class="mon_head"> <tr> <td></td> <td></td> <td> null 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">23.6.2020 Dienstag</div><table class="info" ><tr></tr><tr><td>Betroffene Klassen </td><td>11Q</td></tr></table><table class="mon_list" ><tr></tr></table>Untis Stundenplan Software',
  '58424b67-1ebf-4152-8c37-17814ef93775.htm':
      '<table class="mon_head"> <tr> <td></td> <td></td> <td> GYM. NULL Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">24.6.2020 Mittwoch</div><table class="mon_list" ><tr></tr></table>Untis Stundenplan Software',
};

final List<List<Page>> dsbTest2Expct = [
  [
    Page(
      untis.Day.tuesday,
      [],
      '23.6.2020 Dienstag',
      '',
      'https://light.dsbcontrol.de/DSBlightWebsite/Data/lol.gif',
      null,
    ),
  ],
  [
    Page(
      untis.Day.wednesday,
      [],
      '24.6.2020 Mittwoch',
      '',
      'https://light.dsbcontrol.de/DSBlightWebsite/Data/lel.bmp',
      null,
    ),
  ],
];

void assertPlanListsEqual(List<List<Page>> l1, List<List<Page>> l2) {
  expect(l1.length, l2.length);
  for (var k = 0; k < l1.length; k++) {
    expect(l1[k].length, l2[k].length);
    for (var i = 0; i < l1[k].length; i++) {
      expect(l1[k][i].date, l2[k][i].date);
      expect(l1[k][i].day, l2[k][i].day);
      expect(l1[k][i].subs.length, l2[k][i].subs.length);
      for (var j = 0; j < l1[k][i].subs.length; j++) {
        expect(l1[k][i].subs[j].affectedClass, l2[k][i].subs[j].affectedClass);
        expect(l1[k][i].subs[j].lesson, l2[k][i].subs[j].lesson);
        expect(l1[k][i].subs[j].isFree, l2[k][i].subs[j].isFree);
        expect(l1[k][i].subs[j].notes, l2[k][i].subs[j].notes);
        expect(l1[k][i].subs[j].subject, l2[k][i].subs[j].subject);
        expect(l1[k][i].subs[j].subTeacher, l2[k][i].subs[j].subTeacher);
        expect(l1[k][i].subs[j].orgTeacher, l2[k][i].subs[j].orgTeacher);
      }
    }
  }
}

TestCase dsbTestCase(
  String username,
  String password,
  Map<String, String> htmlCache,
  List<List<Page>> expectedPlans,
  String stage,
  String char,
) =>
    () async {
      final plans = await getAllSubs(
        username,
        password,
        http: SCacheClient(
          getCache: (u) => htmlCache[
              htmlCache.keys.firstWhere((k) => u.toString().contains(k))],
        ),
      ).then((x) => x.search((sub) =>
          sub.affectedClass.contains(stage) &&
          sub.affectedClass.contains(char)));
      for (final plan in plans) {
        for (final page in plan) {
          page.subs.sort();
        }
      }
      assertPlanListsEqual(plans.toNestedList(), expectedPlans);
    };

TestCase jsonTestCase(List<List<Page>> plans) => () async {
      assertPlanListsEqual(
        Page.plansFromJsonString(jsonEncode(plans)).toNestedList(),
        plans,
      );
    };

TestCase publicTestCase(
  String username,
  String password,
  untis.ParserBuilder parser,
) =>
    () =>
        getAllSubs(username, password, downloadPreviews: true, parser: parser);

void main() {
  // TODO: and then reintroduce these
  // tests([
  //   dsbTestCase('', 'null', dsbTest1Cache, dsbTest1Expct, '11', 'q'),
  //   dsbTestCase('null', '', dsbTest1Cache, dsbTest1Expct, '11', ''),
  //   dsbTestCase('null', 'null', dsbTest2Cache, dsbTest2Expct, '', 'q'),
  //   dsbTestCase('invalid', 'none', dsbTest2Cache, dsbTest2Expct, '', ''),
  // ], 'dsb');
  tests([
    jsonTestCase(dsbTest1Expct),
    jsonTestCase(dsbTest2Expct),
  ], 'json');
  tests([
    publicTestCase('187801', 'public', untis.Substitution.fromUntis2019),
    // TODO: make this a better test
    publicTestCase(
        '152321', 'krsmrz21', untis.Substitution.fromUntis), //THANKS @3liFi!
  ], 'public');
}
