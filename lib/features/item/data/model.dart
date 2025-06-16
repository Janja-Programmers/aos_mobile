import 'package:equatable/equatable.dart';

import '../domain/entity.dart';

class ItemModel extends Equatable {
  final String name;
  final String? owner;
  final String? creation;
  final String? modified;
  final String? modifiedBy;
  final int? docstatus;
  final int? idx;
  final String? namingSeries;
  final String? itemCode;
  final String? itemName;
  final String? itemGroup;
  final String? stockUom;
  final String? customVendor;
  final int? disabled;
  final int? allowAlternativeItem;
  final int? isStockItem;
  final int? hasVariants;
  final double? openingStock;
  final double? valuationRate;
  final double? standardRate;
  final int? isFixedAsset;
  final int? autoCreateAssets;
  final int? isGroupedAsset;
  final double? overDeliveryReceiptAllowance;
  final double? overBillingAllowance;
  final String? description;
  final int? shelfLifeInDays;
  final String? endOfLife;
  final String? defaultMaterialRequestType;
  final String? valuationMethod;
  final double? weightPerUnit;
  final int? allowNegativeStock;
  final int? hasBatchNo;
  final int? createNewBatch;
  final int? hasExpiryDate;
  final int? retainSample;
  final int? sampleQuantity;
  final int? hasSerialNo;
  final String? variantBasedOn;
  final int? enableDeferredExpense;
  final int? noOfMonthsExp;
  final int? enableDeferredRevenue;
  final int? noOfMonths;
  final double? minOrderQty;
  final double? safetyStock;
  final int? isPurchaseItem;
  final int? leadTimeDays;
  final double? lastPurchaseRate;
  final int? isCustomerProvidedItem;
  final int? deliveredBySupplier;
  final String? countryOfOrigin;
  final int? grantCommission;
  final int? isSalesItem;
  final double? maxDiscount;
  final int? inspectionRequiredBeforePurchase;
  final int? inspectionRequiredBeforeDelivery;
  final int? includeItemInManufacturing;
  final int? isSubContractedItem;
  final String? customerCode;
  final int? publishedInWebsite;
  final double? totalProjectedQty;
  final String? doctype;
  final List<UomModel>? uoms;
  final List<dynamic>? barcodes;
  final List<dynamic>? reorderLevels;
  final List<dynamic>? attributes;
  final List<ItemDefaultModel>? itemDefaults;
  final List<dynamic>? supplierItems;
  final List<dynamic>? customerItems;
  final List<dynamic>? taxes;

  const ItemModel({
    required this.name,
    this.owner,
    this.creation,
    this.modified,
    this.modifiedBy,
    this.docstatus,
    this.idx,
    this.namingSeries,
    this.itemCode,
    this.itemName,
    this.itemGroup,
    this.stockUom,
    this.customVendor,
    this.disabled,
    this.allowAlternativeItem,
    this.isStockItem,
    this.hasVariants,
    this.openingStock,
    this.valuationRate,
    this.standardRate,
    this.isFixedAsset,
    this.autoCreateAssets,
    this.isGroupedAsset,
    this.overDeliveryReceiptAllowance,
    this.overBillingAllowance,
    this.description,
    this.shelfLifeInDays,
    this.endOfLife,
    this.defaultMaterialRequestType,
    this.valuationMethod,
    this.weightPerUnit,
    this.allowNegativeStock,
    this.hasBatchNo,
    this.createNewBatch,
    this.hasExpiryDate,
    this.retainSample,
    this.sampleQuantity,
    this.hasSerialNo,
    this.variantBasedOn,
    this.enableDeferredExpense,
    this.noOfMonthsExp,
    this.enableDeferredRevenue,
    this.noOfMonths,
    this.minOrderQty,
    this.safetyStock,
    this.isPurchaseItem,
    this.leadTimeDays,
    this.lastPurchaseRate,
    this.isCustomerProvidedItem,
    this.deliveredBySupplier,
    this.countryOfOrigin,
    this.grantCommission,
    this.isSalesItem,
    this.maxDiscount,
    this.inspectionRequiredBeforePurchase,
    this.inspectionRequiredBeforeDelivery,
    this.includeItemInManufacturing,
    this.isSubContractedItem,
    this.customerCode,
    this.publishedInWebsite,
    this.totalProjectedQty,
    this.doctype,
    this.uoms,
    this.barcodes,
    this.reorderLevels,
    this.attributes,
    this.itemDefaults,
    this.supplierItems,
    this.customerItems,
    this.taxes,
  });

