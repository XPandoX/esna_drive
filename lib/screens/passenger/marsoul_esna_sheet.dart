import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/public_apis_service.dart';
import '../../models/esna_place.dart';

class MarsoulEsnaSheet extends StatefulWidget {
  final Function(EsnaPlace place, String recipientPhone, String itemDesc, String payer, bool doorToDoor) onConfirmed;

  const MarsoulEsnaSheet({super.key, required this.onConfirmed});

  @override
  State<MarsoulEsnaSheet> createState() => _MarsoulEsnaSheetState();
}

class _MarsoulEsnaSheetState extends State<MarsoulEsnaSheet> {
  final _recipientPhoneController = TextEditingController();
  final _itemDescController = TextEditingController();
  String _selectedPayer = 'الراسل';
  bool _doorToDoor = false;
  String _activeCategory = 'الكل';

  List<EsnaPlace> _places = [];
  bool _isLoadingPlaces = true;
  EsnaPlace? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _loadLiveServices();
  }

  Future<void> _loadLiveServices() async {
    setState(() => _isLoadingPlaces = true);
    final places = await PublicApisService.getEsnaServices();
    if (mounted) {
      setState(() {
        _places = places;
        if (_places.isNotEmpty) {
          _selectedPlace = _places.first;
        }
        _isLoadingPlaces = false;
      });
    }
  }

  List<EsnaPlace> get _filteredPlaces {
    if (_activeCategory == 'الكل') return _places;
    return _places.where((p) => p.category.contains(_activeCategory)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_shipping, color: AppTheme.primaryLime, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'مرسول إسنا (توصيل طلبات وطرود)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed: _showProhibitedItemsDialog,
                icon: const Icon(Icons.info_outline, color: AppTheme.warningOrange, size: 22),
                tooltip: 'المواد المحظور نقلها',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Categories Tabs (from Overpass API)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['الكل', 'صيدليات', 'مطاعم وكافيهات', 'مستشفيات', 'سوبرماركت'].map((cat) {
                final isSelected = _activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _activeCategory = cat),
                    selectedColor: AppTheme.primaryLime,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: AppTheme.darkCard,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Live Places Selector (Overpass API)
          const Text(
            'اختر مكان الشراء / الاستلام (حي ومباشر من إسنا):',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 95,
            child: _isLoadingPlaces
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryLime))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _filteredPlaces[index];
                      final isSelected = _selectedPlace?.id == place.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPlace = place),
                        child: Container(
                          width: 170,
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryLime.withOpacity(0.15) : AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryLime : AppTheme.darkBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                place.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected ? AppTheme.primaryLime : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                place.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                              if (place.phone != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  place.phone!,
                                  style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _itemDescController,
                    decoration: const InputDecoration(
                      labelText: 'وصف الطلب أو محتوى الطرد (مثلاً: روشتة علاج، وجبة)',
                      prefixIcon: Icon(Icons.description_outlined, color: AppTheme.primaryLime),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _recipientPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم هاتف المستلم (لإرسال كود الاستلام)',
                      prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryLime),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Door to door toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _doorToDoor,
                      onChanged: (val) => setState(() => _doorToDoor = val),
                      title: const Text(
                        'خدمة تسليم من الباب للباب (+5 ج.م)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: const Text(
                        'صعود المندوب للدور أو الشقة لتسليم واستلام الطرد',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                      activeColor: AppTheme.primaryLime,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Who pays
                  const Text(
                    'من سيتحمل تكلفة الأجرة؟',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['الراسل', 'المستلم'].map((payer) {
                      final isSelected = _selectedPayer == payer;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPayer = payer),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryLime.withOpacity(0.15) : AppTheme.darkCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryLime : AppTheme.darkBorder,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              payer,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.primaryLime : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedPlace == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى اختيار مكان الاستلام أولاً')),
                  );
                  return;
                }
                widget.onConfirmed(
                  _selectedPlace!,
                  _recipientPhoneController.text.trim(),
                  _itemDescController.text.trim(),
                  _selectedPayer,
                  _doorToDoor,
                );
                Navigator.pop(context);
              },
              child: const Text('تأكيد تفاصيل مرسول إسنا'),
            ),
          ),
        ],
      ),
    );
  }

  void _showProhibitedItemsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppTheme.alertRed),
            SizedBox(width: 8),
            Text('المواد المحظور نقلها', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AppConstants.prohibitedItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.alertRed, fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(color: AppTheme.primaryLime)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recipientPhoneController.dispose();
    _itemDescController.dispose();
    super.dispose();
  }
}
