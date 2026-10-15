import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/swift_network_background.dart';
import '../services/transfer_service.dart';
import 'account_dashboard_page.dart';
import 'swift_error_page.dart';

class SwiftGatewayLoadingPage extends StatefulWidget {
  final String transferId;
  final String transferType;
  final String recipient;
  final String iban;
  final String bic;
  final String bankName;
  final String bankAddress;
  final double amount;
  final String purpose;
  final String trn;
  final String uetr;
  final bool isLayer;

  const SwiftGatewayLoadingPage({
    super.key,
    required this.transferId,
    required this.transferType,
    required this.recipient,
    required this.iban,
    required this.bic,
    this.bankName = '',
    this.bankAddress = '',
    required this.amount,
    this.purpose = '',
    required this.trn,
    required this.uetr,
    this.isLayer = false,
  });

  @override
  State<SwiftGatewayLoadingPage> createState() =>
      _SwiftGatewayLoadingPageState();
}

class _SwiftGatewayLoadingPageState extends State<SwiftGatewayLoadingPage> {
  late DateTime _startTime;
  static const Duration _totalDuration = Duration(hours: 5); // Estimasi 5 Jam
  Timer? _ticker;
  Timer? _fastTimer;
  double _progress = 0.0;
  bool _isAccelerated = false;
  final _transferService = TransferService();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _updateProgress();
    _settleTransfer();

