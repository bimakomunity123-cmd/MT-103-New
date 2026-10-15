import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/transfer_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _transferService = TransferService();
  List<Map<String, dynamic>> _transfers = [];
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    final transfers = await _transferService.getAllTransfers();
    if (!mounted) return;
    setState(() {
      _transfers = transfers;
      _pendingCount = transfers.where((t) => t['status'] == 'PENDING').length;
      _approvedCount = transfers.where((t) => t['status'] == 'APPROVED').length;
      _rejectedCount = transfers.where((t) => t['status'] == 'REJECTED').length;
    });
  }

  Future<void> _approve(Map<String, dynamic> transfer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderColor),
        ),
        title: const Text('APPROVE TRANSFER', style: TextStyle(color: AppColors.accentGreen, letterSpacing: 1.5)),
        content: Text('Approve transfer ${transfer['id']}?\n\nFunds will be debited from the sender account after 3 business days.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('APPROVE', style: TextStyle(color: AppColors.accentGreen))),
        ],
      ),
    );

    if (confirm == true) {
      await _transferService.approveTransfer(transfer['id']);
      await _loadTransfers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer approved'), backgroundColor: AppColors.accentGreen),
      );
    }
  }

  Future<void> _reject(Map<String, dynamic> transfer) async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderColor),
        ),
        title: const Text('REJECT TRANSFER', style: TextStyle(color: AppColors.accentRed, letterSpacing: 1.5)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject transfer ${transfer['id']}?',
              style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 15),
            TextField(
              controller: reasonCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g. Insufficient funds in sender account',
                hintStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('REJECT', style: TextStyle(color: AppColors.accentRed))),
        ],
      ),
    );

    if (confirm == true) {
      final reason = reasonCtrl.text.isEmpty ? 'No reason provided' : reasonCtrl.text;
      await _transferService.rejectTransfer(transfer['id'], reason);
      await _loadTransfers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer rejected'), backgroundColor: AppColors.accentRed),
      );
    }
  }

  String _formatCurrency(double value) {
    final formatter = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '€ ${formatter.replaceAllMapped(reg, (m) => '${m[1]}.')},00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStats(),
                    const SizedBox(height: 25),
                    const Text('PENDING APPROVALS',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 15),
                    _buildTransferList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppColors.accentOrange),
                child: const Center(child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 18)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('ADMIN PANEL',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  Text('Transfer Approval System', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (_pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(color: AppColors.accentRed),
                  child: Text('$_pendingCount PENDING',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              IconButton(
                onPressed: _loadTransfers,
                icon: const Icon(Icons.refresh, color: AppColors.accentBlue, size: 18),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  side: const BorderSide(color: AppColors.accentRed),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('EXIT', style: TextStyle(fontSize: 10, letterSpacing: 1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, c) {
        int cols = c.maxWidth > 700 ? 3 : 1;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: cols == 3 ? 2.5 : 3,
          children: [
            _statCard('PENDING', _pendingCount.toString(), AppColors.accentOrange, Icons.schedule),
            _statCard('APPROVED', _approvedCount.toString(), AppColors.accentGreen, Icons.check_circle),
            _statCard('REJECTED', _rejectedCount.toString(), AppColors.accentRed, Icons.cancel),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 5),
              Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferList() {
    if (_transfers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.borderColor),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox, color: AppColors.textMuted, size: 48),
            SizedBox(height: 10),
            Text('No transfers yet', style: TextStyle(color: AppColors.textMuted)),
            SizedBox(height: 5),
            Text('Create a transfer from user dashboard for testing',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      );
    }

    // Sort: PENDING first, then by date
    final sorted = List<Map<String, dynamic>>.from(_transfers);
    sorted.sort((a, b) {
      if (a['status'] == 'PENDING' && b['status'] != 'PENDING') return -1;
      if (a['status'] != 'PENDING' && b['status'] == 'PENDING') return 1;
      return (b['created_at'] ?? '').compareTo(a['created_at'] ?? '');
    });

    return Column(
      children: sorted.map((t) => _buildTransferCard(t)).toList(),
    );
  }

  Widget _buildTransferCard(Map<String, dynamic> t) {
    Color statusColor;
    IconData statusIcon;
    switch (t['status']) {
      case 'PENDING':
        statusColor = AppColors.accentOrange;
        statusIcon = Icons.schedule;
        break;
      case 'APPROVED':
        statusColor = AppColors.accentGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
        statusColor = AppColors.accentRed;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  Text(t['id'].toString(),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(t['status'].toString(),
                      style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                ],
              ),
              Text(_formatCurrency((t['amount'] ?? 0).toDouble()),
                style: const TextStyle(color: AppColors.accentGreen, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 15),
          _detailRow('Recipient', t['recipient']?.toString() ?? '-'),
          _detailRow('IBAN', t['iban']?.toString() ?? '-'),
          if (t['bic']?.toString().isNotEmpty ?? false) _detailRow('BIC', t['bic'].toString()),
          if (t['purpose']?.toString().isNotEmpty ?? false) _detailRow('Purpose', t['purpose'].toString()),
          const Divider(color: AppColors.borderColor, height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created: ${_formatDate(t['created_at'])}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  Text('Est. Complete: ${_formatDate(t['est_completion'])}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
              if (t['status'] == 'PENDING')
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _reject(t),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentRed,
                        side: const BorderSide(color: AppColors.accentRed),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: const Text('REJECT', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _approve(t),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: AppColors.bgPrimary,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: const Text('APPROVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                )
              else if (t['status'] == 'REJECTED' && t['rejection_reason'] != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.1),
                    border: Border.all(color: AppColors.accentRed.withOpacity(0.3)),
                  ),
                  child: Text('Reason: ${t['rejection_reason']}',
                    style: const TextStyle(color: AppColors.accentRed, fontSize: 10)),
                )
              else if (t['status'] == 'APPROVED' && t['approved_at'] != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.1),
                    border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                  ),
                  child: Text('Approved: ${_formatDate(t['approved_at'])}',
                    style: const TextStyle(color: AppColors.accentGreen, fontSize: 10)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return dateStr.toString();
    }
  }
}
