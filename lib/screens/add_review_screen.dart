import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// Writes a new review, or edits one the user already wrote.
///
/// The same screen does both jobs. When [existingReview] is null it creates
/// a record; when it holds a review, the fields start filled in and saving
/// updates that record instead.
///
/// Four different field types are used here: a slider for the rating, a
/// dropdown for the meal, a date picker for the visit date, and a multi-line
/// text field for the comment.
class AddReviewScreen extends StatefulWidget {
  final Restaurant restaurant;
  final Review? existingReview;

  const AddReviewScreen({
    super.key,
    required this.restaurant,
    this.existingReview,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  double _rating = 4;
  String _visitType = 'Dinner';
  DateTime _visitDate = DateTime.now();

  bool _isSaving = false;
  String? _errorMessage;

  static const List<String> _visitTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Takeaway',
  ];

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    // When editing, start from the values already saved.
    final Review? existing = widget.existingReview;
    if (existing != null) {
      _commentController.text = existing.comment;
      _rating = existing.rating;
      if (_visitTypes.contains(existing.visitType)) {
        _visitType = existing.visitType;
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Formats a date as "12 Aug 2026" without needing an extra package.
  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? chosen = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      // A visit cannot be in the future, and a year back is far enough.
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: now,
    );

    if (chosen != null) {
      setState(() => _visitDate = chosen);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final String userId = AuthService.currentUser?.uid ?? '';
      final String authorName =
          AuthService.currentUser?.displayName ?? 'Anonymous';

      final Review review = Review(
        // When creating, the id is ignored: Firebase generates one.
        id: widget.existingReview?.id ?? '',
        restaurantId: widget.restaurant.id,
        userId: userId,
        authorName: authorName,
        rating: _rating,
        comment: _commentController.text.trim(),
        visitType: _visitType,
        visitDate: _formatDate(_visitDate),
      );

      if (_isEditing) {
        await DatabaseService.updateReview(review);
      } else {
        await DatabaseService.addReview(review);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Review updated' : 'Review posted'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not save your review. Check your connection '
              'and try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Write a few words about your visit';
    }
    if (value.trim().length < 10) {
      return 'Please write at least 10 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme colours = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit review' : 'Write a review'),
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
                    Text(widget.restaurant.name, style: text.titleLarge),
                    Text(
                      widget.restaurant.area,
                      style: text.bodySmall?.copyWith(
                        color: colours.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // FIELD 1 - slider
                    Text('Your rating', style: text.labelLarge),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _rating,
                            min: 1,
                            max: 5,
                            divisions: 8,
                            label: _rating.toStringAsFixed(1),
                            onChanged: (double value) {
                              setState(() => _rating = value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 18,
                                color: colours.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: text.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // FIELD 2 - dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _visitType,
                      decoration: const InputDecoration(
                        labelText: 'Which meal?',
                        prefixIcon: Icon(Icons.restaurant_menu),
                        border: OutlineInputBorder(),
                      ),
                      items: _visitTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _visitType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // FIELD 3 - date picker
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'When did you visit?',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_formatDate(_visitDate)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // FIELD 4 - multi-line text
                    TextFormField(
                      controller: _commentController,
                      maxLines: 5,
                      maxLength: 400,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Your review',
                        hintText: 'What did you order? How was the service?',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateComment,
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
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

                    const SizedBox(height: 16),
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
                          : Text(_isEditing ? 'Save changes' : 'Post review'),
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
