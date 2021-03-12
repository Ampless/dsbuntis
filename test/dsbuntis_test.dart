import 'package:schttp/schttp.dart';
import 'package:test/test.dart';
import 'package:dsbuntis/dsbuntis.dart';

import 'testlib.dart';

final Map<String, String> dsbTest1Cache = {
  'GetData':
      '{\"d\":\"H4sIAAAAAAAEAOWX3W6bMBSA7yftHSKuS/gxBOjd1G1apaaqlmo301QZfEhQiYmwaTdVfZu9yV5sJm4oP4ayLO00NTco5/98dk4Od2/fTCbaZ2BFyqOMgHY8MY9qsgXHvGCnNM6ERtOkSghzfkoJfBdC3arbz4EWpxzWTGi+lvLJ5E4+hMnORWaQoiijZwm9foy+FV8mPC1rES4rnHKoqU5WSUpq4RspetJ0Uq0437Bjw8CbzZSwUGh4nqVTAgYTDSeRgSnJs4QkQsOMy2QNHIcpTDd0qTWjVpVepL9+UmhpP2cZF8pGfWUppNnvg/g95qBUVEm6LqKwJFU74SVTKk4yevljAx1CQnWRJ5lKrkbacxryc9cWVH07DvYIxI6OMUa6Y3meHrgB0cEObMvyZhGBoF10g4+NpuZsapu2OTH9Y9dVGlfMvkDOc+AFXV7Nrz5BwUEdvJfkIM0WUVul7qEqkfSQlXF76ZYfBWEZ8q8oSxh/QFri2dFmRcj4lWla0xVf98evYPf/Egnm2PAdK/CxG+pBFIsu/NjWMbiublrENy2YAYp8Y0yro4wGax66AfK0qluA+kwGboI8uoHbIHNUN+Jbfw64SeC2LPVw9DYy6HYAqvLed4WqAuvFdeLcdxz6Z4jrO7YTzjzdgjAWRbu27kdIfPV8y4E4QJ6nHgsHmCHzLF8CfRVDZF/MEsZ/NUTGtDrK6FUOkVH0XmSINAVt/17f5vDpRaTNga8yco7X24vKd5tha+87h9uTrKC8u4Uu8A2cYbZdrMsQPC/g0aCq/jFrK2NtE1YmGUiwa7G7kFvjF/KFWIh5sgT2b1fyBXCe0CUb2sg/JKJUSFMxtdvjeuz5soc0ex9vjFNWP9+jpwhZhyL0EYCEOLoeIrSz2Q9OrPZ+Rjj2oeC8C7OCD5HZvvHuRQWXoV8OCToUkrNs+QQTabEflVTluz+WZx2T5UMGFt1hSiFtvC5rc8ENUy43JBO5KA58pEOMZrrjOVgPUBDpQYjQjER+6CBH/NHc/wbNrhqraREAAA==\"}',
  '44a7def4-aaa3-4177-959d-e2921176cde9.htm':
      '<table class=\"mon_head\"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class=\"mon_title\">23.6.2020 Dienstag</div><table class=\"info\" ><tr></tr><tr><td>Betroffene Klassen </td><td>11Q</td></tr></table><table class=\"mon_list\" ><tr></tr><tr><td>11Q</td><td> 7 &nbsp; 8 </td><td>---</td><td>1sk1</td><td>&nbsp;Aschi</td><td> </td></tr></table>Untis Stundenplan Software',
  '58424b67-1ebf-4152-8c37-17814ef93775.htm':
      '<table class=\"mon_head\"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class=\"mon_title\">24.6.2020 Mittwoch</div><table class=\"info\" ><tr></tr><tr><td>Betroffene Klassen </td><td>05a, 05b, 05c, 05d, Heim</td></tr></table><table class=\"mon_list\" ><tr></tr><tr><td>05abcd</td><td>6</td><td>---</td><td>Ethik</td><td> </td></tr></table>Untis Stundenplan Software',
};

final List<Plan> dsbTest1Expct = [
  Plan(
    Day.Tuesday,
    [
      Substitution('11q', 7, '---', '1sk1', '', true, 'Aschi'),
      Substitution('11q', 8, '---', '1sk1', '', true, 'Aschi'),
    ],
    '23.6.2020 Dienstag',
    '',
  ),
  Plan(
    Day.Wednesday,
    [],
    '24.6.2020 Mittwoch',
    '',
  ),
];

