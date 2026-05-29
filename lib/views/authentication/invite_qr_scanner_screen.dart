import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/deep_link_service.dart';

class InviteQrScannerScreen extends StatefulWidget {
  const InviteQrScannerScreen({super.key});

  @override
  State<InviteQrScannerScreen> createState() => _InviteQrScannerScreenState();
}

class _InviteQrScannerScreenState extends State<InviteQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final DeepLinkService _deepLinkService = GetIt.I<DeepLinkService>();

  bool _isHandlingScan = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isHandlingScan) {
      return;
    }

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');

    if (rawValue.isEmpty) {
      return;
    }

    final route = _deepLinkService.mapLinkToRoute(rawValue);
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unsupported QR code. Please scan a valid invite.'),
        ),
      );
      return;
    }

    _isHandlingScan = true;
    await _controller.stop();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan invite QR'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Point your camera at an invite QR code.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

