import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/public_apis_service.dart';
import '../../models/esna_place.dart';
import '../../models/ride_order.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/esna_map_widget.dart';
import '../../widgets/weather_banner.dart';
import '../../widgets/role_drawer.dart';
import 'bidding_screen.dart';
import 'active_ride_screen.dart';
import 'marsoul_esna_sheet.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer3<RideProvider, AuthProvider, WeatherProvider>(
      builder: (context, rideProv, authProv, weatherProv, child) {
        // If a ride is active, show the tracking screen
        if (rideProv.currentRide != null) {
          if (rideProv.currentRide!.status == RideStatus.bidding) {
            return const BiddingScreen();
          } else if (rideProv.currentRide!.status == RideStatus.accepted ||
              rideProv.currentRide!.status == RideStatus.driverArrived ||
              rideProv.currentRide!.status == RideStatus.inProgress ||
              rideProv.currentRide!.status == RideStatus.completed) {
            return const ActiveRideScreen();
          }
        }

        final isExtremeHeat = weatherProv.weather?.isExtremeHeat ?? false;

        return Scaffold(
          key: _scaffoldKey,
          drawer: const RoleDrawer(),
          body: Stack(
            children: [
              // 1. Live Interactive Map
              Positioned.fill(
                child: EsnaMapWidget(
                  onLandmarkSelected: (landmark) {
                    _selectLandmarkAsDestination(landmark, rideProv, isExtremeHeat);
                  },
                ),
              ),

              // 2. Top Bar & Weather
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: AppTheme.primaryLime),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                            tooltip: 'القائمة وتبديل الوضع',
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'إسنا درايف - EsnaDrive',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  'مشوارك بسعرك • توك توك وموتوسيكل',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLime.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: AppTheme.primaryLime, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  authProv.userName.split(' ').first,
                                  style: const TextStyle(
                                    color: AppTheme.primaryLime,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Weather Banner with heat bonus alert
                    const WeatherBanner(),

                    // 10 Esna Landmark Quick Pickers
                    SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: AppConstants.esnaLandmarks.length,
                        itemBuilder: (context, index) {
                          final landmark = AppConstants.esnaLandmarks[index];
                          final isCurrentDest = rideProv.destination.id == landmark.id;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ActionChip(
                              label: Text(landmark.name),
                              avatar: Icon(
                                isCurrentDest ? Icons.check_circle : Icons.near_me,
                                size: 14,
                                color: isCurrentDest ? Colors.black : AppTheme.primaryLime,
                              ),
                              backgroundColor: isCurrentDest ? AppTheme.primaryLime : AppTheme.darkSurface.withOpacity(0.9),
                              labelStyle: TextStyle(
                                color: isCurrentDest ? Colors.black : Colors.white,
                                fontSize: 11,
                                fontWeight: isCurrentDest ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isCurrentDest ? AppTheme.primaryLime : AppTheme.darkBorder,
                              ),
                              onPressed: () {
                                _selectLandmarkAsDestination(landmark, rideProv, isExtremeHeat);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bottom inDrive Booking & Offer Panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pickup & Destination Inputs
                      _buildRouteCard(context, rideProv, isExtremeHeat),
                      const SizedBox(height: 12),

                      // 4 Service Categories
                      _buildCategorySelector(rideProv, isExtremeHeat),
                      const SizedBox(height: 12),

                      // Route Distance & OSRM Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.alt_route, color: AppTheme.primaryLime, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${rideProv.currentDistanceKm} كم • ${rideProv.currentDurationMin} دقيقة (عبر OSRM)',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                          // Payment Method dropdown
                          DropdownButton<String>(
                            value: rideProv.paymentMethod,
                            dropdownColor: AppTheme.darkCard,
                            underline: const SizedBox.shrink(),
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryLime),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            items: ['كاش', 'فودافون كاش', 'إنستا باي'].map((method) {
                              return DropdownMenuItem(value: method, child: Text(method));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) rideProv.setPaymentMethod(val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Offer Fare Row (inDrive Core algorithm)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'اعرض الأجرة المناسبة لك',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${rideProv.offeredPrice.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryLime,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'ج.م',
                                        style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Quick Increment buttons
                            _buildQuickBumpButton('+5 ج.م', () => rideProv.increaseOffer(5)),
                            const SizedBox(width: 8),
                            _buildQuickBumpButton('+10 ج.م', () => rideProv.increaseOffer(10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Request Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (rideProv.selectedCategory == 'marsoul' &&
                                rideProv.courierItemDescription.isEmpty) {
                              _openMarsoulSheet(context, rideProv, isExtremeHeat);
                              return;
                            }
                            rideProv.requestRide(
                              passengerName: authProv.userName,
                              passengerPhone: authProv.phoneNumber ?? '01012345678',
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.flash_on, color: Colors.black, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'اعرض سعرك واطلب الآن',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteCard(BuildContext context, RideProvider rideProv, bool isExtremeHeat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          // Pickup Row
          InkWell(
            onTap: () => _openSearchDialog(context, isPickup: true, rideProv: rideProv, isExtremeHeat: isExtremeHeat),
            child: Row(
              children: [
                const Icon(Icons.circle, color: AppTheme.primaryLime, size: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rideProv.pickup.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
              ],
            ),
          ),
          const Divider(color: AppTheme.darkBorder, height: 16),
          // Destination Row
          InkWell(
            onTap: () => _openSearchDialog(context, isPickup: false, rideProv: rideProv, isExtremeHeat: isExtremeHeat),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.alertRed, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rideProv.destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(RideProvider rideProv, bool isExtremeHeat) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppConstants.categories.map((cat) {
          final isSelected = rideProv.selectedCategory == cat.id;
          return GestureDetector(
            onTap: () {
              rideProv.setCategory(cat.id, isExtremeHeat: isExtremeHeat);
              if (cat.id == 'marsoul') {
                _openMarsoulSheet(context, rideProv, isExtremeHeat);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLime.withOpacity(0.18) : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryLime : AppTheme.darkBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(cat.id),
                    color: isSelected ? AppTheme.primaryLime : AppTheme.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryLime : Colors.white,
                        ),
                      ),
                      Text(
                        cat.capacity,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickBumpButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryLime.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primaryLime.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryLime,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String id) {
    switch (id) {
      case 'toktok':
        return Icons.electric_rickshaw;
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'marsoul':
        return Icons.local_shipping;
      case 'villages':
        return Icons.commute;
      default:
        return Icons.directions_car;
    }
  }

  void _selectLandmarkAsDestination(EsnaLandmark landmark, RideProvider rideProv, bool isExtremeHeat) {
    rideProv.setDestination(
      EsnaPlace(
        id: landmark.id,
        name: landmark.name,
        category: 'معالم إسنا',
        location: landmark.location,
        address: landmark.description,
      ),
    );
    rideProv.updateRoute(isExtremeHeat: isExtremeHeat);
  }

  void _openMarsoulSheet(BuildContext context, RideProvider rideProv, bool isExtremeHeat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarsoulEsnaSheet(
        onConfirmed: (place, recipientPhone, itemDesc, payer, doorToDoor) {
          rideProv.setPickup(place);
          rideProv.setDoorToDoor(doorToDoor, isExtremeHeat: isExtremeHeat);
          rideProv.setCourierDetails(
            recipientPhone: recipientPhone,
            itemDescription: itemDesc,
            payer: payer,
          );
          rideProv.updateRoute(isExtremeHeat: isExtremeHeat);
        },
      ),
    );
  }

  void _openSearchDialog(BuildContext context, {required bool isPickup, required RideProvider rideProv, required bool isExtremeHeat}) {
    showDialog(
      context: context,
      builder: (context) {
        List<EsnaPlace> searchResults = [];
        bool isSearching = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isPickup ? 'تحديد نقطة الانطلاق في إسنا' : 'تحديد الوجهة في إسنا',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن شارع أو معلم بإسنا (Nominatim)...',
                        prefixIcon: Icon(Icons.search, color: AppTheme.primaryLime),
                      ),
                      onChanged: (val) async {
                        if (val.trim().length >= 2) {
                          setDialogState(() => isSearching = true);
                          final res = await PublicApisService.searchPlaces(val);
                          setDialogState(() {
                            searchResults = res;
                            isSearching = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (isSearching)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: AppTheme.primaryLime),
                      )
                    else
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          itemCount: searchResults.isNotEmpty ? searchResults.length : AppConstants.esnaLandmarks.length,
                          itemBuilder: (context, index) {
                            if (searchResults.isNotEmpty) {
                              final place = searchResults[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: AppTheme.primaryLime, size: 20),
                                title: Text(place.name, style: const TextStyle(fontSize: 13)),
                                subtitle: Text(place.address, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                onTap: () {
                                  if (isPickup) {
                                    rideProv.setPickup(place);
                                  } else {
                                    rideProv.setDestination(place);
                                  }
                                  rideProv.updateRoute(isExtremeHeat: isExtremeHeat);
                                  Navigator.pop(context);
                                },
                              );
                            } else {
                              final landmark = AppConstants.esnaLandmarks[index];
                              return ListTile(
                                leading: const Icon(Icons.place_outlined, color: AppTheme.textMuted, size: 20),
                                title: Text(landmark.name, style: const TextStyle(fontSize: 13)),
                                subtitle: Text(landmark.description, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                onTap: () {
                                  final p = EsnaPlace(
                                    id: landmark.id,
                                    name: landmark.name,
                                    category: 'معالم إسنا',
                                    location: landmark.location,
                                    address: landmark.description,
                                  );
                                  if (isPickup) {
                                    rideProv.setPickup(p);
                                  } else {
                                    rideProv.setDestination(p);
                                  }
                                  rideProv.updateRoute(isExtremeHeat: isExtremeHeat);
                                  Navigator.pop(context);
                                },
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: AppTheme.textMuted)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
