// ```````````````````````````````````````````````import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:africaonlinestores/core/theme/app_text_styles.dart';
// import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

// import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_feed_controller.dart';
// import 'package:africaonlinestores/features/shorts/feeds/application/controllers/short_session_controller.dart';
// import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_feed_view.dart';
// import 'package:africaonlinestores/features/shorts/feeds/presentation/widgets/feed/short_page.dart';

// /// ─────────────────────────────────────────────
// /// SHORT DETAIL SCREEN
// /// ─────────────────────────────────────────────
// ///
// /// SINGLE RESPONSIBILITY:
// /// → Open Shorts at specific index
// /// → Reuse feed + playback system
// ///

// class ShortDetailScreen extends ConsumerStatefulWidget {
//   final int initialIndex;

//   const ShortDetailScreen({super.key, required this.initialIndex});

//   @override
//   ConsumerState<ShortDetailScreen> createState() => _ShortDetailScreenState();
// }

// class _ShortDetailScreenState extends ConsumerState<ShortDetailScreen>
//     with WidgetsBindingObserver {
//   bool _initialized = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);

//     _initialize();
//   }

//   Future<void> _initialize() async {
//     if (_initialized) return;

//     _initialized = true;

//     final sessionController = ref.read(shortSessionControllerProvider.notifier);

//     final feedState = ref.read(shortsFeedControllerProvider);

//     /// Guard index
//     final safeIndex = widget.initialIndex.clamp(0, feedState.shorts.length - 1);

//     /// Activate session at specific index
//     sessionController.activate(safeIndex);
//   }

//   /// ─────────────────────────────
//   /// APP LIFECYCLE
//   /// ─────────────────────────────

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final sessionController = ref.read(shortSessionControllerProvider.notifier);

//     if (state == AppLifecycleState.paused) {
//       sessionController.pause();
//     }

//     if (state == AppLifecycleState.resumed) {
//       sessionController.resume();
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final feedState = ref.watch(shortsFeedControllerProvider);
//     final session = ref.watch(shortSessionControllerProvider);

//     final activeIndex = session.activeIndex;

//     if (feedState.shorts.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(
//           leading: const BackButton(),
//           centerTitle: true,
//           title: Text("Shorts On Vacation", style: context.h4),
//         ),
//         backgroundColor: context.appColors.surface,
//         body: Center(child: Text("No shorts available", style: context.p)),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: ShortsFeedView(
//           controller: PageController(initialPage: widget.initialIndex),
//           itemCount: feedState.shorts.length,
//           onPageChanged: (index) {
//             ref.read(shortSessionControllerProvider.notifier).activate(index);
//           },
//           itemBuilder: (context, index) {
//             final isActive = index == activeIndex;

//             return ShortPage(index: index, isActive: isActive);
//           },
//         ),
//       ),
//     );
//   }
// }
