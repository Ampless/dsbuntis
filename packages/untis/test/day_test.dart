import 'package:tested/tested.dart';
import 'package:untis/untis.dart';

TestCase Function(A, B, bool) functionTestCase<A, B>(B Function(A) tfunc) =>
    (A input, B expct, bool error) =>
        expectTestCase(() async => tfunc(input), expct, error);

final matchTestCase = functionTestCase(Day.match);
final toIntTestCase = functionTestCase((Day d) => d.toInt());
final fromIntTestCase = functionTestCase(Day.fromInt);

void main() {
  tests([
    matchTestCase('', null, false),
    matchTestCase('_kEkW_freiTaG_llUUULW', Day.friday, false),
    matchTestCase('FvCkDaY', null, true),
    matchTestCase('Montag', Day.monday, false),
    matchTestCase('Monday', Day.monday, false),
    matchTestCase('Dienstag', Day.tuesday, false),
    matchTestCase('Tuesday', Day.tuesday, false),
    matchTestCase('Mittwoch', Day.wednesday, false),
    matchTestCase('Wednesday', Day.wednesday, false),
    matchTestCase('Donnerstag', Day.thursday, false),
    matchTestCase('Thursday', Day.thursday, false),
    matchTestCase('Freitag', Day.friday, false),
    matchTestCase('Friday', Day.friday, false),
    matchTestCase('samStag', Day.saturday, false),
    matchTestCase('_saturday', Day.saturday, false),
    matchTestCase('Sonntag', Day.sunday, false),
    matchTestCase('sunday', Day.sunday, false),
    toIntTestCase(Day.monday, 0, false),
    toIntTestCase(Day.tuesday, 1, false),
    toIntTestCase(Day.wednesday, 2, false),
    toIntTestCase(Day.thursday, 3, false),
    toIntTestCase(Day.friday, 4, false),
    toIntTestCase(Day.saturday, 6, false),
    toIntTestCase(Day.sunday, 7, false),
    fromIntTestCase(0, Day.monday, false),
    fromIntTestCase(1, Day.tuesday, false),
    fromIntTestCase(2, Day.wednesday, false),
    fromIntTestCase(3, Day.thursday, false),
    fromIntTestCase(4, Day.friday, false),
    fromIntTestCase(6, Day.saturday, false),
    fromIntTestCase(7, Day.sunday, false),
    fromIntTestCase(null, null, false),
    fromIntTestCase(-1, null, false),
    fromIntTestCase(5, null, false),
    fromIntTestCase(42, null, false),
    fromIntTestCase(-1337, null, false),
  ], 'day');
}
