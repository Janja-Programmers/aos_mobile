import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/core/utils/json_utils.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';

class SellerAboutSection extends StatefulWidget {
  const SellerAboutSection({
    super.key,
    required this.about,
    this.location,
    this.operatingHours = const <Object?>[],
  });

  final String about;
  final AOSSellerLocation? location;
  final List<Object?> operatingHours;

  @override
  State<SellerAboutSection> createState() => _SellerAboutSectionState();
}

class _SellerAboutSectionState extends State<SellerAboutSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final about = widget.about.trim();
    final location = widget.location;
    final hours = _visibleHours(widget.operatingHours);

    return SectionCard(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => expanded = !expanded);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'About',
                      style: context.h6.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.textMuted,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          if (expanded) ...[
            if (about.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  about,
                  style: context.body.copyWith(
                    height: 1.45,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
            if (location != null) ...[
              SizedBox(height: about.isEmpty ? 16 : 20),
              _AboutLocation(location: location),
            ],
            if (hours.isNotEmpty) ...[
              SizedBox(height: about.isEmpty && location == null ? 16 : 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Active hours',
                  style: context.pStrong.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...hours.map(
                (hour) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(hour.day, style: context.smallMuted),
                      ),
                      Expanded(
                        child: Text(
                          '${hour.openTime} – ${hour.closeTime}',
                          style: context.small.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AboutLocation extends StatelessWidget {
  const _AboutLocation({required this.location});

  final AOSSellerLocation location;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = location.subtitle;
    final instructions = location.instructions?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: .14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_outlined, color: colors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.title,
                  style: context.pStrong.copyWith(fontWeight: FontWeight.w800),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.smallMuted,
                  ),
                ],
                if (instructions != null && instructions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    instructions,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.small.copyWith(color: colors.textPrimary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerOpenHour {
  const _SellerOpenHour({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  final String day;
  final String openTime;
  final String closeTime;
}

List<_SellerOpenHour> _visibleHours(List<Object?> rawHours) {
  final result = <_SellerOpenHour>[];

  for (final raw in rawHours) {
    if (raw is! Map) continue;

    final item = asJsonMap(raw);
    final isOpen = _truthy(item['is_open']);
    if (!isOpen) continue;

    final day = _dayLabel(item['day_of_week']?.toString());
    final openTime = _timeLabel(item['open_time']?.toString());
    final closeTime = _timeLabel(item['close_time']?.toString());

    if (day.isEmpty || openTime.isEmpty || closeTime.isEmpty) continue;

    result.add(
      _SellerOpenHour(day: day, openTime: openTime, closeTime: closeTime),
    );
  }

  return result;
}

String _dayLabel(String? value) {
  switch (value?.trim()) {
    case 'Mon':
    case 'Monday':
      return 'Mon';
    case 'Tue':
    case 'Tuesday':
      return 'Tue';
    case 'Wed':
    case 'Wednesday':
      return 'Wed';
    case 'Thu':
    case 'Thursday':
      return 'Thu';
    case 'Fri':
    case 'Friday':
      return 'Fri';
    case 'Sat':
    case 'Saturday':
      return 'Sat';
    case 'Sun':
    case 'Sunday':
      return 'Sun';
    default:
      return value?.trim() ?? '';
  }
}

String _timeLabel(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return '';

  final parts = raw.split(':');
  if (parts.length < 2) return raw;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return raw;

  final suffix = hour >= 12 ? 'PM' : 'AM';
  var displayHour = hour;
  if (hour == 0) {
    displayHour = 12;
  } else if (hour > 12) {
    displayHour = hour - 12;
  }
  final displayMinute = minute.toString().padLeft(2, '0');
  return '$displayHour:$displayMinute $suffix';
}

bool _truthy(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final clean = value?.toString().trim().toLowerCase() ?? '';
  return clean == '1' || clean == 'true' || clean == 'yes';
}