    // Live update across 5 hours duration
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isAccelerated) {
        _updateProgress();
      }
    });
  }

  Future<void> _settleTransfer() async {
    await _transferService.completeAndSettleTransfer(
      transferId: widget.transferId,
      transferType: widget.transferType,
      recipient: widget.recipient,
      iban: widget.iban,
      bic: widget.bic,
      bankName: widget.bankName,
      bankAddress: widget.bankAddress,
      amount: widget.amount,
      purpose: widget.purpose,
      trn: widget.trn,
      uetr: widget.uetr,
    );
  }

  void _updateProgress() {
    final now = DateTime.now();
    final elapsedMs = now.difference(_startTime).inMilliseconds;
    final totalMs = _totalDuration.inMilliseconds;

    setState(() {
      _progress = (elapsedMs / totalMs).clamp(0.0, 1.0);
    });
  }

  void _accelerate() {
    if (_progress >= 1.0) return;

    setState(() {
      _isAccelerated = true;
      // Instant bump feedback on each click (+6%)
      _progress = (_progress + 0.06).clamp(0.0, 1.0);
    });

    // Start fast timer if not already running
    if (_fastTimer == null || !_fastTimer!.isActive) {
      _ticker?.cancel();
      _fastTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_progress >= 1.0) {
          timer.cancel();
          setState(() {
            _progress = 1.0;
          });
          return;
        }
        setState(() {
          _progress = (_progress + 0.0035).clamp(0.0, 1.0);
        });
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _fastTimer?.cancel();
    super.dispose();
  }

  String _formatRemainingTime() {
    final remainingMs = (_totalDuration.inMilliseconds * (1.0 - _progress))
        .toInt()
        .clamp(0, _totalDuration.inMilliseconds);
    final remainingDuration = Duration(milliseconds: remainingMs);
    final hours = remainingDuration.inHours;
    final minutes = remainingDuration.inMinutes % 60;
    final seconds = remainingDuration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    final accent = isLayer ? const Color(0xFF00FF66) : AppColors.accentGreen;
    final cardBg = const Color(0xFF09111D).withValues(alpha: 0.92);
    final borderColor = const Color(0xFF00A8FF).withValues(alpha: 0.35);
    const inputBg = Color(0xFF050B14);

    final percentVal = (_progress * 100);
    final percentStr = percentVal < 1.0 && percentVal > 0
        ? percentVal.toStringAsFixed(1)
        : percentVal.toStringAsFixed(0);
    final isComplete = _progress >= 1.0;

    return Scaffold(
      backgroundColor:
          isLayer ? const Color(0xFF020904) : const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        showHud: true,
        isLayer: isLayer,
        onBottomLeftTap: _accelerate,
        child: SafeArea(
          child: Stack(
            children: [
              // Back / Dashboard button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountDashboardPage(
                          dashboardType: widget.isLayer ? 'LAYER' : 'MT 103',
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back,
                      color: Color(0xFF64748B), size: 20),
                  tooltip: 'Return to Dashboard',
                ),
              ),

              // Centered Loading Card (Matching Image 2)
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Container(
                    width: 520,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 32),
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
                          color:
                              const Color(0xFF00A8FF).withValues(alpha: 0.15),
                          blurRadius: 25,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Indicator: Spinning indicator with glow when loading, Checkmark when complete
                        if (isComplete)
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0x2200FF66),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF00FF66), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x5500FF66),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF00FF66),
                              size: 34,
                            ),
                          )
                        else
                          Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(4),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              backgroundColor: inputBg,
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        const SizedBox(height: 25),

                        // Title
                        Text(
                          isComplete
                              ? 'TRANSACTION BROADCAST COMPLETED'
                              : (isLayer
                                  ? 'CONNECTING TO LAYER SECURE TUNNEL'
                                  : 'CONNECTING TO SECURE SERVER'),
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),

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
                              value: _progress,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Progress percentage
                        Text(
                          '$percentStr%',
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

                        // Subtitle
                        Text(
                          isComplete
                              ? 'SWIFT Alliance Gateway Transaction Settled // ACK 999'
                              : (isLayer
                                  ? 'Establishing Layer Quantum Mesh...'
                                  : 'Connecting to SWIFT Alliance Gateway...'),
                          style: GoogleFonts.jetBrainsMono(
                            color: isComplete
                                ? const Color(0xFF00FF66)
                                : const Color(0xFF64748B),
                            fontSize: 10.5,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // ESTIMATED TIME (5 JAM) BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: inputBg,
                            border: Border.all(color: const Color(0xFF1E293B)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  isComplete
                                      ? Icons.check_circle_outline
                                      : Icons.schedule,
                                  size: 13,
                                  color: accent),
                              const SizedBox(width: 6),
                              Text(
                                isComplete
                                    ? 'DURATION: 5 HOURS'
                                    : 'ESTIMATED: 5 HOURS',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '//',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF334155),
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isComplete
                                    ? 'STATUS: COMPLETED'
                                    : 'ETA: ${_formatRemainingTime()}',
                                style: GoogleFonts.jetBrainsMono(
                                  color: accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Loading steps container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: inputBg,
                            border: Border.all(color: const Color(0xFF1E293B)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Column(
                            children: [
                              _LoadingStep(
                                status: _progress > 0.15 ? '✓' : '...',
                                text: 'Authentication verified',
                                done: _progress > 0.15,
                              ),
                              _LoadingStep(
                                status: _progress > 0.45 ? '✓' : '...',
                                text: 'Loading account data',
                                done: _progress > 0.45,
                              ),
                              _LoadingStep(
                                status: _progress > 0.70 ? '✓' : '...',
                                text: 'Establishing secure connection',
                                done: _progress > 0.70,
                              ),
                              _LoadingStep(
                                status: _progress > 0.90 ? '✓' : '...',
                                text: 'Verifying balance and limits',
                                done: _progress > 0.90,
                              ),
                            ],
                          ),
                        ),

                        // Completed Action
                        if (isComplete) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x2200FF66),
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: const Color(0xFF00FF66)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF00FF66), size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  'SUBMISSION COMPLETE & BROADCASTED',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFF00FF66),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.45),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: const Color(0xFF000000),
                                side: BorderSide(
                                  color: isLayer
                                      ? const Color(0xFF88FFB0)
                                      : const Color(0xFF66E5FF),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 15),
                                elevation: 6,
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SwiftErrorPage(
                                      transferId: widget.transferId,
                                      transferType: widget.transferType,
                                      recipient: widget.recipient,
                                      iban: widget.iban,
                                      bic: widget.bic,
                                      bankName: widget.bankName,
                                      bankAddress: widget.bankAddress,
                                      amount: widget.amount,
                                      purpose: widget.purpose,
                                      trn: widget.trn,
                                      uetr: widget.uetr,
                                      isLayer: widget.isLayer,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.send_rounded,
                                  size: 16, color: Color(0xFF000000)),
                              label: Text(
                                '[ SUBMIT TRANSACTION ]',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF000000),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // SPEED UP BUTTON (BOTTOM LEFT - FAINT / SAMAR)
              Positioned(
                bottom: 42,
                left: 24,
                child: _FaintAccelerateButton(
                  onTap: _accelerate,
                  isAccelerated: _isAccelerated,
                ),
              ),
            ],
          ),
        ),
      ),
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

// ============ FAINT ACCELERATE BUTTON ============
class _FaintAccelerateButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isAccelerated;

  const _FaintAccelerateButton({
    required this.onTap,
    required this.isAccelerated,
  });

  @override
  State<_FaintAccelerateButton> createState() => _FaintAccelerateButtonState();
}

class _FaintAccelerateButtonState extends State<_FaintAccelerateButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const normalColor = Color(0xFF334155);
    const hoverColor = Color(0xFF64748B);
    final activeColor = const Color(0xFF00FF66).withValues(alpha: 0.6);

    final currentColor = widget.isAccelerated
        ? (_isHovered ? const Color(0xFF00FF66) : activeColor)
        : (_isHovered ? hoverColor : normalColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF050B14).withValues(alpha: 0.7),
            border: Border.all(
              color: currentColor.withValues(alpha: _isHovered ? 0.6 : 0.3),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            widget.isAccelerated
                ? '[ >> ACCELERATING... ]'
                : '[ >> ACCELERATE PROCESS ]',
            style: GoogleFonts.jetBrainsMono(
              color: currentColor,
              fontSize: 9.5,
              letterSpacing: 1,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
