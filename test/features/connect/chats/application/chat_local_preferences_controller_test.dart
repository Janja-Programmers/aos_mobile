import 'package:africaonlinestores/features/connect/chats/application/controllers/chat_local_preferences_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'chat.enter_to_send': true,
      'chat.wallpaper.CONV-1.id': 'midnight',
    });
  });

  test(
    'preferences are versioned, account scoped, and invalidate legacy keys',
    () async {
      final accountA = ChatLocalPreferencesController(
        conversationId: 'CONV-1',
        accountScope: 'ACC-A',
      );
      await accountA.load();

      expect(accountA.state.enterToSend, isFalse);
      expect(accountA.state.wallpaperId, chatWallpaperDefaultId);

      await accountA.setEnterToSend(true);
      await accountA.setWallpaper('midnight');

      final accountB = ChatLocalPreferencesController(
        conversationId: 'CONV-1',
        accountScope: 'ACC-B',
      );
      await accountB.load();

      expect(accountB.state.enterToSend, isFalse);
      expect(accountB.state.wallpaperId, chatWallpaperDefaultId);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('chat.v2.ACC-A.enter_to_send'), isTrue);
      expect(prefs.getString('chat.v2.ACC-A.wallpaper.CONV-1.id'), 'midnight');
      expect(prefs.containsKey('chat.enter_to_send'), isFalse);
      expect(prefs.containsKey('chat.wallpaper.CONV-1.id'), isFalse);

      accountA.dispose();
      accountB.dispose();
    },
  );
}
