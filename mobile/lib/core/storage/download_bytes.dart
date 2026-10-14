import 'download_bytes_io.dart'
    if (dart.library.html) 'download_bytes_web.dart' as platform;

/// Saves a server response using the browser download flow on web and the
/// application documents directory on native platforms.
Future<void> downloadBytes(
  List<int> bytes, {
  required String filename,
  required String contentType,
}) => platform.downloadBytes(
      bytes,
      filename: filename,
      contentType: contentType,
    );
