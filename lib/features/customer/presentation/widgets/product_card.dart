// import 'package:flutter/material.dart';
// import '../../../shared/item/domain/product.dart';
// import '../../../../core/constants/colors.dart';
// import 'product_action_icons.dart';

// class ProductCard extends StatelessWidget {
//   final Product product;
//   final VoidCallback onTap;
//   final VoidCallback onFavToggle;
//   final VoidCallback onCartToggle;
//   final VoidCallback onCallTap;
//   final bool isFavorite;
//   final int cartCount;

//   const ProductCard({
//     super.key,
//     required this.product,
//     required this.onTap,
//     required this.onFavToggle,
//     required this.onCartToggle,
//     required this.onCallTap,
//     this.isFavorite = false,
//     this.cartCount = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [BoxShadow(blurRadius: 3, color: AppColors.shadow)],
//         ),
//         child: Row(
//           children: [
//             // Image
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(3),
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * 0.3,
//                   height: 100,
//                   color: AppColors.secondary,
//                   child: Image.network(product.imageUrl, fit: BoxFit.cover),
//                 ),
//               ),
//             ),

//             const SizedBox(width: 10),

//             // Description
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.title,
//                     style: Theme.of(
//                       context,
//                     ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     product.description,
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     '\$${product.price.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.success,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       ProductActionIcons(
//                         product: product,
//                         isFavorite: isFavorite,
//                         onFavToggle: onFavToggle,
//                         onCartToggle: onCartToggle,
//                         onCallTap: onCallTap,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
