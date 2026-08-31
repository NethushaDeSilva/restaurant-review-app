import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/restaurant.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

/// Adds a new restaurant, or edits one the signed-in user already owns.
///
/// The same screen does both jobs. When [existingRestaurant] is null it
/// creates a record; when it holds a restaurant, the fields start filled in
/// and saving updates that record instead.
///
/// The owner does not set a rating. A new listing starts at zero and shows
/// as "New" until customers review it, so an owner cannot score their own
/// restaurant.
class AddRestaurantScreen extends StatefulWidget {
  final Restaurant? existingRestaurant;

  const AddRestaurantScreen({super.key, this.existingRestaurant});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dishesController = TextEditingController();

  String _cuisine = 'Sri Lankan';
  double? _latitude;
  double? _longitude;

  bool _isSaving = false;
  bool _loadingLocation = false;
  String? _errorMessage;
  String? _locationMessage;

  static const List<String> _cuisines = [
    'Sri Lankan',
    'Seafood',
    'South Indian',
    'Chinese',
    'Japanese',
    'Fusion',
    'Cafe',
    'Bakery',
    'Fast Food',
    'Other',
  ];

  bool get _isEditing => widget.existingRestaurant != null;

  @override
  void initState() {
    super.initState();
    final Restaurant? existing = widget.existingRestaurant;
    if (existing != null) {
      _nameController.text = existing.name;
      _areaController.text = existing.area;
      _priceController.text = existing.priceRange;
      _imageController.text = existing.imageUrl;
      _descriptionController.text = existing.description;
      _dishesController.text = existing.popularDishes;
      if (_cuisines.contains(existing.cuisine)) {
        _cuisine = existing.cuisine;
      }
      _latitude = existing.latitude;
      _longitude = existing.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _dishesController.dispose();
    super.dispose();
  }

  /// Fills the coordinates from the device GPS, so an owner standing in
  /// their restaurant can tag it without typing numbers.
  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationMessage = null;
    });

    try {
      final Position position = await LocationService.currentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationMessage = 'Location captured from GPS';
        });
      }
    } on LocationException catch (error) {
      if (mounted) {
        setState(() => _locationMessage = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _locationMessage = 'Could not read your location.');
      }
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      setState(() {
        _errorMessage =
            'Set the restaurant location before saving. Tap "Use my current '
            'location" while you are at the restaurant.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final String ownerId = AuthService.currentUser?.uid ?? '';

      final Restaurant restaurant = Restaurant(
        // When creating, the id is ignored: Firebase generates one.
        id: widget.existingRestaurant?.id ?? '',
        ownerId: ownerId,
        name: _nameController.text.trim(),
        cuisine: _cuisine,
        area: _areaController.text.trim(),
        // Ratings come from customer reviews, never from the owner.
        rating: widget.existingRestaurant?.rating ?? 0,
        priceRange: _priceController.text.trim(),
        imageUrl: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
        popularDishes: _dishesController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
      );

      if (_isEditing) {
        await DatabaseService.updateRestaurant(restaurant);
      } else {
        await DatabaseService.addRestaurant(restaurant);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Restaurant updated' : 'Restaurant added',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Could not save. Check your connection and try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Paste a photo link for your restaurant';
    }
    if (!value.trim().startsWith('http')) {
      return 'That does not look like a web link';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Describe your restaurant';
    }
    if (value.trim().length < 20) {
      return 'Please write at least 20 characters';
    }
    return null;
  }

  Widget _buildLocationBox() {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;
    final bool hasLocation = _latitude != null && _longitude != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: colours.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasLocation ? Icons.location_on : Icons.location_off,
                size: 20,
                color: hasLocation ? colours.primary : colours.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text('Restaurant location', style: text.labelLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasLocation
                ? '${_latitude!.toStringAsFixed(4)}, '
                      '${_longitude!.toStringAsFixed(4)}'
                : 'Not set yet',
            style: text.bodyMedium?.copyWith(
              color: hasLocation ? null : colours.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _loadingLocation ? null : _useCurrentLocation,
            icon: _loadingLocation
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, size: 18),
            label: Text(
              hasLocation ? 'Update from GPS' : 'Use my current location',
            ),
          ),
          if (_locationMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _locationMessage!,
              style: text.bodySmall?.copyWith(
                color: hasLocation ? colours.primary : colours.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit restaurant' : 'Add your restaurant'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Listings you add appear to everyone using the app. '
                      'Customers rate them; you cannot review your own.',
                      style: text.bodySmall?.copyWith(
                        color: colours.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Restaurant name',
                        prefixIcon: Icon(Icons.storefront_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _required(value, 'Enter the restaurant name'),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _cuisine,
                      decoration: const InputDecoration(
                        labelText: 'Cuisine',
                        prefixIcon: Icon(Icons.restaurant_menu),
                        border: OutlineInputBorder(),
                      ),
                      items: _cuisines.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _cuisine = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _areaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Address or area',
                        hintText: 'e.g. Galle Road, Moratuwa',
                        prefixIcon: Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _required(value, 'Enter the area or address'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price range',
                        hintText: 'e.g. Rs 800 - 2,000',
                        prefixIcon: Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _required(value, 'Enter a typical price range'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _imageController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Photo link',
                        hintText: 'https://...',
                        helperText: 'Paste an image address from the web',
                        prefixIcon: Icon(Icons.image_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateImageUrl,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _dishesController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Popular dishes',
                        hintText: 'e.g. Kottu, hoppers, devilled chicken',
                        prefixIcon: Icon(Icons.local_dining_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _required(value, 'List a few dishes you are known for'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 400,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'What makes your restaurant worth visiting?',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateDescription,
                    ),
                    const SizedBox(height: 8),

                    _buildLocationBox(),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colours.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 20,
                              color: colours.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: text.bodySmall?.copyWith(
                                  color: colours.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isEditing
                                  ? 'Save changes'
                                  : 'Add restaurant',
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
