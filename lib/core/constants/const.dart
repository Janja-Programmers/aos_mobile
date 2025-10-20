class ApiRoutes {
  static const String baseUrl = 'https://africaonlinestores.com';

  static const String login = '/api/method/login';
  static const String logout = '/api/method/logout';
  static const String register = '/api/method/aos.overrides.user.sign_up';
  static const String resetPassword =
      '/api/method/frappe.core.doctype.user.user.reset_password';

  static const String webItem =
      '/api/method/webshop.webshop.api.get_product_filter_data';
  static const String singleWebItem = '/api/method/aos.api.get_product_detail';

  static const String item = '/api/resource/Item';
  static const String itemPrice = '/api/resource/Item Price';

  static const String salesOrder = '/api/resource/Sales Order';
  static const String salesInvoice = '/api/resource/Sales Invoice';
  static const String payInvoice = '/api/method/frappe.client.insert';
  static const String placeOrder = '/api/method/aos.overrides.cart.place_order';

  static const String deliveryNote = '/api/resource/Delivery Note';
  static const String stockIntake = '/api/resource/Stock Intake';

  static const String newAddress =
      '/api/method/aos.overrides.cart.add_new_address';
  static const String address = '/api/resource/Address';
  static const String update = '/api/method/frappe.client.set_value';
  static const String delete = '/api/method/frappe.client.delete';

  static const String product = '/api/resource/Product';

  static const String addToCart = '/api/method/aos.overrides.cart.update_cart';
  static const String updateCart =
      '/api/method/aos.overrides.cart.update_cart_address';
  static const String cancelDoc = '/api/method/frappe.client.cancel';
  static const String deliver =
      '/api/method/erpnext.selling.doctype.sales_order.sales_order.make_delivery_note';
  static const String bill =
      '/api/method/erpnext.stock.doctype.delivery_note.delivery_note.make_sales_invoice';
  static const String viewPastOrders = '/api/method/frappe.www.list.get';
  static const String slideshowEndpoint = '/api/method/aos.api.get_slider';

  static const String addReview =
      '/api/method/webshop.webshop.doctype.item_review.item_review.add_item_review';
  static const String getProductReviews =
      '/api/method/webshop.webshop.doctype.item_review.item_review.get_item_reviews';
  static const String reportProduct =
      '/api/method/aos.africa_online_stores.doctype.reported_product.reported_product.report_product';

  static var deleteUserAccount = '/api/method/aos.api.delete_account';
}
