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
    matchTestCase('_kEkW_freiTaG_llUUULW', .friday, false),
    matchTestCase('FvCkDaY', null, true),
    matchTestCase('Montag', .monday, false),
    matchTestCase('Monday', .monday, false),
    matchTestCase('Dienstag', .tuesday, false),
    matchTestCase('Tuesday', .tuesday, false),
    matchTestCase('Mittwoch', .wednesday, false),
    matchTestCase('Wednesday', .wednesday, false),
    matchTestCase('Donnerstag', .thursday, false),
    matchTestCase('Thursday', .thursday, false),
    matchTestCase('Freitag', .friday, false),
    matchTestCase('Friday', .friday, false),
    matchTestCase('samStag', .saturday, false),
    matchTestCase('_saturday', .saturday, false),
    matchTestCase('Sonntag', .sunday, false),
    matchTestCase('sunday', .sunday, false),
    toIntTestCase(.monday, 0, false),
    toIntTestCase(.tuesday, 1, false),
    toIntTestCase(.wednesday, 2, false),
    toIntTestCase(.thursday, 3, false),
    toIntTestCase(.friday, 4, false),
    toIntTestCase(.saturday, 6, false),
    toIntTestCase(.sunday, 7, false),
    fromIntTestCase(0, .monday, false),
    fromIntTestCase(1, .tuesday, false),
    fromIntTestCase(2, .wednesday, false),
    fromIntTestCase(3, .thursday, false),
    fromIntTestCase(4, .friday, false),
    fromIntTestCase(6, .saturday, false),
    fromIntTestCase(7, .sunday, false),
    fromIntTestCase(null, null, false),
    fromIntTestCase(-1, null, false),
    fromIntTestCase(5, null, false),
    fromIntTestCase(42, null, false),
    fromIntTestCase(-1337, null, false),
  ], 'day');
}
