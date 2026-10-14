import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadBytes(
  List<int> bytes, {
  required String filename,
  required String contentType,
}) async {
  final blob = html.Blob(
    <Object>[Uint8List.fromList(bytes)],
    contentType,
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  unawaited(Future<void>.delayed(const Duration(seconds: 1), () {
    html.Url.revokeObjectUrl(url);
  }));
}
