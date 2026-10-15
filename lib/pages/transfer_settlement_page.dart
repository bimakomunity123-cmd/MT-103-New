import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/swift_network_background.dart';
import 'swift_gateway_loading_page.dart';

class TransferSettlementPage extends StatefulWidget {
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

  const TransferSettlementPage({
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
  State<TransferSettlementPage> createState() => _TransferSettlementPageState();
}

class _TransferSettlementPageState extends State<TransferSettlementPage> {
  Timer? _fastTimer;
  double _progress = 0.6134;
  bool _isAccelerated = false;

  @override
  void initState() {
    super.initState();
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
    _fastTimer?.cancel();
    super.dispose();
  }

  String _formatNumber(double value) {
    final formatter = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return formatter.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _showCompletionDetails() {
    final amountFormatted = _formatNumber(widget.amount);
    final now = DateTime.now();
    final timestamp =
        '${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)} UTC';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: 760,
            constraints: const BoxConstraints(maxHeight: 720),
            decoration: BoxDecoration(
              color: const Color(0xFF07101B).withValues(alpha: 0.96),
              border: Border.all(color: const Color(0xFF00FF66).withValues(alpha: 0.6), width: 1.2),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: Color(0x2200FF66),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF040A12),
                    border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0x2200FF66),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00FF66)),
                        ),
                        child: const Icon(Icons.check, color: Color(0xFF00FF66), size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SWIFT ALLIANCE DOCCUMENT FILE LOCKED',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF00FF66),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'STATUS: SETTLED & DELIVERED // ACK 999',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF94A3B8),
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 18),
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // BODY SCROLLABLE
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AMOUNT HIGHLIGHT CARD (LOCKED / ABU-ABU)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF03070E),
                            border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_outline, size: 12, color: Color(0xFF64748B)),
                                      const SizedBox(width: 5),
                                      Text(
                                        'SETTLED AMOUNT (LOCKED)',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: const Color(0xFF64748B),
                                          fontSize: 10,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '€ $amountFormatted,00',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: const Color(0xFF94A3B8), // Warna abu-abu (terkunci)
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(2),
                                          border: Border.all(color: const Color(0xFF334155), width: 0.8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.lock, size: 10, color: Color(0xFF94A3B8)),
                                            const SizedBox(width: 3),
                                            Text(
                                              'LOCKED',
                                              style: GoogleFonts.jetBrainsMono(
                                                color: const Color(0xFF94A3B8),
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0x2200FF66),
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(color: const Color(0xFF00FF66).withValues(alpha: 0.6)),
                                    ),
                                    child: Text(
                                      '100.00% COMPLETED',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: const Color(0xFF00FF66),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timestamp,
                                    style: GoogleFonts.jetBrainsMono(
                                      color: const Color(0xFF64748B),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TRANSACTION DETAILS GRID
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF050C15),
                            border: Border.all(color: const Color(0xFF1E293B)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '// TRANSACTION DETAILS & BENEFICIARY',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF00A8FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildDetailRow('Transfer Type', widget.transferType),
                              _buildDetailRow('Beneficiary', widget.recipient),
                              _buildDetailRow('IBAN / Account', widget.iban),
                              _buildDetailRow('BIC / SWIFT', widget.bic),
                              _buildDetailRow('TRN Ref', widget.trn),
                              _buildDetailRow('UETR Tracking', widget.uetr),
                              if (widget.purpose.isNotEmpty)
                                _buildDetailRow('Remittance Info', widget.purpose),
                              _buildDetailRow('Security Protocol', 'HSM 512-BIT QUANTUM SIGNED // OK'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // SETTLEMENT AUDIT TIMELINE
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF050C15),
                            border: Border.all(color: const Color(0xFF1E293B)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '// CLEARING & SETTLEMENT AUDIT TRAIL',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF00FF66),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildTimelineStep('1. Payment instruction payload generated & encrypted', true),
                              _buildTimelineStep('2. Alliance Access HSM Quantum Key signature verified', true),
                              _buildTimelineStep('3. Liquidity reservation & debit ledger booked', true),
                              _buildTimelineStep('4. Interbank Network Handshake & ACK-999 delivered', true),
                              _buildTimelineStep('5. Final Settlement 100.00% completed & cleared', true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // FOOTER ACTIONS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF040A12),
                    border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text:
                                'SWIFT ALLIANCE DOCCUMENT FILE LOCKED\nTRN: ${widget.trn}\nUETR: ${widget.uetr}\nRecipient: ${widget.recipient}\nIBAN: ${widget.iban}\nBIC: ${widget.bic}\nAmount: € $amountFormatted,00\nStatus: SETTLED (100%)\nTimestamp: $timestamp',
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF09111D),
                              content: Text(
                                'Receipt copied to clipboard!',
                                style: GoogleFonts.jetBrainsMono(color: const Color(0xFF00FF66)),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14, color: Color(0xFF94A3B8)),
                        label: Text(
                          '[ COPY RECEIPT ]',
                          style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1E13),
                          side: const BorderSide(color: Color(0xFF00FF66), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shadowColor: const Color(0xFF00FF66).withValues(alpha: 0.3),
                          elevation: 3,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SwiftGatewayLoadingPage(
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.send_rounded, size: 13, color: Color(0xFF00FF66)),
                            const SizedBox(width: 6),
                            Text(
                              '[ SUBMIT ]',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF00FF66),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Color(0xFF334155), fontSize: 11)),
          Expanded(
            child: SelectableText(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFCBD5E1),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String text, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF00FF66), size: 13),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF94A3B8),
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentStr = (_progress * 100).toStringAsFixed(2);
    final isComplete = _progress >= 1.0;
    final isLayer = widget.isLayer;

    return Scaffold(
      backgroundColor: isLayer ? const Color(0xFF020904) : const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        showHud: true,
        isLayer: isLayer,
        onBottomLeftTap: _accelerate,
        child: SafeArea(
          child: Stack(
            children: [
              // Back button to return to dashboard
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 20),
                  tooltip: 'Return to Dashboard',
                ),
              ),

              // ONLY THE GLOWING LOADING PROGRESS BAR IN CYBER CARD
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 850),
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF09111D).withValues(alpha: 0.92),
                      border: Border.all(color: const Color(0xFF00FF66).withValues(alpha: 0.35)),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x77000000),
                          blurRadius: 35,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: Color(0x1500FF66),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // CENTERED TITLE ABOVE LOADING BAR
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00FF66),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FF66).withValues(alpha: 0.9),
                                      blurRadius: 6,
                                      spreadRadius: 1.5,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TRANSACTION PROCESSING BANK : $percentStr%',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF00FF66),
                                  fontSize: 13,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // GLOWING PROGRESS BAR
                        Container(
                          height: 10,
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020705),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: const Color(0xFF1B3D2B), width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3300FF66),
                                blurRadius: 6,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final targetWidth = _progress > 0
                                  ? (constraints.maxWidth * _progress).clamp(4.0, constraints.maxWidth)
                                  : 0.0;
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: targetWidth,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00DD77),
                                        Color(0xFF00FF66),
                                        Color(0xFF55FFAA),
                                      ],
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF00FF66),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: Color(0x6600FF88),
                                        blurRadius: 18,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // COMPLETION STATUS (WHEN 100%) - CLICKABLE
                        if (isComplete) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: _showCompletionDetails,
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0x2200FF66),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFF00FF66).withValues(alpha: 0.9),
                                      width: 1.2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x3300FF66),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, color: Color(0xFF00FF66), size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        'TRANSACTION COMPLETE',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: const Color(0xFF00FF66),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.open_in_new, color: Color(0xFF00FF66), size: 12),
                                    ],
                                  ),
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

              // SPEED UP BUTTON (BOTTOM LEFT - FAINT / SAMAR AS IN IMAGE 2)
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
            widget.isAccelerated ? '[ >> ACCELERATING... ]' : '[ >> ACCELERATE PROCESS ]',
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