  static double? _toDouble(dynamic val) =>
      val != null ? (val as num).toDouble() : null;

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    name: json["name"],
    owner: json["owner"],
    creation: json["creation"],
    modified: json["modified"],
    modifiedBy: json["modified_by"],
    docstatus: json["docstatus"],
    idx: json["idx"],
    namingSeries: json["naming_series"],
    itemCode: json["item_code"],
    itemName: json["item_name"],
    itemGroup: json["item_group"],
    stockUom: json["stock_uom"],
    customVendor: json["custom_vendor"],
    disabled: json["disabled"],
    allowAlternativeItem: json["allow_alternative_item"],
    isStockItem: json["is_stock_item"],
    hasVariants: json["has_variants"],
    openingStock: _toDouble(json["opening_stock"]),
    valuationRate: _toDouble(json["valuation_rate"]),
    standardRate: _toDouble(json["standard_rate"]),
    isFixedAsset: json["is_fixed_asset"],
    autoCreateAssets: json["auto_create_assets"],
    isGroupedAsset: json["is_grouped_asset"],
    overDeliveryReceiptAllowance: _toDouble(
      json["over_delivery_receipt_allowance"],
    ),
    overBillingAllowance: _toDouble(json["over_billing_allowance"]),
    description: json["description"],
    shelfLifeInDays: json["shelf_life_in_days"],
    endOfLife: json["end_of_life"],
    defaultMaterialRequestType: json["default_material_request_type"],
    valuationMethod: json["valuation_method"],
    weightPerUnit: _toDouble(json["weight_per_unit"]),
    allowNegativeStock: json["allow_negative_stock"],
    hasBatchNo: json["has_batch_no"],
    createNewBatch: json["create_new_batch"],
    hasExpiryDate: json["has_expiry_date"],
    retainSample: json["retain_sample"],
    sampleQuantity: json["sample_quantity"],
    hasSerialNo: json["has_serial_no"],
    variantBasedOn: json["variant_based_on"],
    enableDeferredExpense: json["enable_deferred_expense"],
    noOfMonthsExp: json["no_of_months_exp"],
    enableDeferredRevenue: json["enable_deferred_revenue"],
    noOfMonths: json["no_of_months"],
    minOrderQty: _toDouble(json["min_order_qty"]),
    safetyStock: _toDouble(json["safety_stock"]),
    isPurchaseItem: json["is_purchase_item"],
    leadTimeDays: json["lead_time_days"],
    lastPurchaseRate: _toDouble(json["last_purchase_rate"]),
    isCustomerProvidedItem: json["is_customer_provided_item"],
    deliveredBySupplier: json["delivered_by_supplier"],
    countryOfOrigin: json["country_of_origin"],
    grantCommission: json["grant_commission"],
    isSalesItem: json["is_sales_item"],
    maxDiscount: _toDouble(json["max_discount"]),
    inspectionRequiredBeforePurchase:
        json["inspection_required_before_purchase"],
    inspectionRequiredBeforeDelivery:
        json["inspection_required_before_delivery"],
    includeItemInManufacturing: json["include_item_in_manufacturing"],
    isSubContractedItem: json["is_sub_contracted_item"],
    customerCode: json["customer_code"],
    publishedInWebsite: json["published_in_website"],
    totalProjectedQty: _toDouble(json["total_projected_qty"]),
    doctype: json["doctype"],
    uoms:
        json["uoms"] != null
            ? List<UomModel>.from(json["uoms"].map((x) => UomModel.fromJson(x)))
            : [],
    barcodes:
        json["barcodes"] != null
            ? List<dynamic>.from(json["barcodes"].map((x) => x))
            : [],
    reorderLevels:
        json["reorder_levels"] != null
            ? List<dynamic>.from(json["reorder_levels"].map((x) => x))
            : [],
    attributes:
        json["attributes"] != null
            ? List<dynamic>.from(json["attributes"].map((x) => x))
            : [],
    itemDefaults:
        json["item_defaults"] != null
            ? List<ItemDefaultModel>.from(
              json["item_defaults"].map((x) => ItemDefaultModel.fromJson(x)),
            )
            : [],
    supplierItems:
        json["supplier_items"] != null
            ? List<dynamic>.from(json["supplier_items"].map((x) => x))
            : [],
    customerItems:
        json["customer_items"] != null
            ? List<dynamic>.from(json["customer_items"].map((x) => x))
            : [],
    taxes:
        json["taxes"] != null
            ? List<dynamic>.from(json["taxes"].map((x) => x))
            : [],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation,
    "modified": modified,
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "naming_series": namingSeries,
    "item_code": itemCode,
    "item_name": itemName,
    "item_group": itemGroup,
    "stock_uom": stockUom,
    "custom_vendor": customVendor,
    "disabled": disabled,
    "allow_alternative_item": allowAlternativeItem,
    "is_stock_item": isStockItem,
    "has_variants": hasVariants,
    "opening_stock": openingStock,
    "valuation_rate": valuationRate,
    "standard_rate": standardRate,
    "is_fixed_asset": isFixedAsset,
    "auto_create_assets": autoCreateAssets,
    "is_grouped_asset": isGroupedAsset,
    "over_delivery_receipt_allowance": overDeliveryReceiptAllowance,
    "over_billing_allowance": overBillingAllowance,
    "description": description,
    "shelf_life_in_days": shelfLifeInDays,
    "end_of_life": endOfLife,
    "default_material_request_type": defaultMaterialRequestType,
    "valuation_method": valuationMethod,
    "weight_per_unit": weightPerUnit,
    "allow_negative_stock": allowNegativeStock,
    "has_batch_no": hasBatchNo,
    "create_new_batch": createNewBatch,
    "has_expiry_date": hasExpiryDate,
    "retain_sample": retainSample,
    "sample_quantity": sampleQuantity,
    "has_serial_no": hasSerialNo,
    "variant_based_on": variantBasedOn,
    "enable_deferred_expense": enableDeferredExpense,
    "no_of_months_exp": noOfMonthsExp,
    "enable_deferred_revenue": enableDeferredRevenue,
    "no_of_months": noOfMonths,
    "min_order_qty": minOrderQty,
    "safety_stock": safetyStock,
    "is_purchase_item": isPurchaseItem,
    "lead_time_days": leadTimeDays,
    "last_purchase_rate": lastPurchaseRate,
    "is_customer_provided_item": isCustomerProvidedItem,
    "delivered_by_supplier": deliveredBySupplier,
    "country_of_origin": countryOfOrigin,
    "grant_commission": grantCommission,
    "is_sales_item": isSalesItem,
    "max_discount": maxDiscount,
    "inspection_required_before_purchase": inspectionRequiredBeforePurchase,
    "inspection_required_before_delivery": inspectionRequiredBeforeDelivery,
    "include_item_in_manufacturing": includeItemInManufacturing,
    "is_sub_contracted_item": isSubContractedItem,
    "customer_code": customerCode,
    "published_in_website": publishedInWebsite,
    "total_projected_qty": totalProjectedQty,
    "doctype": doctype,
    "uoms": uoms?.map((x) => x.toJson()).toList(),
    "barcodes": barcodes,
    "reorder_levels": reorderLevels,
    "attributes": attributes,
    "item_defaults": itemDefaults?.map((x) => x.toJson()).toList(),
    "supplier_items": supplierItems,
    "customer_items": customerItems,
    "taxes": taxes,
  };

  Item toEntity() => Item(
    name: name,
    owner: owner,
    creation: creation,
    modified: modified,
    modifiedBy: modifiedBy,
    docstatus: docstatus,
    idx: idx,
    namingSeries: namingSeries,
    itemCode: itemCode,
    itemName: itemName,
    itemGroup: itemGroup,
    stockUom: stockUom,
    customVendor: customVendor,
    disabled: disabled,
    allowAlternativeItem: allowAlternativeItem,
    isStockItem: isStockItem,
    hasVariants: hasVariants,
    openingStock: openingStock,
    valuationRate: valuationRate,
    standardRate: standardRate,
    isFixedAsset: isFixedAsset,
    autoCreateAssets: autoCreateAssets,
    isGroupedAsset: isGroupedAsset,
    overDeliveryReceiptAllowance: overDeliveryReceiptAllowance,
    overBillingAllowance: overBillingAllowance,
    description: description,
    shelfLifeInDays: shelfLifeInDays,
    endOfLife: endOfLife,
    defaultMaterialRequestType: defaultMaterialRequestType,
    valuationMethod: valuationMethod,
    weightPerUnit: weightPerUnit,
    allowNegativeStock: allowNegativeStock,
    hasBatchNo: hasBatchNo,
    createNewBatch: createNewBatch,
    hasExpiryDate: hasExpiryDate,
    retainSample: retainSample,
    sampleQuantity: sampleQuantity,
    hasSerialNo: hasSerialNo,
    variantBasedOn: variantBasedOn,
    enableDeferredExpense: enableDeferredExpense,
    noOfMonthsExp: noOfMonthsExp,
    enableDeferredRevenue: enableDeferredRevenue,
    noOfMonths: noOfMonths,
    minOrderQty: minOrderQty,
    safetyStock: safetyStock,
    isPurchaseItem: isPurchaseItem,
    leadTimeDays: leadTimeDays,
    lastPurchaseRate: lastPurchaseRate,
    isCustomerProvidedItem: isCustomerProvidedItem,
    deliveredBySupplier: deliveredBySupplier,
    countryOfOrigin: countryOfOrigin,
    grantCommission: grantCommission,
    isSalesItem: isSalesItem,
    maxDiscount: maxDiscount,
    inspectionRequiredBeforePurchase: inspectionRequiredBeforePurchase,
    inspectionRequiredBeforeDelivery: inspectionRequiredBeforeDelivery,
    includeItemInManufacturing: includeItemInManufacturing,
    isSubContractedItem: isSubContractedItem,
    customerCode: customerCode,
    publishedInWebsite: publishedInWebsite,
    totalProjectedQty: totalProjectedQty,
    doctype: doctype,
    uoms: uoms?.map((e) => e.toEntity()).toList(),
    barcodes: barcodes,
    reorderLevels: reorderLevels,
    attributes: attributes,
    itemDefaults: itemDefaults?.map((e) => e.toEntity()).toList(),
    supplierItems: supplierItems,
    customerItems: customerItems,
    taxes: taxes,
  );

  @override
  List<Object?> get props => [name, itemCode];
}

