import 'package:flutter/material.dart';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';

import 'package:africaonlinestores/features/connect/chats/presentation/screens/new_message_screen.dart';
import 'package:africaonlinestores/features/connect/chats/presentation/widgets/chat_seller_tile.dart';

class NewCallScreen extends StatelessWidget {
  const NewCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellers = [
      Seller(
        shopName: "TechHub Kenya",
        avatar: null,
        category: "Electronics & Gadgets",
        rating: 4.8,
        totalReviews: 1200,
        location: "Nairobi, Kenya",
        isVerified: true,
        isOnline: true,
      ),
      Seller(
        shopName: "Jane Mwangi",
        avatar: null,
        category: "Laptops & Computers",
        rating: 4.5,
        totalReviews: 856,
        location: "Westlands, Nairobi",
        isVerified: false,
        isOnline: true,
      ),
      Seller(
        shopName: "KE Gadgets Store",
        avatar: null,
        category: "Mobile Phones & Accessories",
        rating: 4.9,
        totalReviews: 2300,
        location: "Mombasa, Kenya",
        isVerified: true,
      ),
      Seller(
        shopName: "David Kimani",
        avatar: null,
        category: "Used Electronics",
        rating: 4.2,
        totalReviews: 432,
        location: "Kisumu, Kenya",
        isVerified: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("New Call", style: context.h5),
        leading: const BackButton(),
        elevation: 0,
      ),

      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search sellers...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 🔥 TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "All Sellers",
                style: context.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 📋 LIST
          Expanded(
            child: ListView.builder(
              itemCount: sellers.length,
              itemBuilder: (context, index) {
                final seller = sellers[index];

                return SellerTile(
                  seller: seller,
                  onTap: () {
                    // TODO: navigate to chat
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
