import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/core/constants/colors.dart';

import '../../../auth/auth_provider.dart';

import '/shared/widgets/app_bars.dart';
import '/shared/widgets/cart_button.dart';

class EmptyProductPage extends StatelessWidget {
  const EmptyProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(
        actions:
            user == null
                ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextButton(
                      onPressed: () {
                        context.push('/login');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ]
                : [
                  const CartIconButton(),
                  IconButton(
                    icon: const Icon(Icons.person, color: AppColors.black),
                    onPressed: () {},
                  ),
                ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade600),
              const SizedBox(height: 20),
              const Text(
                'Product not found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The product you’re looking for doesn’t exist or is no longer available.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Continue Shopping'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
