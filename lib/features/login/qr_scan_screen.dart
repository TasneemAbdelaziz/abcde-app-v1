import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';

/// Full-screen camera QR scanner. Pops with the scanned string (the patient's
/// `qr_token`, e.g. "QR-1XL7X8ZV3T"), or null if the user backs out.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false; // pop only once

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(context.watch<LocaleController>().t('scan_qr')),
        actions: [
          IconButton(
            tooltip: 'Flash',
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            tooltip: 'Switch camera',
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'Camera unavailable.\n${error.errorDetails?.message ?? ''}\n\n'
                  'On an emulator, type the QR token manually instead.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              ),
            ),
          ),
          // Scanning frame.
          Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3.w),
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          Positioned(
            bottom: 60.h,
            left: 24.w,
            right: 24.w,
            child: Text(
              'Point the camera at the patient QR wristband',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
