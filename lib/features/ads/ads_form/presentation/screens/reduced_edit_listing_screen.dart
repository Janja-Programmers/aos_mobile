import 'dart:async';

import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/ads/shared/providers/ads_api_provider.dart';
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

  Map<String, dynamic> _source = const {};
  String _status = '';
  String _priceType = 'Fixed';
  DateTime? _offerStart;
  DateTime? _offerEnd;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _offerPriceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ref.read(adsApiProvider).getMyAd(adId: widget.adId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (json) {
        final data = asJsonMap(json['data']);
        final item = asJsonMap(data['item']);
        _source = item;
        _status = (item['status'] ?? '').toString();
        _titleController.text = (item['title'] ?? '').toString();
        _descriptionController.text = (item['description'] ?? '').toString();
        _priceController.text = _numberText(item['price']);
        _offerPriceController.text = _numberText(item['offer_price']);
        _priceType = (item['price_type'] ?? 'Fixed').toString();
        _offerStart = _parseDate(item['offer_start_date']);
        _offerEnd = _parseDate(item['offer_end_date']);
        setState(() => _loading = false);
      },
    );
  }

  static String _numberText(Object? value) {
    if (value == null) return '';
    final number = double.tryParse(value.toString());
    if (number == null) return value.toString();
    return number == number.roundToDouble()
        ? number.toInt().toString()
        : number.toString();
  }

  static DateTime? _parseDate(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : DateTime.tryParse(text);
  }

  bool get _isFullEdit => _status == 'Reviewing' || _status == 'Declined';

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
      if (start) {
        _offerStart = selected;
      } else {
        _offerEnd = selected;
      }
    });
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    if (_status == 'Sold' || _status == 'Expired' || _status == 'Deleted') {
      ShowSnack(context, 'This listing cannot be edited.').error();
      return;
    }

    setState(() => _saving = true);
    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price_type': _priceType,
      'price': _priceController.text.trim().isEmpty
          ? null
          : double.tryParse(_priceController.text.trim()),
      'price_unit': _source['price_unit'],
      'offer_price': _offerPriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_offerPriceController.text.trim()),
      'offer_start_date': _dateText(_offerStart),
      'offer_end_date': _dateText(_offerEnd),
    };

    // Reviewing/Declined use the backend's full-edit contract. Preserve all
    // fields and media that are intentionally not shown in the reduced UI.
    if (_isFullEdit) {
      payload.addAll({
        'location': _source['location'],
        'category': _source['category'],
        'details': _source['details'] ?? const <Object>[],
        'images': _source['images'] ?? const <Object>[],
        'video_media': _source['video_media_id'] ?? _source['video_media'],
      });
    }

    final result = await ref
        .read(adsApiProvider)
        .updateAd(adId: widget.adId, payload: payload);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _saving = false);
        ShowSnack(context, failure.message).error();
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Listing')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _load,
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
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
              Text('Title', style: context.h5),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                maxLength: 80,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required.'
                    : null,
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
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required.'
                    : null,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 24),
              Text('Set Pricing', style: context.h5),
              const SizedBox(height: 14),
              Text('Regular Price', style: context.pStrong),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  prefixText: '${_source['currency'] ?? ''} ',
                  hintText: 'Enter price',
                ),
              ),
              const SizedBox(height: 18),
              Text('Price Type', style: context.pStrong),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        _priceType == 'Fixed'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _priceType == 'Fixed' ? colors.primary : null,
                      ),
                      title: const Text('Fixed Price'),
                      subtitle: const Text('Price is firm and non-negotiable'),
                      selected: _priceType == 'Fixed',
                      onTap: () => setState(() => _priceType = 'Fixed'),
                    ),
                    Divider(height: 1, color: colors.border),
                    ListTile(
                      leading: Icon(
                        _priceType == 'Negotiable'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: _priceType == 'Negotiable'
                            ? colors.primary
                            : null,
                      ),
                      title: const Text('Negotiable'),
                      subtitle: const Text(
                        'Buyers can make offers on this item',
                      ),
                      selected: _priceType == 'Negotiable',
                      onTap: () => setState(() => _priceType = 'Negotiable'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('Offer Price (Optional)', style: context.pStrong),
              const SizedBox(height: 8),
              TextFormField(
                controller: _offerPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                          onChanged: (enabled) {
                            setState(() {
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
                              onPressed: () => _pickDate(start: true),
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                _dateText(_offerStart) ?? 'Start date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDate(start: false),
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(_dateText(_offerEnd) ?? 'End date'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBarSurface(
        padding: const EdgeInsets.all(10),
        child: FilledButton(
          onPressed: _saving ? null : _save,
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
