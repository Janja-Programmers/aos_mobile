import 'package:flutter/material.dart';

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
        const Text(
          'Suggested for You',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        /// Horizontal cards
        SizedBox(
          height: 190,
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
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            ],
          ),

          /// Avatar
          const CircleAvatar(radius: 30, backgroundColor: Colors.grey),

          const SizedBox(height: 10),

          /// Name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 4),

          /// Followers
          Text(
            followers,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const Spacer(),

          /// Follow Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Follow', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
