import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Duration callDuration = const Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _topSquareButton(
                    icon: Icons.keyboard_arrow_down_rounded,
                    iconSize: 34,
                  ),
                  _hdBadge(),
                  _topSquareButton(icon: Icons.more_vert_rounded, iconSize: 30),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Avatar
            Container(
              width: 146,
              height: 146,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEFEFEF),
                border: Border.all(color: const Color(0xFFC8102E), width: 5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 26,
                    spreadRadius: 10,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'T',
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC8102E),
                    height: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'TechHub Kenya',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
                letterSpacing: -0.6,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              '+254 712 345 678',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 12),

            _timerBadge(_formatDuration(callDuration)),

            const Spacer(flex: 3),

            // Middle action buttons
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(icon: Icons.mic_rounded, label: 'Mute'),
                  _ActionButton(
                    icon: Icons.videocam_off_rounded,
                    label: 'Video',
                  ),
                  _ActionButton(
                    icon: Icons.volume_up_rounded,
                    label: 'Speaker',
                  ),
                  _ActionButton(icon: Icons.dialpad_rounded, label: 'Keypad'),
                ],
              ),
            ),

            const SizedBox(height: 46),

            // End call button
            Container(
              width: 126,
              height: 126,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55D90429),
                    blurRadius: 24,
                    spreadRadius: 8,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Material(
                color: const Color(0xFFD90429),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {},
                  child: const Center(
                    child: Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _topSquareButton({required IconData icon, double iconSize = 28}) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: Icon(icon, size: iconSize, color: const Color(0xFF151515)),
    );
  }

  Widget _hdBadge() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.signal_cellular_alt_rounded,
            color: Color(0xFF32C36C),
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            'HD',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerBadge(String time) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(37),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF31C56B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 18),
          Text(
            time,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF202020),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF0F0F0),
            border: Border.all(color: const Color(0xFFE1E1E1)),
          ),
          child: Icon(icon, size: 42, color: const Color(0xFF161616)),
        ),
        const SizedBox(height: 18),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xFF5A5A5A),
          ),
        ),
      ],
    );
  }
}
