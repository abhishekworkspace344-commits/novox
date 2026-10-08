import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/constants/api_constants.dart';
import '../core/storage/secure_storage.dart';

class AdminWebSocketService {
  WebSocketChannel? _channel;

  Stream<Map<String, dynamic>>? _stream;

  // ============================================================
  // CONNECT
  // ============================================================

  Future<Stream<Map<String, dynamic>>> connect() async {
    final token =
        await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        "Authentication token not found",
      );
    }

    final baseUrl =
        ApiConstants.baseUrl;

    final wsUrl = baseUrl
        .replaceFirst(
          "http://",
          "ws://",
        )
        .replaceFirst(
          "https://",
          "wss://",
        );

    final uri = Uri.parse(
      "$wsUrl/ws/admin?token=$token",
    );

    _channel =
        WebSocketChannel.connect(uri);

    _stream = _channel!.stream.map(
      (event) {
        // --------------------------------------------------------
        // Already decoded map
        // --------------------------------------------------------

        if (event is Map<String, dynamic>) {
          return event;
        }

        // --------------------------------------------------------
        // JSON string
        // --------------------------------------------------------

        if (event is String) {
          try {
            final decoded =
                jsonDecode(event);

            if (decoded
                is Map<String, dynamic>) {
              return decoded;
            }
          } catch (_) {
            // Ignore invalid JSON messages.
          }
        }

        // --------------------------------------------------------
        // Unknown message
        // --------------------------------------------------------

        return <String, dynamic>{};
      },
    );

    return _stream!;
  }

  // ============================================================
  // DISCONNECT
  // ============================================================

  Future<void> disconnect() async {
    try {
      await _channel?.sink.close();
    } catch (_) {
      // Ignore close errors.
    }

    _channel = null;
    _stream = null;
  }
}