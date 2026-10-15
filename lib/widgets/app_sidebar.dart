import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../pages/account_dashboard_page.dart';
import '../pages/compliance_page.dart';
import '../pages/transfer_page.dart';

import 'package:flutter/services.dart';
import '../services/transfer_service.dart';

class AppSidebar extends StatelessWidget {
  final int activeIndex;
  final String username;
  final VoidCallback? onEdit;
  final bool isLayer;

  const AppSidebar({
    super.key,
    required this.activeIndex,
    this.username = 'Bima',
    this.onEdit,
    this.isLayer = false,
  });

  String _getInitials(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 'OP';

    // Split by spaces, underscores, dots, hyphens
    final parts = clean.split(RegExp(r'[\s_\.\-]+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'OP';

    if (parts.length == 1) {
      final single = parts[0];
      // Check camelCase capitals like DeutscheBank -> DB
      final capitals = single.replaceAll(RegExp(r'[^A-Z]'), '');
      if (capitals.length >= 2) {
        return capitals.substring(0, 2).toUpperCase();
      }
      if (single.length >= 2) {
        return single.substring(0, 2).toUpperCase();
      }
      return single.toUpperCase();
    }

    // Multiple words: Take first char of first word + first char of second word
    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    final combined = '$first$second'.trim();
    return combined.isNotEmpty ? combined.toUpperCase() : 'OP';
  }

  List<Map<String, dynamic>> get _swiftAccessItems => isLayer
      ? const [
          {'tag': ':LAY:', 'label': 'SWIFT.net Layer', 'index': 1},
        ]
      : const [
          {'tag': ':103:', 'label': 'SWIFT MT 103', 'index': 0},
        ];

  final List<Map<String, dynamic>> _systemItems = const [
    {'tag': ':XFER:', 'label': 'MT103 Transfer', 'index': 2},
    {'tag': ':AUDT:', 'label': 'Transaction History', 'index': 3},
    {'tag': ':RISK:', 'label': 'Compliance & AML', 'index': 4},
    {'tag': ':TERM:', 'label': 'Alliance Terminal', 'index': 5},
  ];

  void _navigateTo(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccountDashboardPage(dashboardType: 'MT 103')),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccountDashboardPage(dashboardType: 'LAYER')),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TransferPage(isLayer: isLayer)),
      );
    } else if (index == 3) {
      _showTransactionHistoryDialog(context);
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CompliancePage()),
      );
    } else if (index == 5) {
      _showFeatureDialog(
        context,
        'ALLIANCE GATEWAY TERMINAL',
        'SWIFT Alliance Access v7.4.2 [FIN/RSDR CORE]\n\n• Status: NODE CONNECTED (TCP 1.3 / NSP-256-GCM)\n• Gateway: 185.22.187.75:443\n• HSM Cluster: PRIMARY (ONLINE / 512-BIT QUANTUM)\n• Validation Engine: ISO 15022 / ISO 20022 READY',
      );
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    final val = (amount is num) ? amount.toDouble() : (double.tryParse(amount.toString()) ?? 0.0);
    final formatter = val.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return formatter.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  void _showTransactionHistoryDialog(BuildContext context) async {
    final accentColor = isLayer ? LayerColors.accentNeon : const Color(0xFF00FF66);
    final dialogBg = const Color(0xFF07101B).withValues(alpha: 0.96);
    final borderColor = isLayer
        ? const Color(0xFF00FF66).withValues(alpha: 0.5)
        : const Color(0xFF00A8FF).withValues(alpha: 0.5);

    final transfers = await TransferService().getAllTransfers();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 780,
          constraints: const BoxConstraints(maxHeight: 720),
          decoration: BoxDecoration(
            color: dialogBg,
            border: Border.all(color: borderColor, width: 1.2),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x88000000),
                blurRadius: 40,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: Color(0x2200A8FF),
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
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor),
                      ),
                      child: Icon(Icons.receipt_long, color: accentColor, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRANSACTION AUDIT LOG // REAL-TIME LEDGER',
                            style: GoogleFonts.jetBrainsMono(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SWIFT ALLIANCE ACCESS v7.4.2 // ${transfers.length} RECORDED ENTRIES',
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

              // BODY
              Flexible(
                child: transfers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(36),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.history_toggle_off, color: Color(0xFF475569), size: 48),
                              const SizedBox(height: 14),
                              Text(
                                'NO RECORDED TRANSACTIONS YET',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Perform a "+ NEW TRANSFER" from the dashboard to initiate and record settlement instructions.',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF475569),
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(18),
                        itemCount: transfers.length,
                        itemBuilder: (context, i) {
                          final item = transfers[i];
                          final amountStr = _formatAmount(item['amount']);
                          final status = (item['status'] ?? 'SETTLED').toString().toUpperCase();
                          final isSettled = status == 'SETTLED' || status == 'APPROVED';
                          final statusColor = isSettled ? const Color(0xFF00FF66) : const Color(0xFFFF9900);
                          final type = item['transfer_type'] ?? 'MT103 Cash Transfer';
                          final recipient = item['recipient'] ?? '-';
                          final iban = item['iban'] ?? '-';
                          final bic = item['bic'] ?? '-';
                          final bank = item['bank_name'] ?? 'Deutsche Bank Frankfurt';
                          final trn = item['trn'] ?? item['id'] ?? '-';
                          final uetr = item['uetr'] ?? '-';
                          final createdAt = item['settled_at'] ?? item['created_at'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF040B14),
                              border: Border.all(
                                color: isSettled
                                    ? const Color(0xFF00FF66).withValues(alpha: 0.3)
                                    : const Color(0xFF1E293B),
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isSettled
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00FF66).withValues(alpha: 0.05),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TOP ROW: Type, Status Badge, Timestamp
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B192C),
                                        border: Border.all(color: const Color(0xFF00A8FF).withValues(alpha: 0.5)),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        type,
                                        style: GoogleFonts.jetBrainsMono(
                                          color: const Color(0xFF00A8FF),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(isSettled ? Icons.check_circle : Icons.hourglass_top,
                                              color: statusColor, size: 11),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSettled ? 'STATUS: SETTLED // ACK 999' : 'STATUS: $status',
                                            style: GoogleFonts.jetBrainsMono(
                                              color: statusColor,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // AMOUNT HIGHLIGHT
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '€ $amountStr,00',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: const Color(0xFF00FF66),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    if (createdAt.isNotEmpty)
                                      Text(
                                        createdAt.toString().replaceAll('T', ' ').split('.').first,
                                        style: GoogleFonts.jetBrainsMono(
                                          color: const Color(0xFF64748B),
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(color: Color(0xFF1E293B), height: 1),
                                const SizedBox(height: 10),

                                // DETAILS
                                _buildHistoryRow('Beneficiary', recipient),
                                _buildHistoryRow('IBAN', iban),
                                _buildHistoryRow('BIC / SWIFT', bic),
                                _buildHistoryRow('Bank', bank),
                                _buildHistoryRow('TRN Ref', trn),
                                _buildHistoryRow('UETR', uetr),
                                if (item['purpose'] != null && item['purpose'].toString().isNotEmpty)
                                  _buildHistoryRow('Remittance', item['purpose'].toString()),

                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                        text:
                                            'SWIFT TRANSACTION RECEIPT\nTRN: $trn\nUETR: $uetr\nRecipient: $recipient\nIBAN: $iban\nBIC: $bic\nAmount: € $amountStr,00\nStatus: $status',
                                      ));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(0xFF09111D),
                                          content: Text(
                                            'Transaction receipt copied to clipboard!',
                                            style: GoogleFonts.jetBrainsMono(color: const Color(0xFF00FF66)),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 12, color: Color(0xFF94A3B8)),
                                    label: Text(
                                      '[ COPY TRN / RECEIPT ]',
                                      style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8), fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // FOOTER
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF040A12),
                  border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ALLIANCE ACCESS HSM QUANTUM ENCRYPTED',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF475569),
                        fontSize: 9.5,
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: Text(
                        '[ CLOSE AUDIT LOG ]',
                        style: GoogleFonts.jetBrainsMono(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF64748B),
                fontSize: 10.5,
              ),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Color(0xFF334155), fontSize: 10.5)),
          Expanded(
            child: SelectableText(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFCBD5E1),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String title, String content) {
    final accentColor = isLayer ? LayerColors.accentNeon : AppColors.accentBlue;
    final dialogBg = isLayer ? LayerColors.bgCardSolid : const Color(0xFF0C1626);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
        ),
        title: Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            color: accentColor,
            fontSize: 13,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFFCBD5E1),
            fontSize: 11.5,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ACKNOWLEDGE',
              style: GoogleFonts.jetBrainsMono(
                color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final textMuted = isLayer ? const Color(0xFF3B7A4E) : const Color(0xFF64748B);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: textMuted,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    final index = item['index'] as int;
    final isActive = index == activeIndex;
    final label = item['label'] as String;

    final accentColor = isLayer ? LayerColors.accentNeon : AppColors.accentBlue;
    final activeBg = isLayer
        ? const Color(0x2E00FF66)
        : const Color(0x3300A8FF);
    final activeDotColor = isLayer ? LayerColors.accentNeon : const Color(0xFF00FFCC);
    final inactiveDotColor = isLayer ? const Color(0xFF13361E) : const Color(0xFF334155);
    const activeTextColor = Colors.white;
    final inactiveTextColor = isLayer ? const Color(0xFF86E7A4) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        if (index == activeIndex) return;
        _navigateTo(context, index);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          border: isActive
              ? Border(left: BorderSide(color: accentColor, width: 3))
              : const Border(left: BorderSide(color: Colors.transparent, width: 3)),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeDotColor : inactiveDotColor,
                boxShadow: isActive
                    ? [BoxShadow(color: activeDotColor, blurRadius: 6, spreadRadius: 1)]
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11.5,
                  color: isActive ? activeTextColor : inactiveTextColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isLayer
        ? const Color(0xD9030E06)
        : const Color(0xD9060E1A);
    final borderColor = isLayer
        ? const Color(0x3300FF66)
        : const Color(0x3300A8FF);
    final accentColor = isLayer ? LayerColors.accentNeon : AppColors.accentBlue;
    final textPrimary = isLayer ? LayerColors.textPrimary : AppColors.textPrimary;
    final textMuted = isLayer ? const Color(0xFF3B7A4E) : const Color(0xFF475569);

    return Container(
      width: 235,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),

          // OPERATOR BADGE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.06),
                border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      border: Border.all(color: accentColor.withValues(alpha: 0.6)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(username),
                        style: GoogleFonts.jetBrainsMono(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: GoogleFonts.jetBrainsMono(
                            color: textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLayer ? 'OPERATOR // LAYER L1' : 'OPERATOR // SWIFT L1',
                          style: GoogleFonts.jetBrainsMono(
                            color: textMuted,
                            fontSize: 8.5,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [borderColor, borderColor.withValues(alpha: 0.1)],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SWIFT ACCESS SECTION
          _buildSectionHeader('SWIFT ACCESS CHANNELS'),
          const SizedBox(height: 2),
          ..._swiftAccessItems.map((item) => _buildMenuItem(context, item)),

          const SizedBox(height: 16),

          // SYSTEM SECTION
          _buildSectionHeader('SYSTEM PROTOCOLS'),
          const SizedBox(height: 2),
          ..._systemItems.map((item) => _buildMenuItem(context, item)),

          const Spacer(),

          // FOOTER TELEMETRY
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor)),
              color: Colors.black.withValues(alpha: 0.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GATEWAY: 127.0.0.1:5000',
                      style: GoogleFonts.jetBrainsMono(
                        color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isLayer ? 'LAYER-MESH // QUANTUM HSM' : 'v7.4.2 RSDR // CSP 2026',
                  style: GoogleFonts.jetBrainsMono(
                    color: textMuted,
                    fontSize: 8.5,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PKI: VALIDATED',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF64748B),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (onEdit != null)
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            border: Border.all(color: textMuted.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'QUICK EDIT',
                            style: GoogleFonts.jetBrainsMono(
                              color: accentColor,
                              fontSize: 8.5,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
