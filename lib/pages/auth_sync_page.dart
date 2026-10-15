import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/swift_network_background.dart';
import '../widgets/deutsche_bank_logo.dart';
import 'account_dashboard_page.dart';

class AuthSyncPage extends StatefulWidget {
  final String dashboardType;

  const AuthSyncPage({
    super.key,
    this.dashboardType = 'MT 103',
  });

  @override
  State<AuthSyncPage> createState() => _AuthSyncPageState();
}

class _AuthSyncPageState extends State<AuthSyncPage> {
  static const int totalSeconds = 300; // 5 menit = 300 detik
  int _remainingSeconds = totalSeconds;
  Timer? _timer;
  final List<String> _logs = [];

  final List<Map<String, dynamic>> _scheduledLogs = [
    {'time': 299, 'msg': '[SYSTEM] SWIFT Alliance Gateway initialization started...'},
    {'time': 296, 'msg': '[AUTH] Validating credentials against Deutsche Bank Frankfurt Core HSM...'},
    {'time': 290, 'msg': '[CRYPTO] Establishing 4096-bit RSA TLS Session Key Handshake...'},
    {'time': 280, 'msg': '[NODE] Linked to Alliance Access Node: DB-FRA-GW-09 (Port 8443)'},
    {'time': 265, 'msg': '[SAFRA] Executing Safra & RSDR Compliance Protocol Integrity Check...'},
    {'time': 240, 'msg': '[TELEMETRY] Latency: 1.2ms | Packet Loss: 0.00% | Cipher: AES-256-GCM'},
    {'time': 210, 'msg': '[QUORUM] Awaiting Multi-Signature Security Token Quorum clearance...'},
    {'time': 180, 'msg': '[BALANCE] Pre-caching Liquidity Ledger & MT103 Settlement Pipeline...'},
    {'time': 120, 'msg': '[SYNCHRONIZING] Finalizing Hardware Security Module (HSM-v4) sync...'},
    {'time': 60, 'msg': '[VERIFIED] Alliance Access Token Authorized. Preparing Secure Dashboard...'},
    {'time': 5, 'msg': '[CONNECT] Establishing final encrypted bridge to Terminal session...'},
  ];

  @override
  void initState() {
    super.initState();
    _logs.add('[SYSTEM] SWIFT Alliance Gateway initialization started...');
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          // Check for new logs
          for (var item in _scheduledLogs) {
            if (item['time'] == _remainingSeconds && !_logs.contains(item['msg'])) {
              _logs.insert(0, item['msg']);
            }
          }
        } else {
          _timer?.cancel();
          _proceedToDashboard();
        }
      });
    });
  }

  void _proceedToDashboard() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AccountDashboardPage(dashboardType: widget.dashboardType),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (totalSeconds - _remainingSeconds) / totalSeconds;
    final isLayer = widget.dashboardType == 'LAYER';
    final accentColor = isLayer ? const Color(0xFFFF3366) : const Color(0xFF00A8FF);

    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Container(
              width: 680,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: const Color(0xFF060D18).withValues(alpha: 0.95),
                border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          'Deutsche Bank',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const DeutscheBankEmblem(
                        size: 46,
                        color: Color(0xFF0055FF),
                        hasGlow: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF04180F),
                      border: Border.all(color: const Color(0xFF00FF66).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00FF66),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0xFF00FF66), blurRadius: 4, spreadRadius: 1),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SWIFT ALLIANCE ACCESS - SYNCHRONIZATION',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: const Color(0xFF00FF66),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Big Countdown Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF040810),
                      border: Border.all(color: const Color(0xFF1E293B)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SESSION INITIALIZATION COUNTDOWN',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: accentColor.withValues(alpha: 0.6),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AUTHENTICATING ${widget.dashboardType} GATEWAY (5 MINUTES DURATION)',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF0F172A),
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '00:00 (START)',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF475569)),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}%',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '05:00 (TARGET)',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terminal Live Stream Box
                  Container(
                    width: double.infinity,
                    height: 120,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF02050A),
                      border: Border.all(color: const Color(0xFF1E293B)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: index == 0 ? const Color(0xFF00FF66) : const Color(0xFF64748B),
                              fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HOST: db-swift.dt.com // NODE-EU-09',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      InkWell(
                        onTap: _proceedToDashboard,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1626),
                            border: Border.all(color: accentColor.withValues(alpha: 0.6)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bolt, size: 14, color: accentColor),
                              const SizedBox(width: 6),
                              Text(
                                '[ BYPASS / DIRECT CONNECT ]',
                                style: GoogleFonts.jetBrainsMono(
                                  color: accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
