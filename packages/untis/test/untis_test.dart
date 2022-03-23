import 'package:test/test.dart';
import 'package:untis/untis.dart';

import '../../../testlib.dart';

const untisTest1 = [
  '<table class="mon_head"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">23.6.2020 Dienstag</div><table class="info" ><tr></tr><tr><td>Betroffene Klassen </td><td>11Q</td></tr></table><table class="mon_list" ><tr></tr><tr><td>11Q</td><td> 7 &nbsp; 8 </td><td>---</td><td>1sk1</td><td>&nbsp;Aschi</td><td> </td></tr></table>Untis Stundenplan Software',
  '<table class="mon_head"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">24.6.2020 Mittwoch</div><table class="info" ><tr></tr><tr><td>Betroffene Klassen </td><td>05a, 05b, 05c, 05d, Heim</td></tr></table><table class="mon_list" ><tr></tr><tr><td>05abcd</td><td>6</td><td>---</td><td>Ethik</td><td> </td></tr></table>Untis Stundenplan Software',
];

final List<Plan> untisTest1Expct = [
  Plan(
    Day.tuesday,
    [
      Substitution('11q', 7, '---', '1sk1', true, orgTeacher: 'Aschi'),
      Substitution('11q', 8, '---', '1sk1', true, orgTeacher: 'Aschi'),
    ],
    '23.6.2020 Dienstag',
  ),
  Plan(Day.wednesday, [], '24.6.2020 Mittwoch'),
];

const untisTest2 = [
  '<table class="mon_head"> <tr> <td></td> <td></td> <td> null 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">23.6.2020 Dienstag</div><table class="info" ><tr></tr><tr><td>Betroffene Klassen </td><td>11Q</td></tr></table><table class="mon_list" ><tr></tr></table>Untis Stundenplan Software',
  '<table class="mon_head"> <tr> <td></td> <td></td> <td> GYM. NULL Stand: 23.06.2020 08:55 </td> </tr></table><div class="mon_title">24.6.2020 Mittwoch</div><table class="mon_list" ><tr></tr></table>Untis Stundenplan Software',
];

final List<Plan> untisTest2Expct = [
  Plan(Day.tuesday, [], '23.6.2020 Dienstag'),
  Plan(Day.wednesday, [], '24.6.2020 Mittwoch'),
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

TestCase untisTestCase(
  List<String> htmls,
  List<Plan> expectedPlans,
  String stage,
  String char,
) =>
    () async {
      final plans = Plan.searchInPlans(
        Plan.parsePlans(htmls),
        (sub) =>
            sub.affectedClass.contains(stage) &&
            sub.affectedClass.contains(char),
      );
      for (final plan in plans) {
        plan.subs.sort();
      }
      assertPlanListsEqual(plans, expectedPlans);
    };

List<TestCase> dsbTestCases = [
  untisTestCase(untisTest1, untisTest1Expct, '11', 'q'),
  untisTestCase(untisTest1, untisTest1Expct, '11', ''),
  untisTestCase(untisTest2, untisTest2Expct, '', 'q'),
  untisTestCase(untisTest2, untisTest2Expct, '', ''),
];

TestCase jsonTestCase(List<Plan> plans) => () async {
      assertPlanListsEqual(
        Plan.plansFromJsonString(Plan.plansToJsonString(plans)),
        plans,
      );
    };

List<TestCase> jsonTestCases = [
  jsonTestCase(untisTest1Expct),
  jsonTestCase(untisTest2Expct),
];

void main() {
  tests(dsbTestCases, 'dsb');
  tests(jsonTestCases, 'json');
}
