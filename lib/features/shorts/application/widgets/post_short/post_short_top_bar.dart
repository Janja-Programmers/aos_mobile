import 'package:flutter/material.dart';

class PostShortTopBar extends StatelessWidget {
  final bool hasVideo;
  final VoidCallback onClose;
  final VoidCallback onRefresh;
  final VoidCallback? onPost;

  const PostShortTopBar({
    super.key,
    required this.hasVideo,
    required this.onClose,
    required this.onRefresh,
    required this.onPost,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          _glassIconButton(icon: Icons.close_rounded, onTap: onClose),
          const Spacer(),
          if (hasVideo) ...[
            _glassIconButton(icon: Icons.refresh_rounded, onTap: onRefresh),
            const SizedBox(width: 10),
            _postButton(),
          ],
        ],
      ),
    );
  }

  Widget _postButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4D67), Color(0xFFFF7A59)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPost,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Opacity(
              opacity: onPost == null ? 0.5 : 1,
              child: const Text('Post', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
