import 'package:permission_handler/permission_handler.dart';

Future<bool> checkStoragePermission() async {
  final status = await Permission.storage.status;

  if (status.isGranted) return true;

  final result = await Permission.storage.request();
  return result.isGranted;
}