final Map<String, String> dsbTest2Cache = {
  'GetData':
      '{\"d\":\"H4sIAAAAAAAEAOWX3W6bMBSA7yftHSKuS/gxBOjd1G1apaaqlmo301QZfEhQiYmwaTdVfZu9yV5sJm4oP4ayLO00NTco5/98dk4Od2/fTCbaZ2BFyqOMgHY8MY9qsgXHvGCnNM6ERtOkSghzfkoJfBdC3arbz4EWpxzWTGi+lvLJ5E4+hMnORWaQoiijZwm9foy+FV8mPC1rES4rnHKoqU5WSUpq4RspetJ0Uq0437Bjw8CbzZSwUGh4nqVTAgYTDSeRgSnJs4QkQsOMy2QNHIcpTDd0qTWjVpVepL9+UmhpP2cZF8pGfWUppNnvg/g95qBUVEm6LqKwJFU74SVTKk4yevljAx1CQnWRJ5lKrkbacxryc9cWVH07DvYIxI6OMUa6Y3meHrgB0cEObMvyZhGBoF10g4+NpuZsapu2OTH9Y9dVGlfMvkDOc+AFXV7Nrz5BwUEdvJfkIM0WUVul7qEqkfSQlXF76ZYfBWEZ8q8oSxh/QFri2dFmRcj4lWla0xVf98evYPf/Egnm2PAdK/CxG+pBFIsu/NjWMbiublrENy2YAYp8Y0yro4wGax66AfK0qluA+kwGboI8uoHbIHNUN+Jbfw64SeC2LPVw9DYy6HYAqvLed4WqAuvFdeLcdxz6Z4jrO7YTzjzdgjAWRbu27kdIfPV8y4E4QJ6nHgsHmCHzLF8CfRVDZF/MEsZ/NUTGtDrK6FUOkVH0XmSINAVt/17f5vDpRaTNga8yco7X24vKd5tha+87h9uTrKC8u4Uu8A2cYbZdrMsQPC/g0aCq/jFrK2NtE1YmGUiwa7G7kFvjF/KFWIh5sgT2b1fyBXCe0CUb2sg/JKJUSFMxtdvjeuz5soc0ex9vjFNWP9+jpwhZhyL0EYCEOLoeIrSz2Q9OrPZ+Rjj2oeC8C7OCD5HZvvHuRQWXoV8OCToUkrNs+QQTabEflVTluz+WZx2T5UMGFt1hSiFtvC5rc8ENUy43JBO5KA58pEOMZrrjOVgPUBDpQYjQjER+6CBH/NHc/wbNrhqraREAAA==\"}',
  '44a7def4-aaa3-4177-959d-e2921176cde9.htm':
      '<table class=\"mon_head\"> <tr> <td></td> <td></td> <td> null 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class=\"mon_title\">23.6.2020 Dienstag</div><table class=\"info\" ><tr></tr><tr><td>Betroffene Klassen </td><td>11Q</td></tr></table><table class=\"mon_list\" ><tr></tr></table>Untis Stundenplan Software',
  '58424b67-1ebf-4152-8c37-17814ef93775.htm':
      '<table class=\"mon_head\"> <tr> <td></td> <td></td> <td> GYM. NULL Stand: 23.06.2020 08:55 </td> </tr></table><div class=\"mon_title\">24.6.2020 Mittwoch</div><table class=\"mon_list\" ><tr></tr></table>Untis Stundenplan Software',
};

final List<Plan> dsbTest2Expct = [
  Plan(
    Day.Tuesday,
    [],
    '23.6.2020 Dienstag',
    '',
  ),
  Plan(
    Day.Wednesday,
    [],
    '24.6.2020 Mittwoch',
    '',
  ),
];

void assertPlanListsEqual(List<Plan> l1, List<Plan> l2) {
  expect(l1.length, l2.length);
  for (var i = 0; i < l1.length; i++) {
    expect(l1[i].date, l2[i].date);
    expect(l1[i].day, l2[i].day);
    expect(l1[i].subs.length, l2[i].subs.length);
    for (var j = 0; j < l1[i].subs.length; j++) {
      expect(l1[i].subs[j].affectedClass, l2[i].subs[j].affectedClass);
      expect(l1[i].subs[j].lesson, l2[i].subs[j].lesson);
      expect(l1[i].subs[j].isFree, l2[i].subs[j].isFree);
      expect(l1[i].subs[j].notes, l2[i].subs[j].notes);
      expect(l1[i].subs[j].subject, l2[i].subs[j].subject);
      expect(l1[i].subs[j].subTeacher, l2[i].subs[j].subTeacher);
      expect(l1[i].subs[j].orgTeacher, l2[i].subs[j].orgTeacher);
    }
  }
}

testCase dsbTestCase(
  String username,
  String password,
  Map<String, String> htmlCache,
  List<Plan> expectedPlans,
  String stage,
  String char, [
  Future<List<Plan>> Function(String, String, ScHttpClient, String, String)?
      tfunc,
]) =>
    () async {
      tfunc ??= (username, password, http, stage, char) async {
        final l = Plan.searchInPlans(
          await getAllSubs(
            username,
            password,
            http,
          ),
          (sub) =>
              sub.affectedClass.contains(stage) &&
              sub.affectedClass.contains(char),
        );
        l.forEach((plan) => plan.subs.sort());
        return l;
      };
      final plans = await tfunc!(username, password, ScHttpClient((url) {
        for (final key in htmlCache.keys)
          if (strcontain(key, url)) return htmlCache[key];
        return null;
      }), stage, char);
      assertPlanListsEqual(plans, expectedPlans);
    };

List<testCase> dsbTestCases = [
  dsbTestCase('null', 'null', dsbTest1Cache, dsbTest1Expct, '11', 'q'),
  dsbTestCase('null', 'null', dsbTest1Cache, dsbTest1Expct, '11', ''),
  dsbTestCase('null', 'null', dsbTest2Cache, dsbTest2Expct, '', 'q'),
  dsbTestCase('invalid', 'none', dsbTest2Cache, dsbTest2Expct, '', ''),
];

testCase jsonTestCase(List<Plan> plans) => () async {
      assertPlanListsEqual(Plan.plansFromJson(Plan.plansToJson(plans)), plans);
    };

List<testCase> jsonTestCases = [
  jsonTestCase(dsbTest1Expct),
  jsonTestCase(dsbTest2Expct),
];

void main() {
  tests(dsbTestCases, 'dsb');
  tests(jsonTestCases, 'json');
}