class UomModel {
  final String name;
  final String? owner;
  final String? creation;
  final String? modified;
  final String? modifiedBy;
  final int? docstatus;
  final int? idx;
  final String? uom;
  final double? conversionFactor;
  final String? parent;
  final String? parentfield;
  final String? parenttype;
  final String? doctype;

  UomModel({
    required this.name,
    this.owner,
    this.creation,
    this.modified,
    this.modifiedBy,
    this.docstatus,
    this.idx,
    this.uom,
    this.conversionFactor,
    this.parent,
    this.parentfield,
    this.parenttype,
    this.doctype,
  });

  factory UomModel.fromJson(Map<String, dynamic> json) => UomModel(
    name: json["name"],
    owner: json["owner"],
    creation: json["creation"],
    modified: json["modified"],
    modifiedBy: json["modified_by"],
    docstatus: json["docstatus"],
    idx: json["idx"],
    uom: json["uom"],
    conversionFactor: (json["conversion_factor"] as num).toDouble(),
    parent: json["parent"],
    parentfield: json["parentfield"],
    parenttype: json["parenttype"],
    doctype: json["doctype"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation,
    "modified": modified,
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "uom": uom,
    "conversion_factor": conversionFactor,
    "parent": parent,
    "parentfield": parentfield,
    "parenttype": parenttype,
    "doctype": doctype,
  };

  Uom toEntity() =>
      Uom(uom: uom, conversionFactor: conversionFactor, name: name);
}

class SpecificationModel extends Equatable {
  final String label;
  final String description;

