// import 'package:amani_mall/core/constants/colors.dart';
// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../cart/domain/cart_item.dart';
// import '../../cart/presentation/cart_provider.dart';
// import '../../wishlist/domain/wishlist_item.dart';
// import '../../wishlist/presentation/wishlist_provider.dart';
// import '../../../shared/item/domain/product.dart';
// import '../../product/presentation/product_provider.dart';
// import '../widgets/product_action_buttons.dart';
// import '../widgets/product_card.dart';
// import '../widgets/supplier_contact_sheet.dart';

// class ProductDetailScreen extends StatelessWidget {
//   final String productId;

//   const ProductDetailScreen({super.key, required this.productId});

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProductProvider>(context);
//     final Product? product = provider.selectedProduct;
//     final similarProducts =
//         Provider.of<ProductProvider>(context).products
//             .where(
//               (p) => p.category == product?.category && p.id != product?.id,
//             )
//             .toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Product Detail'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart),
//             onPressed: () => context.push('/cart'),
//           ),
//         ],
//       ),
//       body:
//           product == null
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Image
//                     Center(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(
//                           8,
//                         ), // Rounded corners
//                         child: Container(
//                           width: MediaQuery.of(context).size.width * 0.9,
//                           height: 200,
//                           color: AppColors.secondary,
//                           child: Image.network(
//                             product.imageUrl,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // Title and Price
//                     Text(
//                       product.title,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '\$${product.price.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.success,
//                       ),
//                     ),
//                     if (product.oldPrice != null)
//                       Text(
//                         '\$${product.oldPrice!.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           decoration: TextDecoration.lineThrough,
//                           color: AppColors.secondary,
//                         ),
//                       ),

//                     const SizedBox(height: 16),
//                     Text(product.description),
//                     const SizedBox(height: 16),

//                     // Stock & Rating
//                     Row(
//                       children: [
//                         Chip(
//                           label: Text(
//                             product.inStock ? 'In Stock' : 'Out of Stock',
//                           ),
//                           backgroundColor:
//                               product.inStock
//                                   ? AppColors.success
//                                   : AppColors.danger,
//                         ),
//                         const SizedBox(width: 12),
//                         Chip(
//                           label: Text('⭐ ${product.rating.toStringAsFixed(1)}'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),

//                     // Action buttons
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: ProductActionButtons(
//                         product: product,
//                         isAddToCartEnabled: product.inStock,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Similar Products
//                     Padding(
//                       padding: const EdgeInsets.all(6),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Similar Products',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           ListView.builder(
//                             itemCount: similarProducts.length,
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemBuilder: (context, index) {
//                               final p = similarProducts[index];
//                               return ProductCard(
//                                 product: p,
//                                 onTap: () {
//                                   Provider.of<ProductProvider>(
//                                     context,
//                                     listen: false,
//                                   ).loadProductDetails(p.id);
//                                   context.push('/product/${p.id}');
//                                 },
//                                 onFavToggle: () {
//                                   final wishlist =
//                                       Provider.of<WishlistProvider>(
//                                         context,
//                                         listen: false,
//                                       );
//                                   final item = WishlistItem(
//                                     id: p.id,
//                                     title: p.title,
//                                     imageUrl: p.imageUrl,
//                                     price: p.price,
//                                   );
//                                   wishlist.isInWishlist(p.id)
//                                       ? wishlist.remove(p.id)
//                                       : wishlist.add(item);
//                                 },
//                                 onCartToggle: () {
//                                   final cart = Provider.of<CartProvider>(
//                                     context,
//                                     listen: false,
//                                   );
//                                   final isNew =
//                                       !cart.items.any((e) => e.id == p.id);
//                                   cart.add(
//                                     CartItem(
//                                       id: p.id,
//                                       title: p.title,
//                                       imageUrl: p.imageUrl,
//                                       price: p.price,
//                                       quantity: 1,
//                                     ),
//                                   );
//                                   if (isNew) {
//                                     ScaffoldMessenger.of(context)
//                                       ..hideCurrentSnackBar()
//                                       ..showSnackBar(
//                                         const SnackBar(
//                                           content: Text('🛒 Added to Cart'),
//                                         ),
//                                       );
//                                   }
//                                 },
//                                 onCallTap: () {
//                                   showModalBottomSheet(
//                                     context: context,
//                                     builder:
//                                         (_) => SupplierContactSheet(product: p),
//                                   );
//                                 },
//                                 isFavorite: Provider.of<WishlistProvider>(
//                                   context,
//                                 ).isInWishlist(p.id),
//                                 cartCount:
//                                     Provider.of<CartProvider>(context).items
//                                         .firstWhereOrNull((e) => e.id == p.id)
//                                         ?.quantity ??
//                                     0,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       floatingActionButton: FloatingActionButton(
//         tooltip: 'Product List',
//         child: const Icon(Icons.list),
//         onPressed: () {
//           context.push('/products');
//         },
//       ),
//     );
//   }
// }
