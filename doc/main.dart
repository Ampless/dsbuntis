//If you are looking for something that you would actually want to use:
//https://github.com/Ampless/Accemus

import 'package:dsbuntis/dsbuntis.dart';

void main(List<String> args) async {
  final plans = await getAllSubs(args[0], args[1]);
  print(plans);
}
