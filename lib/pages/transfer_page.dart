import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/swift_network_background.dart';
import '../services/transfer_service.dart';
import 'transfer_transmission_page.dart';

class TransferPage extends StatefulWidget {
  final bool isLayer;

  const TransferPage({super.key, this.isLayer = false});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _recipientCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _keyCtrl = TextEditingController(); // HIDDEN
  final _bicCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankAddressCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  final List<String> _transferTypes = const [
    'MT103 Cash Transfer',
    'MT103 Single Customer Credit Transfer',
    'MT103 GPI Direct Cash Transfer',
    'MT103 GPI Semi Automantic',
    'MT103 GPI with GPI Code or UETR Code',
    'MT103 GPI Semi with UETR Code',
    'MT103 Cash Wire Transfer',
    'MT103/202 Manual Download with STP mode',
    'MT103/202 Manual Download with FTP mode',
    'MT103 GPI Manual Download with STP mode',
    'MT103 GPI Manual Download with FTP mode',
  ];

  late String _selectedTransferType = _transferTypes[0];

  bool _isProcessing = false;
  final _transferService = TransferService();

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    // Just for display
  }

  void _submitTransfer() async {
    final isLayer = widget.isLayer;
    if (_recipientCtrl.text.isEmpty || _ibanCtrl.text.isEmpty ||
        _amountCtrl.text.isEmpty || _keyCtrl.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll('.', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount')),
      );
      return;
    }

    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCard : AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: isLayer ? LayerColors.borderColor : AppColors.borderColor),
        ),
        title: Text(
          'CONFIRM TRANSFER',
          style: TextStyle(
            color: isLayer ? LayerColors.accentNeon : AppColors.accentOrange,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: $_selectedTransferType',
              style: TextStyle(
                color: isLayer ? LayerColors.accentCyan : AppColors.accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text('Recipient: ${_recipientCtrl.text}', style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 12)),
            Text('IBAN: ${_ibanCtrl.text}', style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            Text('Amount: € ${_formatNumber(amount)}',
              style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 15),
            Text('⚠️ The transfer process takes time and requires administrator approval.',
              style: TextStyle(color: isLayer ? LayerColors.accentOrange : AppColors.accentOrange, fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('CANCEL', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('SUBMIT', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontWeight: FontWeight.w700))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    // Submit to service
    final transferId = await _transferService.createTransfer(
      recipient: _recipientCtrl.text,
      iban: _ibanCtrl.text,
      bic: _bicCtrl.text,
      amount: amount,
      purpose: _purposeCtrl.text,
      securityKey: _keyCtrl.text,
      transferType: _selectedTransferType,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (transferId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransferTransmissionPage(
            transferId: transferId,
            transferType: _selectedTransferType,
            recipient: _recipientCtrl.text,
            iban: _ibanCtrl.text,
            bic: _bicCtrl.text,
            bankName: _bankNameCtrl.text,
            bankAddress: _bankAddressCtrl.text,
            amount: amount,
            purpose: _purposeCtrl.text,
            isLayer: widget.isLayer,
          ),
        ),
      );
    } else {
      _showErrorDialog('Failed to create transfer');
    }
  }

  void _showErrorDialog(String message) {
    final isLayer = widget.isLayer;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCard : AppColors.bgCard,
        title: const Text('ERROR', style: TextStyle(color: AppColors.accentRed)),
        content: Text(message, style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen))),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    final formatter = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return formatter.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;

    return Scaffold(
      backgroundColor: isLayer ? LayerColors.bgPrimary : const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        showHud: false,
        isLayer: isLayer,
        child: SafeArea(
          child: Stack(
            children: [
              // PRECISELY CENTERED TRANSFER CARD
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 50,
                      ),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: isLayer
                                ? LayerColors.bgCard.withValues(alpha: 0.94)
                                : const Color(0xFF09111D).withValues(alpha: 0.94),
                            border: Border.all(
                              color: isLayer
                                  ? LayerColors.accentNeon.withValues(alpha: 0.35)
                                  : const Color(0xFF00A8FF).withValues(alpha: 0.35),
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0x77000000),
                                blurRadius: 35,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: isLayer ? const Color(0x1500FF66) : const Color(0x1500A8FF),
                                blurRadius: 25,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NEW TRANSFER',
                                style: GoogleFonts.jetBrainsMono(
                                  color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary,
                                  fontSize: 20,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isLayer ? 'SWIFT.net Layer Wire Transfer' : 'International Wire Transfer',
                                style: GoogleFonts.jetBrainsMono(
                                  color: isLayer ? LayerColors.textMuted : AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 25),

                              _buildTransferTypeField(),
                              const SizedBox(height: 15),
                              _buildField('RECIPIENT NAME', _recipientCtrl, 'e.g. John Smith'),
                              const SizedBox(height: 15),
                              _buildField('IBAN / ACCOUNT NUMBER', _ibanCtrl, 'e.g. DE89370400440532013000'),
                              const SizedBox(height: 15),
                              _buildField('BIC / SWIFT', _bicCtrl, 'e.g. COBADEFFXXX'),
                              const SizedBox(height: 15),
                              _buildField('BANK NAME', _bankNameCtrl, 'e.g. PT. BANK CENTRAL ASIA TBK'),
                              const SizedBox(height: 15),
                              _buildField('BANK ADDRESS', _bankAddressCtrl, 'e.g. BCA KCP BOGOR JL. IR. H. DJUANDA NO. 28', maxLines: 2),
                              const SizedBox(height: 15),
                              _buildField('AMOUNT (EUR)', _amountCtrl, '0', isNumber: true),
                              const SizedBox(height: 15),
                              _buildField('PURPOSE / REFERENCE', _purposeCtrl, 'e.g. Invoice payment', maxLines: 3),
                              const SizedBox(height: 15),

                              // HIDDEN KEY INPUT
                              _buildKeyField(),
                              const SizedBox(height: 25),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isProcessing ? null : _submitTransfer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
                                    foregroundColor: isLayer ? LayerColors.bgPrimary : AppColors.bgPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  ),
                                  child: _isProcessing
                                      ? SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: isLayer ? LayerColors.bgPrimary : AppColors.bgPrimary),
                                        )
                                      : const Text('SUBMIT TRANSFER',
                                          style: TextStyle(letterSpacing: 2, fontSize: 13, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // FLOATING TOP-LEFT BACK BUTTON
              Positioned(
                top: 16,
                left: 16,
                child: _buildHeader(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferTypeField() {
    final isLayer = widget.isLayer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRANSFER TYPE',
          style: TextStyle(
            color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isLayer ? LayerColors.bgInput : AppColors.bgInput,
            border: Border.all(color: isLayer ? LayerColors.borderColor : AppColors.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTransferType,
              isExpanded: true,
              dropdownColor: isLayer ? LayerColors.bgCard : AppColors.bgCard,
              borderRadius: BorderRadius.zero,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: isLayer ? LayerColors.accentNeon : AppColors.textSecondary,
                size: 20,
              ),
              style: TextStyle(
                color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              items: _transferTypes.map((type) {
                final isSelected = type == _selectedTransferType;
                final activeColor = isLayer ? LayerColors.accentNeon : AppColors.accentGreen;
                return DropdownMenuItem<String>(
                  value: type,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? activeColor : (isLayer ? LayerColors.textMuted : AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? activeColor : (isLayer ? LayerColors.textPrimary : AppColors.textPrimary),
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedTransferType = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final isLayer = widget.isLayer;
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(4),
      hoverColor: (isLayer ? LayerColors.accentNeon : AppColors.accentBlue).withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'New Transfer',
              style: GoogleFonts.jetBrainsMono(
                color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, {bool isNumber = false, int maxLines = 1}) {
    final isLayer = widget.isLayer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: false,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: isLayer ? LayerColors.bgInput : AppColors.bgInput,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: isLayer ? LayerColors.borderColor : AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyField() {
    final isLayer = widget.isLayer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('SECURITY KEY', style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 10, letterSpacing: 1.5)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: AppColors.accentRed.withValues(alpha: 0.2)),
              child: const Text('HIDDEN', style: TextStyle(color: AppColors.accentRed, fontSize: 8, letterSpacing: 1)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _keyCtrl,
          obscureText: true,
          obscuringCharacter: '•',
          style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 13, letterSpacing: 2),
          decoration: InputDecoration(
            hintText: '•••••••••',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13, letterSpacing: 2),
            filled: true,
            fillColor: isLayer ? LayerColors.bgInput : AppColors.bgInput,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: isLayer ? LayerColors.borderColor : AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: const Icon(Icons.lock, color: AppColors.accentRed, size: 16),
          ),
        ),
        const SizedBox(height: 4),
        const Text('Characters hidden for security',
          style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontStyle: FontStyle.italic)),
      ],
    );
  }
}
