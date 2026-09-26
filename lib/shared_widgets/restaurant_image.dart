import 'package:flutter/material.dart';

/// Loads a restaurant photo from the internet.
///
/// Image.network on its own shows nothing while downloading and a red error
/// box if the URL fails. The two builders below replace that with a spinner
/// and a neutral fallback icon, so a slow connection or a dead link never
/// makes the app look broken.
///
/// [height] is optional. When it is null the widget fills whatever space the
/// parent gives it, which is what the grid layout needs.
///
/// [heroTag] is optional. When two screens use the same tag for the same
/// photo, Flutter animates the image between them during the page change.
class RestaurantImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final String? heroTag;

  const RestaurantImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colours = Theme.of(context).colorScheme;

    final Widget image = Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,

      // Runs repeatedly while the photo downloads.
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child; // finished downloading, show the real image
        }
        return Container(
          height: height,
          color: colours.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator()),
        );
      },

      // Runs if the URL is wrong or the device is offline.
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: colours.surfaceContainerHighest,
          child: Icon(
            Icons.restaurant,
            size: 40,
            color: colours.onSurfaceVariant,
          ),
        );
      },
    );

    if (heroTag == null) {
      return image;
    }

    return Hero(tag: heroTag!, child: image);
  }
}
