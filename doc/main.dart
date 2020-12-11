//If you are looking for an implementation that you would actually want to use:
//https://github.com/Ampless/Accemus

import 'package:dsbuntis/dsbuntis.dart';
import 'package:schttp/schttp.dart';

Future<void> main(List<String> args) async {
  final http = ScHttpClient();
  final plans = await getAllSubs(args[0], args[1], http.get, http.post);
  print(Plan.plansToJson(plans));
}
