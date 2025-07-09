import 'package:equatable/equatable.dart';

class Item extends Equatable {
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
  final List<Uom>? uoms;
  final List<dynamic>? barcodes;
  final List<dynamic>? reorderLevels;
  final List<dynamic>? attributes;
  final List<ItemDefault>? itemDefaults;
  final List<dynamic>? supplierItems;
  final List<dynamic>? customerItems;
  final List<dynamic>? taxes;

  const Item({
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

  @override
  List<Object?> get props => [
    name,
    owner,
    creation,
    modified,
    modifiedBy,
    docstatus,
    idx,
    namingSeries,
    itemCode,
    itemName,
    itemGroup,
    stockUom,
    customVendor,
    disabled,
    allowAlternativeItem,
    isStockItem,
    hasVariants,
    openingStock,
    valuationRate,
    standardRate,
    isFixedAsset,
    autoCreateAssets,
    isGroupedAsset,
    overDeliveryReceiptAllowance,
    overBillingAllowance,
    description,
    shelfLifeInDays,
    endOfLife,
    defaultMaterialRequestType,
    valuationMethod,
    weightPerUnit,
    allowNegativeStock,
    hasBatchNo,
    createNewBatch,
    hasExpiryDate,
    retainSample,
    sampleQuantity,
    hasSerialNo,
    variantBasedOn,
    enableDeferredExpense,
    noOfMonthsExp,
    enableDeferredRevenue,
    noOfMonths,
    minOrderQty,
    safetyStock,
    isPurchaseItem,
    leadTimeDays,
    lastPurchaseRate,
    isCustomerProvidedItem,
    deliveredBySupplier,
    countryOfOrigin,
    grantCommission,
    isSalesItem,
    maxDiscount,
    inspectionRequiredBeforePurchase,
    inspectionRequiredBeforeDelivery,
    includeItemInManufacturing,
    isSubContractedItem,
    customerCode,
    publishedInWebsite,
    totalProjectedQty,
  ];
}

class Uom {
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

  Uom({
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

  List<Object?> get props => [
    name,
    owner,
    creation,
    modified,
    modifiedBy,
    docstatus,
    idx,
    uom,
    conversionFactor,
    parent,
    parentfield,
    parenttype,
    doctype,
  ];
}

class ItemDefault {
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

  ItemDefault({
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
}
