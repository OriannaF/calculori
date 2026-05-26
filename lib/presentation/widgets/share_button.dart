import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ShareResultButton extends StatelessWidget {
  final ScreenshotController screenshotController;
  final String productName;
  final double basePrice;

  const ShareResultButton({
    super.key,
    required this.screenshotController,
    required this.productName,
    required this.basePrice,
  });

  Future<void> _takeScreenshotAndShare(BuildContext context) async {
    try {
      HapticFeedback.mediumImpact();
      
      final imageBytes = await screenshotController.capture(delay: const Duration(milliseconds: 20));
      
      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/precio_$productName.png').create();
        await imagePath.writeAsBytes(imageBytes);

        final textToShare = '¡Mirá el precio de $productName! Base: \$${basePrice.toStringAsFixed(0)}';
        
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(imagePath.path)],
            text: textToShare,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.share_rounded),
      label: const Text('Compartir'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE1E0FF),
        foregroundColor: const Color(0xFF4648D4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => _takeScreenshotAndShare(context),
    );
  }
}
