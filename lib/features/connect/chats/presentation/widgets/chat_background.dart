import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;
  final String assetPath;

  const ChatBackground({
    super.key,
    required this.child,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: colors.surface)),

        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.5,
              child: Center(
                child: Image.asset(
                  assetPath,
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.55),
              ),
            ),
          ),
        ),

        child,
      ],
    );
  }
}

// import 'package:flutter/material.dart';

// import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

// class ChatBackground extends StatelessWidget {
//   final Widget child;
//   final String assetPath;

//   const ChatBackground({
//     super.key,
//     required this.child,
//     required this.assetPath,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(child: ColoredBox(color: context.appColors.surface)),

//         Positioned.fill(
//           child: IgnorePointer(
//             child: Opacity(
//               opacity: 0.025,
//               child: GridView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(24),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 48,
//                   crossAxisSpacing: 48,
//                 ),
//                 itemCount: 30,
//                 itemBuilder: (_, _) {
//                   return Image.asset(assetPath, fit: BoxFit.contain);
//                 },
//               ),
//             ),
//           ),
//         ),

//         child,
//       ],
//     );
//   }
// }
