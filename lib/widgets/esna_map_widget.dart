import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/ride_provider.dart';

class EsnaMapWidget extends StatefulWidget {
  final MapController? controller;
  final bool showLandmarks;
  final Function(EsnaLandmark)? onLandmarkSelected;

  const EsnaMapWidget({
    super.key,
    this.controller,
    this.showLandmarks = true,
    this.onLandmarkSelected,
  });

  @override
  State<EsnaMapWidget> createState() => _EsnaMapWidgetState();
}

class _EsnaMapWidgetState extends State<EsnaMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.controller ?? MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProv, child) {
        final routePoints = rideProv.currentRoutePoints;
        final pickupPos = rideProv.pickup.location;
        final destPos = rideProv.destination.location;
        final driverPos = rideProv.driverCurrentPosition;

        final markers = <Marker>[
          // Pickup Marker
          Marker(
            point: pickupPos,
            width: 50,
            height: 50,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLime,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.primaryLime,
                  size: 16,
                ),
              ],
            ),
          ),

          // Destination Marker
          Marker(
            point: destPos,
            width: 50,
            height: 50,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.alertRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.alertRed,
                  size: 16,
                ),
              ],
            ),
          ),
        ];

        // Driver moving marker
        if (driverPos != null) {
          final isMoto = rideProv.selectedCategory == 'motorcycle';
          markers.add(
            Marker(
              point: driverPos,
              width: 54,
              height: 54,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isMoto ? Icons.two_wheeler : Icons.electric_rickshaw,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        }

        // Landmark markers
        if (widget.showLandmarks) {
          for (final landmark in AppConstants.esnaLandmarks) {
            markers.add(
              Marker(
                point: landmark.location,
                width: 32,
                height: 32,
                child: GestureDetector(
                  onTap: () {
                    widget.onLandmarkSelected?.call(landmark);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface.withOpacity(0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.darkBorder, width: 1),
                    ),
                    child: const Icon(
                      Icons.place_outlined,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: AppConstants.esnaCenter,
            initialZoom: AppConstants.defaultZoom,
            minZoom: 12.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.esnadrive.app',
            ),
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5.5,
                    color: AppTheme.primaryLime,
                    borderStrokeWidth: 1.5,
                    borderColor: Colors.black45,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}
