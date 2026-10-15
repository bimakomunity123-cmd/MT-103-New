import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/swift_network_background.dart';
import 'transfer_settlement_page.dart';

class SettlementLoadingPage extends StatefulWidget {
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

  const SettlementLoadingPage({
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
  State<SettlementLoadingPage> createState() => _SettlementLoadingPageState();
}

class _SettlementLoadingPageState extends State<SettlementLoadingPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Standard normal page transition duration (5 seconds)
    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TransferSettlementPage(
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
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    final accent = isLayer ? const Color(0xFF00FF88) : const Color(0xFF00A8FF);

    return Scaffold(
      backgroundColor: const Color(0xFF040810),
      body: SwiftNetworkBackground(
        showHud: false,
        isLayer: isLayer,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                    backgroundColor: const Color(0xFF0E1A2E),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading...',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFF1F5F9),
                    fontSize: 14,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please wait a moment',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
