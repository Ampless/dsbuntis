import 'package:dsbuntis/dsbuntis.dart';

import 'testlib.dart';

testCase dayTestCase(input, expct, bool error, [Function tfunc = matchDay]) =>
    expectTestCase(() async => tfunc(input), expct, error);

List<testCase> dayTestCases = [
  dayTestCase('', Day.Null, false),
  dayTestCase('_kEkW_freiTaG_llUUULW', Day.Friday, false),
  dayTestCase('FvCkDaY', null, true),
  dayTestCase('Montag', Day.Monday, false),
  dayTestCase('Monday', Day.Monday, false),
  dayTestCase('Dienstag', Day.Tuesday, false),
  dayTestCase('Tuesday', Day.Tuesday, false),
  dayTestCase('Mittwoch', Day.Wednesday, false),
  dayTestCase('Wednesday', Day.Wednesday, false),
  dayTestCase('Donnerstag', Day.Thursday, false),
  dayTestCase('Thursday', Day.Thursday, false),
  dayTestCase('Freitag', Day.Friday, false),
  dayTestCase('Friday', Day.Friday, false),
  dayTestCase(Day.Monday, 0, false, dayToInt),
  dayTestCase(Day.Tuesday, 1, false, dayToInt),
  dayTestCase(Day.Wednesday, 2, false, dayToInt),
  dayTestCase(Day.Thursday, 3, false, dayToInt),
  dayTestCase(Day.Friday, 4, false, dayToInt),
  dayTestCase(Day.Null, -1, false, dayToInt),
  dayTestCase(0, Day.Monday, false, dayFromInt),
  dayTestCase(1, Day.Tuesday, false, dayFromInt),
  dayTestCase(2, Day.Wednesday, false, dayFromInt),
  dayTestCase(3, Day.Thursday, false, dayFromInt),
  dayTestCase(4, Day.Friday, false, dayFromInt),
  dayTestCase(-1, Day.Null, false, dayFromInt),
  dayTestCase(5, Day.Null, false, dayFromInt),
];

void main() {
  tests(dayTestCases, 'day');
}
