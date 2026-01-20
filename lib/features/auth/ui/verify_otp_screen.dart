import 'package:flutter/material.dart';

import '../data/auth_api.dart';

import 'aos_ui.dart';

class VerifyOTPScreen extends StatefulWidget {
  const VerifyOTPScreen({
    super.key,
    required this.authApi,
    required this.email,
  });
  final AuthApi authApi;
  final String email;

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text.trim()).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // paste handling: take first 6 digits
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      FocusScope.of(context).unfocus();
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the 6-digit code')));
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await widget.authApi.verifyOtp(
        email: widget.email,
        otp: _otp,
      );
      final ok = res['ok'] == true;
      final msg = (res['message'] ?? '').toString();

      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        return;
      }

      // success modal like screenshot 3
      await showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        builder: (_) => _SuccessSheet(
          onGoLogin: () {
            Navigator.pop(context); // close sheet
            Navigator.pop(
              context,
            ); // back to signup or root (replace with login route later)
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final res = await widget.authApi.resendOtp(email: widget.email);
      final msg = (res['message'] ?? '').toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AOSUi.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // icon circle
              Container(
                height: 96,
                width: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFEFF1),
                ),
                child: Center(
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: const Icon(
                      Icons.mail_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text('Verify OTP', style: AOSUi.h2(context)),
              const SizedBox(height: 10),
              Text(
                'We have to sent the code verification to',
                style: AOSUi.bodyMuted(context),
              ),
              const SizedBox(height: 6),
              Text(
                widget.email,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 22),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  // final isActive =
                  //     _nodes[i].hasFocus || _controllers[i].text.isNotEmpty;
                  return SizedBox(
                    width: 52,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _nodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AOSUi.stroke),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (v) => _onChanged(i, v),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 22),
              AOSUi.primaryButton(
                text: 'Submit',
                onPressed: _verify,
                loading: _loading,
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AOSUi.bodyMuted(context),
                  ),
                  GestureDetector(
                    onTap: _resending ? null : _resend,
                    child: Text(
                      _resending ? 'Sending...' : 'Resend',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({required this.onGoLogin});
  final VoidCallback onGoLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E8EC),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 22),

              // big green circle + check
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2ECC71).withOpacity(0.15),
                ),
                child: Center(
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2ECC71),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Text('Register Success', style: AOSUi.h2(context)),
              const SizedBox(height: 10),
              Text(
                'Congratulation! your account already created.\nPlease login to get amazing experience.',
                textAlign: TextAlign.center,
                style: AOSUi.bodyMuted(context),
              ),
              const SizedBox(height: 18),
              AOSUi.primaryButton(
                text: 'Go to Login page',
                onPressed: onGoLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
