// [DATA] screen â talks to LoginVm (auth API).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/notifications/notification_center.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';
import 'login_vm.dart';
import 'qr_scan_screen.dart';

/// Login screen. Two ways to sign in, matching the prototype:
///   - National ID + password  (`POST /auth/login`)
///   - QR wristband token       (`POST /auth/login/qr`)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _qrCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    _qrCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final vm = context.read<LoginVm>();
    final session = vm.tab == LoginTab.idPassword
        ? await vm.submit(_idCtrl.text, _passCtrl.text)
        : await vm.submitQr(_qrCtrl.text);

    if (session != null && mounted) {
      // Start polling for notifications (live bell badge + heads-up banners).
      context.read<NotificationCenter>().start();
      // Logged in â go to Home and clear the auth screens from the stack.
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
    }
  }

  /// Opens the camera scanner; on a successful scan, fills the token field and
  /// logs in straight away.
  Future<void> _scanQr() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (code == null || code.isEmpty || !mounted) return;
    _qrCtrl.text = code;
    await _login();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginVm>();
    // Watch the language so the whole screen re-localizes on switch.
    final loc = context.watch<LocaleController>();

    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: const BrandBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Header ---
                Image.asset(
                  'assets/images/hospital_logo.png',
                  height: 54.h,
                  errorBuilder: (_, __, ___) => Text(
                    'Alamein Model Hospital',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  loc.t('sign_in'),
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  loc.t('login_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
                ),
                SizedBox(height: 24.h),

                // --- Card ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 26.h),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppTheme.shadowLg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TabBar(
                        tab: vm.tab,
                        onChanged: vm.switchTab,
                      ),
                      SizedBox(height: 22.h),

                      if (vm.tab == LoginTab.idPassword)
                        _idPasswordPanel()
                      else
                        _qrPanel(),

                      // --- Error message ---
                      if (vm.error != null) ...[
                        SizedBox(height: 14.h),
                        _ErrorBox(message: vm.error!),
                      ],

                      SizedBox(height: 18.h),

                      // --- Log In button ---
                      SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: vm.loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: vm.loading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  loc.t('log_in'),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  loc.t('footer'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textDim),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- ID & password fields ---
  Widget _idPasswordPanel() {
    final loc = context.read<LocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(loc.t('national_id')),
        SizedBox(height: 6.h),
        _input(
          controller: _idCtrl,
          hint: loc.t('national_id_hint'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16.h),
        _FieldLabel(loc.t('password')),
        SizedBox(height: 6.h),
        _input(
          controller: _passCtrl,
          hint: loc.t('password_hint'),
          obscure: _obscure,
          onSubmitted: (_) => _login(),
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textMuted,
              size: 20.sp,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ],
    );
  }

  // --- QR panel ---
  Widget _qrPanel() {
    final loc = context.read<LocaleController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tap to open the camera scanner.
        InkWell(
          onTap: _scanQr,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.border2,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, size: 56.sp, color: AppColors.blue),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    loc.t('qr_box_hint'),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 46.h,
          child: OutlinedButton.icon(
            onPressed: _scanQr,
            icon: Icon(Icons.qr_code_scanner, size: 18.sp),
            label: Text(loc.t('scan_qr'), style: TextStyle(fontSize: 14.sp)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Manual fallback (useful on emulators with no camera).
        _FieldLabel(loc.t('qr_token')),
        SizedBox(height: 6.h),
        _input(
          controller: _qrCtrl,
          hint: loc.t('qr_token_hint'),
          onSubmitted: (_) => _login(),
        ),
      ],
    );
  }

  // Shared text-field builder styled like the prototype's .input-field.
  Widget _input({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      style: TextStyle(fontSize: 14.sp, color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textDim, fontSize: 14.sp),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.border2, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.blue, width: 1.5),
        ),
      ),
    );
  }
}

/// The ID&Password / QR segmented tabs.
class _TabBar extends StatelessWidget {
  final LoginTab tab;
  final ValueChanged<LoginTab> onChanged;

  const _TabBar({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.bluePale,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _seg(loc.t('tab_id_password'), LoginTab.idPassword),
          _seg(loc.t('tab_qr'), LoginTab.qr),
        ],
      ),
    );
  }

  Widget _seg(String label, LoginTab value) {
    final active = tab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.red, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.5.sp, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