  const SpecificationModel({required this.label, required this.description});

  factory SpecificationModel.fromJson(Map<String, dynamic> json) {
    return SpecificationModel(
      label: json['label'] ?? '',
      description: _extractTextFromHtml(json['description'] ?? ''),
    );
  }

  SpecificationModel toEntity() {
    return SpecificationModel(label: label, description: description);
  }

  static String _extractTextFromHtml(String html) {
    final tagRegExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return html.replaceAll(tagRegExp, '').trim();
  }

  @override
  List<Object?> get props => [label, description];
}

class ItemDefaultModel {
  final String name;
  final String? owner;
  final String? creation;
  final String? modified;
  final String? modifiedBy;
  final int? docstatus;
  final int? idx;
  final String? company;
  final String? defaultWarehouse;
  final String? incomeAccount;
  final String? parent;
  final String? parentfield;
  final String? parenttype;
  final String? doctype;

  ItemDefaultModel({
    required this.name,
    this.owner,
    this.creation,
    this.modified,
    this.modifiedBy,
    this.docstatus,
    this.idx,
    this.company,
    this.defaultWarehouse,
    this.incomeAccount,
    this.parent,
    this.parentfield,
    this.parenttype,
    this.doctype,
  });

  factory ItemDefaultModel.fromJson(Map<String, dynamic> json) =>
      ItemDefaultModel(
        name: json["name"],
        owner: json["owner"],
        creation: json["creation"],
        modified: json["modified"],
        modifiedBy: json["modified_by"],
        docstatus: json["docstatus"],
        idx: json["idx"],
        company: json["company"],
        defaultWarehouse: json["default_warehouse"],
        incomeAccount: json["income_account"],
        parent: json["parent"],
        parentfield: json["parentfield"],
        parenttype: json["parenttype"],
        doctype: json["doctype"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner": owner,
    "creation": creation,
    "modified": modified,
    "modified_by": modifiedBy,
    "docstatus": docstatus,
    "idx": idx,
    "company": company,
    "default_warehouse": defaultWarehouse,
    "income_account": incomeAccount,
    "parent": parent,
    "parentfield": parentfield,
    "parenttype": parenttype,
    "doctype": doctype,
  };

  ItemDefault toEntity() => ItemDefault(parent: parent, name: name);
}
