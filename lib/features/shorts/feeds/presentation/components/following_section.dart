import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:flutter/material.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';

class FollowingSection extends StatelessWidget {
  const FollowingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = List.generate(5, (index) {
      return {'name': 'Beauty Studio', 'followers': '1.2M followers'};
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        /// Title
        Text(
          'Suggested for You',
          style: context.h3.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        /// Horizontal cards
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = suggestions[index];

              return _FollowingCard(
                name: item['name']!,
                followers: item['followers']!,
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        /// CTA Button
        Center(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'GET MORE INSPIRATION',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _FollowingCard extends StatelessWidget {
  final String name;
  final String followers;

  const _FollowingCard({required this.name, required this.followers});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: BoxBorder.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Top row (dismiss)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colors.black.withOpacity(.65),
                ),
              ),
            ],
          ),

          /// Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: colors.black.withOpacity(.50),
          ),

          const SizedBox(height: 10),

          /// Name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.pStrong,
          ),

          const SizedBox(height: 4),

          /// Followers
          Text(followers, style: context.pMuted),

          const Spacer(),

          /// Follow Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                elevation: 0,
              ),
              child: Text('Follow', style: AppTextStylesX(context).button),
            ),
          ),
        ],
      ),
    );
  }
}
