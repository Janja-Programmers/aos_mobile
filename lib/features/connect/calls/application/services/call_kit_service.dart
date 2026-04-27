// import 'dart:async';

// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:africaonlinestores/core/utils/logger.dart';
// import 'package:africaonlinestores/features/connect/calls/application/providers/call_providers.dart';

// class CallKitService {
//   final Ref ref;

//   StreamSubscription<CallEvent?>? _sub;
//   String? _currentCallId;

//   CallKitService(this.ref);

//   Future<void> showIncomingCall(Map<String, dynamic> data) async {
//     final callId = data['call_id']?.toString();
//     if (callId == null || callId.isEmpty) {
//       appLogger.e('❌ Cannot show CallKit: missing call_id → $data');
//       return;
//     }

//     _currentCallId = callId;

//     final callType = data['call_type']?.toString() ?? 'audio';
//     final caller = data['caller']?.toString() ?? 'AOS User';

//     final params = CallKitParams(
//       id: callId,
//       nameCaller: caller,
//       appName: 'AOS',
//       handle: callType == 'video' ? 'Incoming Video Call' : 'Incoming Call',
//       type: callType == 'video' ? 1 : 0,
//       duration: 60000,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       extra: {'call_id': callId, 'call_type': callType, 'caller': caller},
//       android: const AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: false,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955FA',
//         actionColor: '#4CAF50',
//         textColor: '#ffffff',
//       ),
//       ios: const IOSParams(
//         supportsVideo: true,
//         ringtonePath: 'system_ringtone_default',
//       ),
//     );

//     await FlutterCallkitIncoming.showCallkitIncoming(params);
//   }

//   void init() {
//     _sub?.cancel();

//     _sub = FlutterCallkitIncoming.onEvent.listen((event) async {
//       if (event == null) return;

//       final callId = _extractCallId(event);
//       _currentCallId = callId ?? _currentCallId;

//       appLogger.i('📞 CallKit event: ${event.event}');
//       appLogger.i('📞 CallKit callId: $_currentCallId');

//       switch (event.event) {
//         case Event.actionCallAccept:
//           await _handleAccept();
//           break;

//         case Event.actionCallDecline:
//           await _handleDecline();
//           break;

//         case Event.actionCallEnded:
//           await _handleEnded();
//           break;

//         case Event.actionCallTimeout:
//           await _handleTimeout();
//           break;

//         default:
//           break;
//       }
//     });
//   }

//   Future<void> endNativeCall({String? callId}) async {
//     final id = callId ?? _currentCallId;
//     if (id == null || id.isEmpty) return;

//     await FlutterCallkitIncoming.endCall(id);
//   }

//   Future<void> endAllNativeCalls() async {
//     await FlutterCallkitIncoming.endAllCalls();
//   }

//   Future<void> _handleAccept() async {
//     await ref.read(callManagerProvider.notifier).acceptIncomingCall();
//   }

//   Future<void> _handleDecline() async {
//     await ref.read(callManagerProvider.notifier).rejectIncomingCall();
//     await endNativeCall();
//   }

//   Future<void> _handleEnded() async {
//     await ref.read(callManagerProvider.notifier).endCurrentCall();
//   }

//   Future<void> _handleTimeout() async {
//     await ref.read(callManagerProvider.notifier).callNotAnswered();
//     await endNativeCall();
//   }

//   String? _extractCallId(CallEvent event) {
//     final body = event.body;

//     if (body is! Map) return null;

//     final extra = body['extra'];
//     if (extra is Map && extra['call_id'] != null) {
//       return extra['call_id'].toString();
//     }

//     if (body['id'] != null) {
//       return body['id'].toString();
//     }

//     return null;
//   }

//   Future<void> clearNativeCall({String? callId}) async {
//     final id = callId ?? _currentCallId;

//     if (id == null || id.isEmpty) {
//       await FlutterCallkitIncoming.endAllCalls();
//       return;
//     }

//     await FlutterCallkitIncoming.endCall(id);

//     if (_currentCallId == id) {
//       _currentCallId = null;
//     }
//   }

//   void dispose() {
//     _sub?.cancel();
//   }
// }
