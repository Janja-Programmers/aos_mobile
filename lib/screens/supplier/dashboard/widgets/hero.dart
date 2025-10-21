import 'package:flutter/material.dart';
// import '/screens/auth/auth_provider.dart';
// import 'package:provider/provider.dart';
// import '/features/auth/domain/user.dart';

class DashboardHero extends StatelessWidget {
  final ImageProvider? bannerImage;
  final double height;
  final EdgeInsets padding;

  const DashboardHero({
    super.key,
    this.bannerImage,
    this.height = 160,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    // final authProvider = context.watch<AuthProvider?>();
    // final User? user = authProvider?.user;

    // final String displayName =
    //     (user?.username.trim().isNotEmpty ?? false) ? user!.username : 'User';
    // final String? email = user?.email;

    final ImageProvider effectiveBanner =
        bannerImage ?? const AssetImage('assets/dash.png');

    return Padding(
      padding: padding,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Banner
            SizedBox(
              width: double.infinity,
              height: height,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationX(3.14159),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: effectiveBanner,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.18),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Gradient overlay for better contrast
            SizedBox(
              width: double.infinity,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // // Content Row: avatar + welcome text
            // Positioned(
            //   left: 16,
            //   bottom: 12,
            //   right: 16,
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       _buildAvatar(displayName),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: _buildWelcomeTexts(displayName, email, context),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  //   Widget _buildAvatar(String displayName, [String? photoUrl]) {
  //     final String initial =
  //         displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

  //     if (photoUrl != null && photoUrl.isNotEmpty) {
  //       return CircleAvatar(radius: 32, backgroundImage: NetworkImage(photoUrl));
  //     }

  //     return CircleAvatar(
  //       radius: 32,
  //       backgroundColor: Colors.white,
  //       child: CircleAvatar(
  //         radius: 30,
  //         backgroundColor: Colors.grey.shade200,
  //         child: Text(
  //           initial,
  //           style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     );
  //   }

  //   Widget _buildWelcomeTexts(
  //     String displayName,
  //     String? email,
  //     BuildContext context,
  //   ) {
  //     final styleTitle = Theme.of(context).textTheme.titleLarge?.copyWith(
  //       color: Colors.white,
  //       fontWeight: FontWeight.bold,
  //     );
  //     final styleSubtitle = Theme.of(
  //       context,
  //     ).textTheme.titleSmall?.copyWith(color: Colors.white70);

  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text('Welcome $displayName', style: styleTitle),
  //         if (email != null && email.isNotEmpty) ...[
  //           const SizedBox(height: 4),
  //           Text(email, style: styleSubtitle),
  //         ],
  //       ],
  //     );
  //   }
}
