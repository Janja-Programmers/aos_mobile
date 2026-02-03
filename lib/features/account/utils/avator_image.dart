import 'package:flutter/material.dart';

ImageProvider<Object>? resolveAvatarImage(String? url, String baseUrl) {
  if (url == null || url.trim().isEmpty) return null;

  final uri = Uri.tryParse(url);
  if (uri != null && uri.hasScheme) {
    return NetworkImage(url);
  }

  return NetworkImage('$baseUrl$url');
}
