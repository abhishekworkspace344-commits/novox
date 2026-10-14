import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> downloadBytes(
  List<int> bytes, {
  required String filename,
  required String contentType,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}${Platform.pathSeparator}$filename');
  await file.writeAsBytes(bytes, flush: true);
}
