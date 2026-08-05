// ignore_for_file: avoid_slow_async_io

import 'dart:async';
import 'dart:io';

import 'package:africaonlinestores/features/account/shared/providers/account_user_provider.dart';
import 'package:africaonlinestores/features/connect/chats/domain/chat_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String chatWallpaperDefaultId = 'default';
const String chatWallpaperGalleryId = 'gallery';
const String chatGlobalPreferencesConversationId = '__global__';

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
    required this.accountScope,
    required this.loading,
    required this.saving,
    required this.wallpaperId,
    required this.enterToSend,
    this.wallpaperImagePath,
  });

  final String conversationId;
  final String accountScope;
  final bool loading;
  final bool saving;
  final String wallpaperId;
  final String? wallpaperImagePath;
  final bool enterToSend;

  factory ChatLocalPreferencesState.initial({
    required String conversationId,
    required String accountScope,
  }) {
    return ChatLocalPreferencesState(
      conversationId: conversationId,
      accountScope: accountScope,
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
      accountScope: accountScope,
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

final chatLocalPreferencesControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatLocalPreferencesController, ChatLocalPreferencesState, String>((
      ref,
      conversationId,
    ) {
      final accountScope = _storageAccountScope(
        ref.watch(currentCanonicalAccountIdProvider),
      );
      final controller = ChatLocalPreferencesController(
        conversationId: conversationId,
        accountScope: accountScope,
      );
      unawaited(controller.load());
      return controller;
    });

class ChatLocalPreferencesController
    extends StateNotifier<ChatLocalPreferencesState> {
  ChatLocalPreferencesController({
    required String conversationId,
    required String accountScope,
  }) : super(
         ChatLocalPreferencesState.initial(
           conversationId: conversationId,
           accountScope: accountScope,
         ),
       );

  static const String _versionPrefix = 'chat.v2';
  static const String _legacyEnterToSendKey = 'chat.enter_to_send';
  static const String _legacyWallpaperPrefix = 'chat.wallpaper';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // Version 1 stored one global ownership-sensitive preference namespace.
    // It is intentionally invalidated rather than migrated across accounts.
    await _invalidateLegacyKeys(prefs);

    final ownWallpaperId = prefs.getString(
      _wallpaperIdKey(state.conversationId),
    );
    final ownImagePath = prefs.getString(
      _wallpaperImageKey(state.conversationId),
    );
    final useGlobalFallback =
        state.conversationId != chatGlobalPreferencesConversationId &&
        ownWallpaperId == null;
    final wallpaperId = useGlobalFallback
        ? prefs.getString(
                _wallpaperIdKey(chatGlobalPreferencesConversationId),
              ) ??
              chatWallpaperDefaultId
        : ownWallpaperId ?? chatWallpaperDefaultId;
    final imagePath = useGlobalFallback
        ? prefs.getString(
            _wallpaperImageKey(chatGlobalPreferencesConversationId),
          )
        : ownImagePath;
    final enterToSend = prefs.getBool(_enterToSendKey) ?? false;

    if (!mounted) return;
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
    final previousImagePath = state.wallpaperImagePath;

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
      await _deleteManagedWallpaper(previousImagePath);
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

    final previousWallpaperId = state.wallpaperId;
    final previousImagePath = state.wallpaperImagePath;
    state = state.copyWith(saving: true);

    try {
      final persistedPath = await _persistGalleryWallpaper(image.path);
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(
          _wallpaperIdKey(state.conversationId),
          chatWallpaperGalleryId,
        ),
        prefs.setString(
          _wallpaperImageKey(state.conversationId),
          persistedPath,
        ),
      ]);

      await _deleteManagedWallpaper(
        previousImagePath,
        exceptPath: persistedPath,
      );

      if (!mounted) return true;
      state = state.copyWith(
        saving: false,
        wallpaperId: chatWallpaperGalleryId,
        wallpaperImagePath: persistedPath,
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(
        saving: false,
        wallpaperId: previousWallpaperId,
        wallpaperImagePath: previousImagePath,
      );
      return false;
    }
  }

  Future<void> resetWallpaper() async {
    final previousImagePath = state.wallpaperImagePath;
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

    var fallbackWallpaperId = chatWallpaperDefaultId;
    String? fallbackImagePath;
    if (state.conversationId != chatGlobalPreferencesConversationId) {
      fallbackWallpaperId =
          prefs.getString(
            _wallpaperIdKey(chatGlobalPreferencesConversationId),
          ) ??
          chatWallpaperDefaultId;
      fallbackImagePath = prefs.getString(
        _wallpaperImageKey(chatGlobalPreferencesConversationId),
      );
    }

    await _deleteManagedWallpaper(
      previousImagePath,
      exceptPath: fallbackImagePath,
    );

    if (!mounted) return;
    state = state.copyWith(
      saving: false,
      wallpaperId: fallbackWallpaperId,
      wallpaperImagePath: fallbackImagePath,
    );
  }

  Future<String> _persistGalleryWallpaper(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('Selected wallpaper is unavailable.');
    }

    final supportDirectory = await getApplicationSupportDirectory();
    final accountDirectory = Directory(
      '${supportDirectory.path}/chat_wallpapers/${state.accountScope}',
    );
    await accountDirectory.create(recursive: true);

    final cleanConversationId = state.conversationId.replaceAll(
      RegExp('[^A-Za-z0-9_-]'),
      '_',
    );
    final extension = _safeFileExtension(sourcePath);
    final destination = File(
      '${accountDirectory.path}/$cleanConversationId$extension',
    );
    final temporary = File('${destination.path}.tmp');

    if (await temporary.exists()) await temporary.delete();
    await source.copy(temporary.path);
    if (await destination.exists()) await destination.delete();
    await temporary.rename(destination.path);
    return destination.path;
  }

  Future<void> _deleteManagedWallpaper(
    String? path, {
    String? exceptPath,
  }) async {
    final cleanPath = path?.trim();
    if (cleanPath == null ||
        cleanPath.isEmpty ||
        cleanPath == exceptPath ||
        !cleanPath.contains('/chat_wallpapers/')) {
      return;
    }

    final file = File(cleanPath);
    if (await file.exists()) await file.delete();
  }

  Future<void> setEnterToSend(bool enabled) async {
    state = state.copyWith(saving: true, enterToSend: enabled);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enterToSendKey, enabled);

    if (!mounted) return;
    state = state.copyWith(saving: false);
  }

  String get _enterToSendKey {
    return '$_versionPrefix.${state.accountScope}.enter_to_send';
  }

  String _wallpaperIdKey(String conversationId) {
    return '$_versionPrefix.${state.accountScope}.wallpaper.$conversationId.id';
  }

  String _wallpaperImageKey(String conversationId) {
    return '$_versionPrefix.${state.accountScope}.wallpaper.'
        '$conversationId.image_path';
  }

  Future<void> _invalidateLegacyKeys(SharedPreferences prefs) async {
    final keys = prefs.getKeys().where(
      (key) =>
          key == _legacyEnterToSendKey ||
          key.startsWith('$_legacyWallpaperPrefix.'),
    );
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

String _safeFileExtension(String path) {
  final cleanPath = path.split('?').first;
  final dotIndex = cleanPath.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == cleanPath.length - 1) return '.jpg';

  final extension = cleanPath.substring(dotIndex).toLowerCase();
  const supported = <String>{'.jpg', '.jpeg', '.png', '.webp'};
  return supported.contains(extension) ? extension : '.jpg';
}

String _storageAccountScope(String? canonicalId) {
  final normalized = normalizeCanonicalUserId(canonicalId);
  return normalized.isEmpty ? 'guest' : normalized;
}
