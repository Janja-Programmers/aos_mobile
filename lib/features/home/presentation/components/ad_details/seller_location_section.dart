import 'dart:async';

import 'package:africaonlinestores/core/config/app_config.dart';
import 'package:africaonlinestores/core/theme/app_text_styles.dart';
import 'package:africaonlinestores/core/theme/app_theme_extensions.dart';
import 'package:africaonlinestores/features/maps/navigation/maps_routes.dart';
import 'package:africaonlinestores/features/maps/presentation/widgets/maplibre_platform_chrome.dart';
import 'package:africaonlinestores/features/sellers/domain/aos_seller.dart';
import 'package:africaonlinestores/shared/components/cards/section_card.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class SellerLocationSection extends StatefulWidget {
  const SellerLocationSection({
    super.key,
    required this.sellerId,
    required this.location,
  });

  final String sellerId;
  final AOSSellerLocation location;

  @override
  State<SellerLocationSection> createState() => _SellerLocationSectionState();
}

class _SellerLocationSectionState extends State<SellerLocationSection> {
  MapLibreMapController? _map;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final location = widget.location;
    final latitude = location.latitude;
    final longitude = location.longitude;
    final hasCoordinates = latitude != null && longitude != null;
    final address = location.subtitle ?? location.title;

    return SectionCard(
      title: 'Shop location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: hasCoordinates
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: MapLibreMap(
                            styleString: AppConfig.mapStyleUrl,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(latitude, longitude),
                              zoom: 15,
                            ),
                            attributionButtonMargins:
                                aosMapAttributionButtonMargins,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            onMapCreated: (controller) => _map = controller,
                          ),
                        ),
                        Center(
                          child: IgnorePointer(
                            child: Icon(
                              Icons.location_pin,
                              color: colors.primary,
                              size: 48,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 10,
                          end: 10,
                          child: Column(
                            children: [
                              _PreviewMapControl(
                                icon: Icons.add_rounded,
                                tooltip: 'Zoom in',
                                onTap: () => unawaited(
                                  _map?.animateCamera(CameraUpdate.zoomIn()),
                                ),
                              ),
                              const SizedBox(height: 6),
                              _PreviewMapControl(
                                icon: Icons.remove_rounded,
                                tooltip: 'Zoom out',
                                onTap: () => unawaited(
                                  _map?.animateCamera(CameraUpdate.zoomOut()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ColoredBox(
                      color: colors.elevated,
                      child: Center(
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 48,
                          color: colors.primary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: colors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.pStrong,
                    ),
                    Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.smallMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(foregroundColor: colors.white),
                onPressed: hasCoordinates
                    ? () {
                        MapsNavigation.toExplorer<void>(
                          context,
                          sellerId: widget.sellerId,
                        );
                      }
                    : null,
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: Text(
                  'View map',
                  style: AppTextStylesX(
                    context,
                  ).button.copyWith(color: colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewMapControl extends StatelessWidget {
  const _PreviewMapControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface.withValues(alpha: .94),
      elevation: 2,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: colors.primary),
      ),
    );
  }
}
