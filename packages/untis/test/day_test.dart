import 'package:untis/untis.dart';

import '../../../testlib.dart';

TestCase dayTestCase(input, expct, bool error, [Function tfunc = matchDay]) =>
    expectTestCase(() async => tfunc(input), expct, error);

void main() {
  tests([
    dayTestCase('', null, false),
    dayTestCase('_kEkW_freiTaG_llUUULW', Day.friday, false),
    dayTestCase('FvCkDaY', null, true),
    dayTestCase('Montag', Day.monday, false),
    dayTestCase('Monday', Day.monday, false),
    dayTestCase('Dienstag', Day.tuesday, false),
    dayTestCase('Tuesday', Day.tuesday, false),
    dayTestCase('Mittwoch', Day.wednesday, false),
    dayTestCase('Wednesday', Day.wednesday, false),
    dayTestCase('Donnerstag', Day.thursday, false),
    dayTestCase('Thursday', Day.thursday, false),
    dayTestCase('Freitag', Day.friday, false),
    dayTestCase('Friday', Day.friday, false),
    dayTestCase(Day.monday, 0, false, dayToInt),
    dayTestCase(Day.tuesday, 1, false, dayToInt),
    dayTestCase(Day.wednesday, 2, false, dayToInt),
    dayTestCase(Day.thursday, 3, false, dayToInt),
    dayTestCase(Day.friday, 4, false, dayToInt),
    dayTestCase(0, Day.monday, false, dayFromInt),
    dayTestCase(1, Day.tuesday, false, dayFromInt),
    dayTestCase(2, Day.wednesday, false, dayFromInt),
    dayTestCase(3, Day.thursday, false, dayFromInt),
    dayTestCase(4, Day.friday, false, dayFromInt),
    dayTestCase(-1, null, false, dayFromInt),
    dayTestCase(5, null, false, dayFromInt),
  ], 'day');
}
