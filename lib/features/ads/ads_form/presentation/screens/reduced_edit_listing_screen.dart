import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/contact_info.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_type_picker.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/price_visibility_toggle.dart';
import 'package:africaonlinestores/features/ads/ads_form/presentation/steps/pricing/service_unit_picker.dart';
import 'package:africaonlinestores/features/ads/ads_form/utils/ad_update_contract.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
import 'package:africaonlinestores/features/ads/shared/utils/ad_failure_message.dart';
import 'package:africaonlinestores/features/ads/shared/utils/pricing_rules.dart';
import 'package:africaonlinestores/shared/components/app_bottom_bar_surface.dart';
import 'package:africaonlinestores/shared/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReducedEditListingScreen extends ConsumerStatefulWidget {
  const ReducedEditListingScreen({super.key, required this.adId});

  final String adId;

  @override
  ConsumerState<ReducedEditListingScreen> createState() =>
      _ReducedEditListingScreenState();
}

class _ReducedEditListingScreenState
    extends ConsumerState<ReducedEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerPriceController = TextEditingController();

  Map<String, dynamic> _source = const <String, dynamic>{};
  String _status = '';
  String _initialTitle = '';
  String _initialDescription = '';
  String _priceType = 'Fixed';
  String? _priceUnit;
  String _pricingRequirement = 'Optional';
  List<String> _allowedPriceTypes = const <String>[];
  List<String> _allowedPriceUnits = const <String>[];
  bool _isService = false;
  bool _pricingTouched = false;
  DateTime? _offerStart;
  DateTime? _offerEnd;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _loadGeneration = 0;

  bool get _isFullEdit => _status == 'Reviewing' || _status == 'Declined';
  bool get _canEdit => _status == 'Active' || _isFullEdit;
  bool get _pricingHidden =>
      _pricingRequirement.trim().toLowerCase() == 'hidden';
  bool get _needsAmount => _priceType == 'Fixed' || _priceType == 'Negotiable';
  bool get _isFixedPrice => _priceType == 'Fixed';
  bool get _isContactMode => _priceType == 'Contact for price';

  List<String> get _effectiveAllowedPriceTypes =>
      _allowedPriceTypes.isEmpty ? defaultAdPriceTypes : _allowedPriceTypes;

  List<String> get _visiblePriceTypes => _effectiveAllowedPriceTypes
      .where((type) => type != 'Contact for price')
      .toList(growable: false);

  bool get _supportsContactPrice =>
      _effectiveAllowedPriceTypes.contains('Contact for price');

  bool get _requiresPricingValidation => _isFullEdit || _pricingTouched;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant ReducedEditListingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adId != widget.adId) {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _loadGeneration += 1;
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _offerPriceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final result = await ref.read(adsApiProvider).getMyAd(adId: widget.adId);
    if (!mounted || generation != _loadGeneration) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = adFailureMessage(failure);
      }),
      (json) {
        try {
          final data = asJsonMap(json['data']);
          final item = asJsonMap(data['item']);
          if (item.isEmpty) {
            throw const FormatException('Missing edit item');
          }

          final pricing = asJsonMap(item['pricing']);
          final allowedTypes = asJsonList(pricing['allowed_price_types'])
              .map((value) => value.toString().trim())
              .where((value) => value.isNotEmpty)
              .toList(growable: false);
          final allowedUnits = asJsonList(pricing['allowed_price_units'])
              .map((value) => value.toString().trim())
              .where((value) => value.isNotEmpty)
              .toList(growable: false);
          final requirement =
              asString(pricing['pricing_requirement']).trim().isEmpty
              ? 'Optional'
              : asString(pricing['pricing_requirement']).trim();
          final effectiveTypes = allowedTypes.isEmpty
              ? defaultAdPriceTypes
              : allowedTypes;
          final storedPriceType = asString(item['price_type']).trim();
          final initialPriceType = storedPriceType.isNotEmpty
              ? storedPriceType
              : requirement.toLowerCase() == 'hidden'
              ? ''
              : effectiveTypes.contains('Fixed')
              ? 'Fixed'
              : effectiveTypes.length == 1
              ? effectiveTypes.single
              : '';

          final offerPrice = _optionalPositiveDouble(item['offer_price']);
          final title = asString(item['title']);
          final description = asString(item['description']);

          _source = item;
          _status = asString(item['status']).trim();
          _initialTitle = title;
          _initialDescription = description;
          _titleController.text = title;
          _descriptionController.text = description;
          _priceController.text = _numberText(item['price']);
          _offerPriceController.text = _numberText(offerPrice);
          _priceType = initialPriceType;
          final storedPriceUnit = asNullableString(item['price_unit']);
          _priceUnit =
              allowedUnits.isEmpty ||
                  storedPriceUnit == null ||
                  allowedUnits.contains(storedPriceUnit)
              ? storedPriceUnit
              : null;
          _pricingRequirement = requirement;
          _allowedPriceTypes = allowedTypes;
          _allowedPriceUnits = allowedUnits;
          _isService = asBool(item['is_service']);
          _pricingTouched = false;
          _offerStart = offerPrice == null
              ? null
              : _parseDate(item['offer_start_date']);
          _offerEnd = offerPrice == null
              ? null
              : _parseDate(item['offer_end_date']);

          setState(() {
            _loading = false;
            _error = null;
          });
        } on FormatException {
          setState(() {
            _loading = false;
            _error = 'Could not load listing details.';
          });
        }
      },
    );
  }

  static double? _optionalPositiveDouble(Object? value) {
    if (value == null) return null;
    final parsed = double.tryParse(value.toString().trim());
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  static String _numberText(Object? value) {
    if (value == null) return '';
    final number = double.tryParse(value.toString());
    if (number == null) return value.toString();
    return number == number.roundToDouble()
        ? number.toInt().toString()
        : number.toString();
  }

  String? _validateTitle(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return 'Title is required.';
    if (clean.length < 5) return 'Title must be at least 5 characters.';
    if (clean.length > 140) return 'Title must be 140 characters or fewer.';
    return null;
  }

  String? _validateDescription(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return 'Description is required.';
    if (clean.length < 20) {
      return 'Description must be at least 20 characters.';
    }
    if (clean.length > 5000) {
      return 'Description must be 5000 characters or fewer.';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (!_requiresPricingValidation || _pricingHidden || !_needsAmount) {
      return null;
    }
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return 'Enter a valid price.';
    return null;
  }

  String? _validateOfferPrice(String? value) {
    if (!_requiresPricingValidation || _pricingHidden) return null;

    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return null;

    final offer = double.tryParse(clean);
    if (offer == null || offer <= 0) {
      return 'Offer price must be greater than zero.';
    }
    if (!_isFixedPrice) {
      return 'Offers are only available for fixed-price listings.';
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || offer >= price) {
      return 'Offer price must be lower than price.';
    }
    return null;
  }

  String? _validatePriceUnit(String? value) {
    if (!_requiresPricingValidation || !_isService || !_needsAmount) {
      return null;
    }
    if (_allowedPriceUnits.isEmpty) {
      return 'This service category has no valid price units configured. Choose another price type.';
    }
    final clean = value?.trim() ?? '';
    if (clean.isEmpty || !_allowedPriceUnits.contains(clean)) {
      return 'Select a valid price unit.';
    }
    return null;
  }

  static DateTime? _parseDate(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : DateTime.tryParse(text);
  }

  void _setPriceType(String type) {
    setState(() {
      _pricingTouched = true;
      _priceType = type;

      if (type == 'Contact for price' || type == 'Free') {
        _priceController.clear();
        _priceUnit = null;
      }

      if (type != 'Fixed') {
        _offerPriceController.clear();
        _offerStart = null;
        _offerEnd = null;
      }
    });
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _offerStart : _offerEnd;
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: initial ?? DateTime.now(),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _pricingTouched = true;
      if (start) {
        _offerStart = selected;
      } else {
        _offerEnd = selected;
      }
    });
  }

  Map<String, dynamic> _pricingPayload({required bool includeClears}) {
    if (_pricingHidden) return <String, dynamic>{};

    final payload = <String, dynamic>{'price_type': _priceType};

    if (_needsAmount) {
      payload['price'] = double.tryParse(_priceController.text.trim());
      if (_isService) {
        payload['price_unit'] = _priceUnit;
      } else if (includeClears) {
        payload['price_unit'] = null;
      }
    } else if (includeClears) {
      payload['price'] = null;
      payload['price_unit'] = null;
    }

    final offerPrice = _isFixedPrice
        ? _optionalPositiveDouble(_offerPriceController.text)
        : null;

    if (offerPrice != null) {
      payload['offer_price'] = offerPrice;
      payload['offer_start_date'] = _dateText(_offerStart);
      payload['offer_end_date'] = _dateText(_offerEnd);
    } else if (includeClears) {
      payload['offer_price'] = null;
      payload['offer_start_date'] = null;
      payload['offer_end_date'] = null;
    }

    return payload;
  }

  Map<String, dynamic> _activeCandidate() {
    final payload = <String, dynamic>{};
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title != _initialTitle.trim()) payload['title'] = title;
    if (description != _initialDescription.trim()) {
      payload['description'] = description;
    }
    if (_pricingTouched) {
      payload.addAll(_pricingPayload(includeClears: true));
    }

    return payload;
  }

  Map<String, dynamic> _fullCandidate() {
    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _source['location'],
      'category': _source['category'],
      'details': _source['details'] ?? const <Object>[],
      'images': _source['images'] ?? const <Object>[],
      'video_media': _source['video_media_id'] ?? _source['video_media'],
    };
    payload.addAll(_pricingPayload(includeClears: false));
    return payload;
  }

  Future<void> _save() async {
    if (_saving || !_canEdit) return;

    if (_requiresPricingValidation &&
        !_pricingHidden &&
        !_effectiveAllowedPriceTypes.contains(_priceType)) {
      ShowSnack(
        context,
        'This price type is not allowed for the listing category. Choose another price type.',
      ).error();
      return;
    }

    if (_requiresPricingValidation &&
        _isService &&
        _needsAmount &&
        _allowedPriceUnits.isEmpty) {
      ShowSnack(
        context,
        'This service category has no valid price units configured. Choose another permitted price type.',
      ).error();
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_requiresPricingValidation &&
        _isFixedPrice &&
        _offerPriceController.text.trim().isNotEmpty &&
        _offerStart != null &&
        _offerEnd != null &&
        _offerStart!.isAfter(_offerEnd!)) {
      ShowSnack(context, 'Offer end date must be after start date.').error();
      return;
    }

    final candidate = _status == 'Active'
        ? _activeCandidate()
        : _fullCandidate();
    final contract = AdUpdateContract.payloadForStatus(
      status: _status,
      candidate: candidate,
    );

    if (contract.isLeft) {
      ShowSnack(
        context,
        adFailureMessage(contract.leftOrNull!, adStatus: _status),
      ).error();
      return;
    }

    setState(() => _saving = true);

    final result = await ref
        .read(adsApiProvider)
        .updateAd(adId: widget.adId, payload: contract.rightOrNull!);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _saving = false);
        ShowSnack(
          context,
          adFailureMessage(failure, adStatus: _status),
        ).error();
      },
      (_) {
        setState(() => _saving = false);
        ShowSnack(context, 'Listing updated successfully.').success();
        Navigator.of(context).pop(true);
      },
    );
  }

  static String? _dateText(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Listing')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Listing')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => unawaited(_load()),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Listing')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              if (!_canEdit) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AdUpdateContract.editBlockedMessage(_status),
                    style: context.pStrong,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Text('Title', style: context.h5),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                maxLength: 140,
                validator: _validateTitle,
                enabled: _canEdit,
                decoration: const InputDecoration(hintText: 'Listing title'),
              ),
              const SizedBox(height: 18),
              Text('Item description', style: context.h5),
              const SizedBox(height: 6),
              Text(
                'Provide clear information buyers need before contacting you.',
                style: context.pMuted,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                minLines: 6,
                maxLines: 10,
                maxLength: 5000,
                validator: _validateDescription,
                enabled: _canEdit,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              if (!_pricingHidden) ...[
                const SizedBox(height: 24),
                Text('Set Pricing', style: context.h5),
                const SizedBox(height: 14),
                if (_supportsContactPrice) ...[
                  PriceVisibilityToggle(
                    priceType: _priceType,
                    onSpecify: () {
                      if (!_canEdit || !_isContactMode) return;
                      final next = _visiblePriceTypes.contains('Fixed')
                          ? 'Fixed'
                          : (_visiblePriceTypes.isEmpty
                                ? null
                                : _visiblePriceTypes.first);
                      if (next != null) _setPriceType(next);
                    },
                    onContact: () {
                      if (!_canEdit || _isContactMode) return;
                      _setPriceType('Contact for price');
                    },
                  ),
                  const SizedBox(height: 18),
                ],
                if (_isContactMode)
                  const ContactInfoCard()
                else ...[
                  if (_needsAmount) ...[
                    Text('Regular Price', style: context.pStrong),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      enabled: _canEdit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validatePrice,
                      onChanged: (_) => _pricingTouched = true,
                      decoration: InputDecoration(
                        prefixText: '${_source['currency'] ?? ''} ',
                        hintText: 'Enter price',
                      ),
                    ),
                    if (_isService && _allowedPriceUnits.isEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Fixed or negotiable pricing is unavailable because this service category has no price units configured. Choose another permitted price type.',
                        style: TextStyle(color: colors.error),
                      ),
                    ],
                    if (_isService && _allowedPriceUnits.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ServiceUnitPicker(
                        units: _allowedPriceUnits,
                        selected: _priceUnit,
                        onChanged: _canEdit
                            ? (value) {
                                setState(() {
                                  _pricingTouched = true;
                                  _priceUnit = value;
                                });
                              }
                            : (_) {},
                      ),
                      Builder(
                        builder: (context) {
                          final error = _validatePriceUnit(_priceUnit);
                          return error == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    error,
                                    style: TextStyle(color: colors.error),
                                  ),
                                );
                        },
                      ),
                    ],
                    const SizedBox(height: 18),
                  ],
                  PriceTypePicker(
                    selected: _priceType,
                    options: _visiblePriceTypes,
                    onChanged: _canEdit ? _setPriceType : (_) {},
                  ),
                  if (_isFixedPrice) ...[
                    const SizedBox(height: 18),
                    Text('Offer Price (Optional)', style: context.pStrong),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _offerPriceController,
                      enabled: _canEdit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateOfferPrice,
                      onChanged: (_) => _pricingTouched = true,
                      decoration: InputDecoration(
                        prefixText: '${_source['currency'] ?? ''} ',
                        hintText: 'Enter offer price',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month, color: colors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Schedule Offer Dates',
                                  style: context.pStrong,
                                ),
                              ),
                              Switch(
                                value: _offerStart != null || _offerEnd != null,
                                onChanged: !_canEdit
                                    ? null
                                    : (enabled) {
                                        setState(() {
                                          _pricingTouched = true;
                                          if (!enabled) {
                                            _offerStart = null;
                                            _offerEnd = null;
                                          } else {
                                            _offerStart ??= DateTime.now();
                                          }
                                        });
                                      },
                              ),
                            ],
                          ),
                          if (_offerStart != null || _offerEnd != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _canEdit
                                        ? () => _pickDate(start: true)
                                        : null,
                                    icon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    label: Text(
                                      _dateText(_offerStart) ?? 'Start date',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _canEdit
                                        ? () => _pickDate(start: false)
                                        : null,
                                    icon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    label: Text(
                                      _dateText(_offerEnd) ?? 'End date',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBarSurface(
        padding: const EdgeInsets.all(10),
        child: FilledButton(
          onPressed: _saving || !_canEdit ? null : _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: colors.primary,
            foregroundColor: colors.btnText,
          ),
          child: _saving
              ? SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.btnText,
                  ),
                )
              : const Text('Save Changes'),
        ),
      ),
    );
  }
}
