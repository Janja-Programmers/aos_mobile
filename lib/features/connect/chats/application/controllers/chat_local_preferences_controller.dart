import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String chatWallpaperDefaultId = 'default';
const String chatWallpaperGalleryId = 'gallery';

class ChatWallpaperOption {
  const ChatWallpaperOption({
    required this.id,
    required this.label,
    required this.color,
    this.borderColor,
  });

  final String id;
  final String label;
  final Color color;
  final Color? borderColor;
}

const List<ChatWallpaperOption>
chatSolidWallpaperOptions = <ChatWallpaperOption>[
  ChatWallpaperOption(
    id: 'midnight',
    label: 'Midnight',
    color: Color(0xFF0B1724),
  ),
  ChatWallpaperOption(id: 'navy', label: 'Navy', color: Color(0xFF182F40)),
  ChatWallpaperOption(id: 'forest', label: 'Forest', color: Color(0xFF183022)),
  ChatWallpaperOption(id: 'plum', label: 'Plum', color: Color(0xFF321B31)),
  ChatWallpaperOption(
    id: 'charcoal',
    label: 'Charcoal',
    color: Color(0xFF151515),
    borderColor: Color(0xFF303030),
  ),
  ChatWallpaperOption(id: 'maroon', label: 'Maroon', color: Color(0xFF371E20)),
  ChatWallpaperOption(id: 'teal', label: 'Teal', color: Color(0xFF172B2A)),
  ChatWallpaperOption(id: 'coffee', label: 'Coffee', color: Color(0xFF2C261F)),
];

class ChatLocalPreferencesState {
  const ChatLocalPreferencesState({
    required this.conversationId,
    required this.loading,
    required this.saving,
    required this.wallpaperId,
    required this.enterToSend,
    this.wallpaperImagePath,
  });

  final String conversationId;
  final bool loading;
  final bool saving;
  final String wallpaperId;
  final String? wallpaperImagePath;
  final bool enterToSend;

  factory ChatLocalPreferencesState.initial(String conversationId) {
    return ChatLocalPreferencesState(
      conversationId: conversationId,
      loading: true,
      saving: false,
      wallpaperId: chatWallpaperDefaultId,
      enterToSend: false,
    );
  }

  bool get hasGalleryWallpaper {
    final cleanPath = wallpaperImagePath?.trim();
    return wallpaperId == chatWallpaperGalleryId &&
        cleanPath != null &&
        cleanPath.isNotEmpty;
  }

  ChatWallpaperOption? get solidWallpaper {
    for (final option in chatSolidWallpaperOptions) {
      if (option.id == wallpaperId) return option;
    }
    return null;
  }

  ChatLocalPreferencesState copyWith({
    bool? loading,
    bool? saving,
    String? wallpaperId,
    Object? wallpaperImagePath = _unset,
    bool? enterToSend,
  }) {
    return ChatLocalPreferencesState(
      conversationId: conversationId,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      wallpaperId: wallpaperId ?? this.wallpaperId,
      wallpaperImagePath: identical(wallpaperImagePath, _unset)
          ? this.wallpaperImagePath
          : wallpaperImagePath as String?,
      enterToSend: enterToSend ?? this.enterToSend,
    );
  }
}

const Object _unset = Object();

final chatLocalPreferencesControllerProvider =
    StateNotifierProvider.family<
      ChatLocalPreferencesController,
      ChatLocalPreferencesState,
      String
    >((ref, conversationId) {
      final controller = ChatLocalPreferencesController(conversationId);
      unawaited(controller.load());
      return controller;
    });

class ChatLocalPreferencesController
    extends StateNotifier<ChatLocalPreferencesState> {
  ChatLocalPreferencesController(String conversationId)
    : super(ChatLocalPreferencesState.initial(conversationId));

  static const String _enterToSendKey = 'chat.enter_to_send';
  static const String _wallpaperPrefix = 'chat.wallpaper';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final wallpaperId =
        prefs.getString(_wallpaperIdKey(state.conversationId)) ??
        chatWallpaperDefaultId;
    final imagePath = prefs.getString(_wallpaperImageKey(state.conversationId));
    final enterToSend = prefs.getBool(_enterToSendKey) ?? false;

    state = state.copyWith(
      loading: false,
      wallpaperId: wallpaperId,
      wallpaperImagePath: imagePath,
      enterToSend: enterToSend,
    );
  }

  Future<void> setWallpaper(String wallpaperId) async {
    final cleanId = wallpaperId.trim().isEmpty
        ? chatWallpaperDefaultId
        : wallpaperId.trim();

    state = state.copyWith(
      saving: true,
      wallpaperId: cleanId,
      wallpaperImagePath: cleanId == chatWallpaperGalleryId
          ? state.wallpaperImagePath
          : null,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wallpaperIdKey(state.conversationId), cleanId);
    if (cleanId != chatWallpaperGalleryId) {
      await prefs.remove(_wallpaperImageKey(state.conversationId));
    }

    if (!mounted) return;
    state = state.copyWith(saving: false);
  }

  Future<bool> chooseGalleryWallpaper() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );

    if (image == null || !mounted) return false;

    state = state.copyWith(
      saving: true,
      wallpaperId: chatWallpaperGalleryId,
      wallpaperImagePath: image.path,
    );

    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(
        _wallpaperIdKey(state.conversationId),
        chatWallpaperGalleryId,
      ),
      prefs.setString(_wallpaperImageKey(state.conversationId), image.path),
    ]);

    if (!mounted) return true;
    state = state.copyWith(saving: false);
    return true;
  }

  Future<void> resetWallpaper() async {
    state = state.copyWith(
      saving: true,
      wallpaperId: chatWallpaperDefaultId,
      wallpaperImagePath: null,
    );

    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_wallpaperIdKey(state.conversationId)),
      prefs.remove(_wallpaperImageKey(state.conversationId)),
    ]);

    if (!mounted) return;
    state = state.copyWith(saving: false);
  }

  Future<void> setEnterToSend(bool enabled) async {
    state = state.copyWith(saving: true, enterToSend: enabled);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enterToSendKey, enabled);

    if (!mounted) return;
    state = state.copyWith(saving: false);
  }

  static String _wallpaperIdKey(String conversationId) {
    return '$_wallpaperPrefix.$conversationId.id';
  }

  static String _wallpaperImageKey(String conversationId) {
    return '$_wallpaperPrefix.$conversationId.image_path';
  }
}
