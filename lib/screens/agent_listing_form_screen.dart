import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/map_mode.dart';
import '../models/property_listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../services/map/location_name_service.dart';
import 'location_picker_screen.dart';

class AgentListingFormScreen extends StatefulWidget {
  final PropertyListing? existing;

  const AgentListingFormScreen({super.key, this.existing});

  @override
  State<AgentListingFormScreen> createState() => _AgentListingFormScreenState();
}

class _AgentListingFormScreenState extends State<AgentListingFormScreen> {
  late PropertyType _type;
  late bool _isAvailable;
  late double _rating;
  late double _traction;

  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  LatLng? _pickedLocation;
  String _areaLabel = 'Unknown';

  final Set<String> _amenities = {};
  late List<String> _images;

  static const _amenityOptions = <String>[
    'Wi‑Fi',
    'Parking',
    'Breakfast',
    'Hot shower',
    'Security',
    'Lake view',
    'Kitchen',
    'Air conditioning',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? PropertyType.apartment;
    _isAvailable = existing?.isAvailable ?? true;
    _rating = existing?.rating ?? 4.5;
    _traction = (existing?.traction ?? 50).toDouble();
    _titleCtrl.text = existing?.title ?? '';
    _priceCtrl.text = existing?.priceLabel ?? '';
    _rulesCtrl.text = existing?.houseRules ?? '';
    _pickedLocation = existing?.location;
    _areaLabel = existing?.areaLabel ?? 'Unknown';
    _amenities.addAll(existing?.amenities ?? const []);

    // Images (allow agent-provided URLs). Keep existing order.
    final existingImages = existing?.images;
    if (existingImages != null && existingImages.isNotEmpty) {
      _images = List<String>.from(existingImages);
    } else {
      _images = List<String>.from(const [
        'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
        'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
      ]);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _rulesCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  bool _isValidImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    // Accept common direct image URLs + Google Drive direct-view links.
    final lower = trimmed.toLowerCase();
    final isHttp = lower.startsWith('http://') || lower.startsWith('https://');
    if (!isHttp) return false;
    final looksLikeImage = lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
    final isDrive = lower.contains('drive.google.com');
    return looksLikeImage || isDrive;
  }

  void _addImageUrl() {
    final url = _imageUrlCtrl.text.trim();
    if (!_isValidImageUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a valid image URL (.jpg/.png/etc) or a Google Drive link')),
      );
      return;
    }
    if (_images.contains(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That image URL is already added')),
      );
      return;
    }
    setState(() {
      _images.add(url);
      _imageUrlCtrl.clear();
    });
  }

  Future<void> _pickOnMap() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (picked == null) return;
    
    // Fetch location name from Mapbox API
    final areaLabel = await LocationNameService.getLocationName(picked.latitude, picked.longitude);
    
    setState(() {
      _pickedLocation = picked;
      _areaLabel = areaLabel;
    });
  }

  void _save() {
    final auth = context.read<AuthProvider>();
    final listings = context.read<ListingsProvider>();

    final user = auth.currentUser;
    if (user == null || !auth.isAgent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agent access required')),
      );
      return;
    }
    if (_titleCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty || _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title, price, and location are required')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one photo URL')),
      );
      return;
    }

    final now = DateTime.now();

    final listing = PropertyListing(
      id: widget.existing?.id ?? 'listing_${now.millisecondsSinceEpoch}',
      agentId: user.id,
      type: _type,
      title: _titleCtrl.text.trim(),
      areaLabel: _areaLabel,
      location: _pickedLocation!,
      isAvailable: _isAvailable,
      priceLabel: _priceCtrl.text.trim(),
      rating: double.parse(_rating.toStringAsFixed(1)),
      traction: _traction.round(),
      amenities: _amenities.toList()..sort(),
      houseRules: _rulesCtrl.text.trim(),
      images: List<String>.from(_images),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.existing == null) {
      listings.addListing(listing);
    } else {
      listings.updateListing(listing);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Listing' : 'Add Listing',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basics'),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Price (e.g. KSh 2,500/night)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
              title: const Text('Available'),
              subtitle: const Text('Only available listings are shown to normal users'),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Location'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.place, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pickedLocation == null
                          ? 'No location selected'
                          : '$_areaLabel\n${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _pickOnMap,
                    child: const Text('Pick on map'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Amenities'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amenityOptions.map((a) {
                final selected = _amenities.contains(a);
                return FilterChip(
                  label: Text(a),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _amenities.add(a);
                      } else {
                        _amenities.remove(a);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Photos'),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlCtrl,
              decoration: InputDecoration(
                labelText: 'Add photo URL',
                hintText: 'Paste direct image link (.jpg/.png) or Google Drive link',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_link),
                  onPressed: _addImageUrl,
                ),
              ),
              onSubmitted: (_) => _addImageUrl(),
            ),
            const SizedBox(height: 12),
            if (_images.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Added photos (${_images.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ..._images.map((url) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                url,
                                width: 64,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 64,
                                    height: 48,
                                    color: Theme.of(context).dividerColor,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                url,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _images.remove(url);
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      );
                    }),
                    Text(
                      'Tip: add compound, sitting room, kitchen, bathroom, bedroom photos.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildSectionTitle('House rules'),
            const SizedBox(height: 12),
            TextField(
              controller: _rulesCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Add simple rules (check-in, smoking, noise...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Signals'),
            const SizedBox(height: 12),
            _buildSliderRow(
              label: 'Rating',
              value: _rating,
              min: 1,
              max: 5,
              divisions: 40,
              valueLabel: _rating.toStringAsFixed(1),
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 12),
            _buildSliderRow(
              label: 'Traction',
              value: _traction,
              min: 0,
              max: 200,
              divisions: 200,
              valueLabel: _traction.round().toString(),
              onChanged: (v) => setState(() => _traction = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(isEdit ? 'Save changes' : 'Add listing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(child: _typeChip(PropertyType.apartment, Icons.apartment)),
        const SizedBox(width: 12),
        Expanded(child: _typeChip(PropertyType.bnb, Icons.hotel)),
      ],
    );
  }

  Widget _typeChip(PropertyType type, IconData icon) {
    final selected = _type == type;
    return InkWell(
      onTap: () => setState(() => _type = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color),
            const SizedBox(width: 8),
            Text(type.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              Text(valueLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

