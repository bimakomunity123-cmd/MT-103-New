import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/info_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/balance_section.dart';
import '../widgets/swift_network_background.dart';
import '../widgets/deutsche_bank_logo.dart';
import '../services/session_service.dart';
import '../services/api_service.dart';
import '../services/transfer_service.dart';
import 'welcome_login_page.dart';
import 'transfer_page.dart';

class AccountDashboardPage extends StatefulWidget {
  final String dashboardType;

  const AccountDashboardPage({
    super.key,
    this.dashboardType = 'MT 103',
  });

  @override
  State<AccountDashboardPage> createState() => _AccountDashboardPageState();
}

class _AccountDashboardPageState extends State<AccountDashboardPage>
    with SingleTickerProviderStateMixin {
  final _session = SessionService();
  final _transferService = TransferService();
  String _username = 'DeutscheBank_Betty_Bima';
  String _headerBankName = 'Bank BRI';
  String _headerSubtitle = '';
  bool _isLoading = true;
  static const _loadingDuration = Duration(minutes: 3);
  late AnimationController _loadingController;

  // Dynamic data - DEFAULT KOSONG
  Map<String, String> _accountData = {
    'account_holder': '',
    'account_number': '',
    'iban': '',
    'bic': '',
    'bank': '',
    'branch': '',
    'reg_no': '',
    'vat_id': '',
  };

  // Balance - DEFAULT KOSONG (0)
  double _balance = 0;
  double _availableBalance = 0;
  double _blockedBalance = 0;
  double _dailyLimit = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadingController = AnimationController(
      duration: _loadingDuration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isLoading = false);
          _loadData();
        }
      });
    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await _session.getUsername();
    if (user != null && mounted) {
      setState(() => _username = user);
    }

    // Load from local storage (TransferService)
    final balances = await _transferService.getBalances();
    final accInfo = await _transferService.getAccountInfo();

    if (mounted) {
      setState(() {
        if (balances['balance'] != null && balances['balance']! > 0) {
          _balance = balances['balance']!;
        }
        if (balances['available'] != null && balances['available']! > 0) {
          _availableBalance = balances['available']!;
        }
        if (balances['blocked'] != null && balances['blocked']! > 0) {
          _blockedBalance = balances['blocked']!;
        }
        if (balances['limit'] != null && balances['limit']! > 0) {
          _dailyLimit = balances['limit']!;
        }

        if (accInfo.isNotEmpty) {
          accInfo.forEach((k, v) {
            if (v.isNotEmpty) {
              _accountData[k] = v;
            }
          });
        }
      });
    }

    final online = await ApiService.checkConnection();
    if (!mounted) return;

    // Backend load (optional - kalo ada)
    if (online) {
      try {
        final acc = await ApiService.getAccountInfo(_username);
        if (acc['success'] == true && acc['data'] != null && mounted) {
          setState(() {
            final data = acc['data'] as Map;
            if (data['account_holder'] != null && data['account_holder'].toString().isNotEmpty) _accountData['account_holder'] = data['account_holder'].toString();
            if (data['account_number'] != null && data['account_number'].toString().isNotEmpty) _accountData['account_number'] = data['account_number'].toString();
            if (data['iban'] != null && data['iban'].toString().isNotEmpty) _accountData['iban'] = data['iban'].toString();
            if (data['bic'] != null && data['bic'].toString().isNotEmpty) _accountData['bic'] = data['bic'].toString();
            if (data['bank'] != null && data['bank'].toString().isNotEmpty) _accountData['bank'] = data['bank'].toString();
            if (data['branch'] != null && data['branch'].toString().isNotEmpty) _accountData['branch'] = data['branch'].toString();
            if (data['reg_no'] != null && data['reg_no'].toString().isNotEmpty) _accountData['reg_no'] = data['reg_no'].toString();
            if (data['vat_id'] != null && data['vat_id'].toString().isNotEmpty) _accountData['vat_id'] = data['vat_id'].toString();
            if (data['balance_eur'] != null) _balance = (data['balance_eur']).toDouble();
            if (data['available_eur'] != null) _availableBalance = (data['available_eur']).toDouble();
            if (data['blocked_eur'] != null) _blockedBalance = (data['blocked_eur']).toDouble();
            if (data['daily_limit_eur'] != null) _dailyLimit = (data['daily_limit_eur']).toDouble();
          });
        }
      } catch (e) {
        // silent
      }
    }
  }

  void _updateAccountRow(int index, String value) {
    final keys = _accountData.keys.toList();
    if (index < keys.length) {
      setState(() {
        _accountData[keys[index]] = value;
      });
      _transferService.saveAccountInfo(_accountData);
    }
  }

  void _editAllAccountInfo() async {
    final isLayer = widget.dashboardType == 'LAYER';
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _EditAccountInfoDialog(data: _accountData, isLayer: isLayer),
    );

    if (result != null) {
      setState(() {
        _accountData = result;
      });
      _transferService.saveAccountInfo(result);
    }
  }

  void _showQuickEditMenu() {
    final isLayer = widget.dashboardType == 'LAYER';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCardSolid : AppColors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderColor),
        ),
        title: Row(
          children: [
            Icon(Icons.tune, color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              'QUICK EDIT MENU',
              style: TextStyle(
                color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue,
                fontSize: 13,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Bank Header
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.account_balance, color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue, size: 20),
                  title: Text('Edit Bank Header', style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle: Text('Bank name: "$_headerBankName"', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10)),
                  trailing: Icon(Icons.chevron_right, color: isLayer ? LayerColors.textMuted : AppColors.textMuted, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _editHeaderBankDialog();
                  },
                ),
                Divider(color: isLayer ? LayerColors.borderColor : AppColors.borderColor, height: 1),

                // 2. Account Information
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.badge_outlined, color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue, size: 20),
                  title: Text('Edit Account Information', style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle: Text('Holder, IBAN, BIC, Bank, Branch, Reg No, VAT ID', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10)),
                  trailing: Icon(Icons.chevron_right, color: isLayer ? LayerColors.textMuted : AppColors.textMuted, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _editAllAccountInfo();
                  },
                ),
                Divider(color: isLayer ? LayerColors.borderColor : AppColors.borderColor, height: 1),

                // 3. Edit All Balances (All In One)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.monetization_on_outlined, color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, size: 20),
                  title: Text('Edit All Balances & Limits (All-in-One)', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                  subtitle: Text('Quickly edit Total, Available, Blocked & Limit together', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10)),
                  trailing: Icon(Icons.chevron_right, color: isLayer ? LayerColors.textMuted : AppColors.textMuted, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _editAllBalancesDialog();
                  },
                ),
                Divider(color: isLayer ? LayerColors.borderColor : AppColors.borderColor, height: 1),

                // 4. Edit Total Settled Balance
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.account_balance_wallet_outlined, color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, size: 20),
                  title: Text('Edit Total Balance', style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 12)),
                  subtitle: Text('Current: ${_formatCurrency(_balance)}', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10)),
                  trailing: Icon(Icons.chevron_right, color: isLayer ? LayerColors.textMuted : AppColors.textMuted, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _editBalanceDialog();
                  },
                ),
                Divider(color: isLayer ? LayerColors.borderColor : AppColors.borderColor, height: 1),

                // 5. Edit Available Balance
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle_outline, color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, size: 20),
                  title: Text('Edit Available Balance', style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 12)),
                  subtitle: Text('Current: ${_formatCurrency(_availableBalance)}', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10)),
                  trailing: Icon(Icons.chevron_right, color: isLayer ? LayerColors.textMuted : AppColors.textMuted, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _editStatCard('available');
                  },
                ),
                Divider(color: isLayer ? LayerColors.borderColor : AppColors.borderColor, height: 1),

                // 6. Edit Blocked / Pending
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.hourglass_empty, color: isLayer ? LayerColors.accentOrange : AppColors.accentOrange, size: 20),
                  title: Text('Edit Blocked / Pending', style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 12)),
                  subtitle: Text('Current: ${_formatCurrency(_blockedBalance)}', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10)),
                  trailing: Icon(Icons.chevron_right, color: isLayer ? LayerColors.textMuted : AppColors.textMuted, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _editStatCard('blocked');
                  },
                ),
                Divider(color: isLayer ? LayerColors.borderColor : AppColors.borderColor, height: 1),

                // 7. Edit Daily Limit
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.speed, color: isLayer ? LayerColors.accentCyan : AppColors.accentBlue, size: 20),
                  title: Text('Edit Daily Transfer Limit', style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 12)),
                  subtitle: Text('Current: ${_formatCurrency(_dailyLimit)}', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10)),
                  trailing: Icon(Icons.chevron_right, color: isLayer ? LayerColors.textMuted : AppColors.textMuted, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _editStatCard('limit');
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  void _editAllBalancesDialog() async {
    final isLayer = widget.dashboardType == 'LAYER';
    final totalCtrl = TextEditingController(text: _balance > 0 ? _balance.toStringAsFixed(0) : '');
    final availCtrl = TextEditingController(text: _availableBalance > 0 ? _availableBalance.toStringAsFixed(0) : '');
    final blockCtrl = TextEditingController(text: _blockedBalance > 0 ? _blockedBalance.toStringAsFixed(0) : '');
    final limitCtrl = TextEditingController(text: _dailyLimit > 0 ? _dailyLimit.toStringAsFixed(0) : '');

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCardSolid : AppColors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderColor),
        ),
        title: Text(
          'EDIT BALANCES & LIMITS',
          style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue, fontSize: 13, letterSpacing: 1.5),
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceField('Total Settled Balance (EUR):', totalCtrl, isLayer ? LayerColors.accentNeon : AppColors.accentGreen, isLayer),
                const SizedBox(height: 14),
                _buildBalanceField('Available Balance (EUR):', availCtrl, isLayer ? LayerColors.accentNeon : AppColors.accentGreen, isLayer),
                const SizedBox(height: 14),
                _buildBalanceField('Blocked / Pending Balance (EUR):', blockCtrl, isLayer ? LayerColors.accentOrange : AppColors.accentOrange, isLayer),
                const SizedBox(height: 14),
                _buildBalanceField('Daily Transfer Limit (EUR):', limitCtrl, isLayer ? LayerColors.accentCyan : AppColors.accentBlue, isLayer),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'total': double.tryParse(totalCtrl.text) ?? 0,
                'available': double.tryParse(availCtrl.text) ?? 0,
                'blocked': double.tryParse(blockCtrl.text) ?? 0,
                'limit': double.tryParse(limitCtrl.text) ?? 0,
              });
            },
            child: Text('SAVE ALL', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _balance = result['total'] ?? _balance;
        _availableBalance = result['available'] ?? _availableBalance;
        _blockedBalance = result['blocked'] ?? _blockedBalance;
        _dailyLimit = result['limit'] ?? _dailyLimit;
      });
      _transferService.saveBalances(
        balance: _balance,
        available: _availableBalance,
        blocked: _blockedBalance,
        limit: _dailyLimit,
      );
    }
  }

  Widget _buildBalanceField(String label, TextEditingController ctrl, Color color, bool isLayer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            prefixText: '€ ',
            prefixStyle: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
            hintText: '0',
            hintStyle: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted),
            border: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderColor)),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderColor)),
          ),
        ),
      ],
    );
  }

  void _editHeaderBankDialog() async {
    final isLayer = widget.dashboardType == 'LAYER';
    final nameCtrl = TextEditingController(text: _headerBankName);
    final subCtrl = TextEditingController(
      text: _headerSubtitle.isNotEmpty
          ? _headerSubtitle
          : (isLayer ? 'SWIFT Alliance LAYER v7.4.2' : 'SWIFT Alliance Access v7.4.2'),
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCardSolid : AppColors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderColor),
        ),
        title: Text(
          'EDIT BANK HEADER',
          style: TextStyle(
            color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bank Name:', style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                hintText: 'e.g. Bank BCA',
                hintStyle: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 14),
            Text('Subtitle / Version:', style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 6),
            TextField(
              controller: subCtrl,
              style: TextStyle(color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                hintText: isLayer ? 'SWIFT Alliance LAYER v7.4.2' : 'SWIFT Alliance Access v7.4.2',
                hintStyle: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameCtrl.text.trim(),
                'sub': subCtrl.text.trim(),
              });
            },
            child: Text('SAVE', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (result['name'] != null && result['name']!.isNotEmpty) {
          _headerBankName = result['name']!;
        }
        if (result['sub'] != null) {
          _headerSubtitle = result['sub']!;
        }
      });
    }
  }

  void _editBalanceDialog() async {
    final isLayer = widget.dashboardType == 'LAYER';
    final ctrl = TextEditingController(text: _balance > 0 ? _balance.toStringAsFixed(0) : '');
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCardSolid : AppColors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderColor),
        ),
        title: Text('SET BALANCE', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue, fontSize: 13, letterSpacing: 1.5)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter balance amount (EUR):', style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 10),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 18, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '€ ',
                prefixStyle: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 18, fontWeight: FontWeight.w700),
                hintText: '0',
                hintStyle: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted))),
          TextButton(
            onPressed: () {
              final value = double.tryParse(ctrl.text) ?? 0;
              Navigator.pop(context, value);
            },
            child: Text('SAVE', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _balance = result;
      });
      _transferService.saveBalances(
        balance: _balance,
        available: _availableBalance,
        blocked: _blockedBalance,
        limit: _dailyLimit,
      );
    }
  }

  String _formatCurrency(double value) {
    if (value == 0) return '€ 0,00';
    final formatter = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '€ ${formatter.replaceAllMapped(reg, (m) => '${m[1]}.')},00';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }
    return _buildDashboard();
  }

  Widget _buildDashboard() {
    final isLayer = widget.dashboardType == 'LAYER';

    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        showHud: false,
        isLayer: isLayer,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Row(
                  children: [
                    AppSidebar(
                      activeIndex: isLayer ? 1 : 0,
                      username: _username,
                      onEdit: _showQuickEditMenu,
                      isLayer: isLayer,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPageTitle(),
                            const SizedBox(height: 25),
                            _buildInfoGrid(),
                            const SizedBox(height: 25),
                            BalanceSection(
                              initialValue: _balance > 0 ? _balance : null,
                              onChanged: (v) {
                                setState(() => _balance = v);
                                _transferService.saveBalances(
                                  balance: _balance,
                                  available: _availableBalance,
                                  blocked: _blockedBalance,
                                  limit: _dailyLimit,
                                );
                              },
                              isLayer: isLayer,
                            ),
                            const SizedBox(height: 20),
                            _buildStatsGrid(),
                          ],
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

  Widget _buildLoadingScreen() {
    final isLayer = widget.dashboardType == 'LAYER';
    final accent = isLayer ? LayerColors.accentNeon : AppColors.accentGreen;
    final cardBg = const Color(0xFF09111D).withValues(alpha: 0.92);
    final borderColor = isLayer
        ? const Color(0xFF00FF66).withValues(alpha: 0.35)
        : const Color(0xFF00A8FF).withValues(alpha: 0.35);
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
                  color: (isLayer ? const Color(0xFF00FF66) : const Color(0xFF00A8FF)).withValues(alpha: 0.15),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        backgroundColor: inputBg,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Text(
                      isLayer
                          ? 'CONNECTING TO LAYER SECURE TUNNEL'
                          : 'CONNECTING TO SECURE SERVER',
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
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
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
                      isLayer ? 'Establishing Layer Quantum Mesh...' : 'Connecting to SWIFT Alliance Gateway...',
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
                            text: isLayer ? 'Layer identity verified' : 'Authentication verified',
                            done: progress > 0.15,
                            isLayer: isLayer,
                          ),
                          _LoadingStep(
                            status: progress > 0.45 ? '✓' : '...',
                            text: isLayer ? 'Loading layer ledger data' : 'Loading account data',
                            done: progress > 0.45,
                            isLayer: isLayer,
                          ),
                          _LoadingStep(
                            status: progress > 0.70 ? '✓' : '...',
                            text: isLayer ? 'Establishing encrypted mesh tunnel' : 'Establishing secure connection',
                            done: progress > 0.70,
                            isLayer: isLayer,
                          ),
                          _LoadingStep(
                            status: progress > 0.90 ? '✓' : '...',
                            text: isLayer ? 'Synchronizing global node balance' : 'Verifying balance and limits',
                            done: progress > 0.90,
                            isLayer: isLayer,
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

  Widget _buildPageTitle() {
    final isLayer = widget.dashboardType == 'LAYER';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isLayer
                  ? 'SWIFT.net Layer Dashboard'
                  : 'SWIFT MT 103 Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                shadows: isLayer
                    ? [const Shadow(color: Color(0x6600FF66), blurRadius: 12)]
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          isLayer
              ? 'Account Overview | Secure Tunnel Monitoring | RSDR Management'
              : 'Account Overview | Real-time Monitoring | RSDR Management',
          style: TextStyle(fontSize: 11, color: isLayer ? LayerColors.textSecondary : AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final isLayer = widget.dashboardType == 'LAYER';
    final cardBg = isLayer ? LayerColors.bgCard : AppColors.bgCard;
    final borderColor = isLayer ? LayerColors.borderColor : AppColors.borderColor;
    final accentNeon = isLayer ? LayerColors.accentNeon : AppColors.accentGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _editHeaderBankDialog,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  DeutscheBankEmblem(
                    size: 32,
                    color: isLayer ? const Color(0xFF00FF66) : const Color(0xFF00A8FF),
                    hasGlow: true,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _headerBankName,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary),
                      ),
                      Text(
                        _headerSubtitle.isNotEmpty
                            ? _headerSubtitle
                            : (isLayer ? 'SWIFT Alliance LAYER v7.4.2' : 'SWIFT Alliance Access v7.4.2'),
                        style: TextStyle(fontSize: 9, color: isLayer ? LayerColors.textMuted : AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Text(
                isLayer ? 'HOST: db-layer.vpn.dt.com' : 'HOST: db-swift.dt.com',
                style: TextStyle(fontSize: 10, color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary),
              ),
              const SizedBox(width: 15),
              Text('SPEC: ', style: TextStyle(fontSize: 10, color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary)),
              Text(
                isLayer ? 'LAYER-NET-03141' : 'CRYPTO03141',
                style: TextStyle(fontSize: 10, color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 15),
              Text('STATUS: ', style: TextStyle(fontSize: 10, color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentNeon.withValues(alpha: 0.15),
                  border: Border.all(color: accentNeon.withValues(alpha: 0.3)),
                ),
                child: Text(
                  isLayer ? 'LAYER ACTIVE' : 'ONLINE',
                  style: TextStyle(fontSize: 9, color: accentNeon, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TransferPage(isLayer: isLayer)));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentNeon,
                  side: BorderSide(color: accentNeon),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('+ NEW TRANSFER', style: TextStyle(fontSize: 10, letterSpacing: 1)),
              ),
              const SizedBox(width: 15),
              OutlinedButton(
                onPressed: _confirmLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  side: const BorderSide(color: AppColors.accentRed),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('LOGOUT', style: TextStyle(fontSize: 10, letterSpacing: 1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final isLayer = widget.dashboardType == 'LAYER';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCardSolid : const Color(0xFF0C1626),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: AppColors.accentRed.withValues(alpha: 0.6)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.accentRed, size: 20),
            const SizedBox(width: 8),
            Text(
              'CONFIRM LOGOUT',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.accentRed,
                fontSize: 13,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to terminate the current SWIFT session and logout?',
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFFCBD5E1),
            fontSize: 12,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: const BorderSide(color: AppColors.accentRed),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(
              'LOGOUT',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.accentRed,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _session.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeLoginPage()),
        (route) => false,
      );
    }
  }

  Widget _buildInfoGrid() {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _accountInfoCard()),
              const SizedBox(width: 20),
              Expanded(child: _serverInfoCard()),
            ],
          );
        }
        return Column(children: [_accountInfoCard(), const SizedBox(height: 20), _serverInfoCard()]);
      },
    );
  }

  Widget _accountInfoCard() {
    final isLayer = widget.dashboardType == 'LAYER';
    return InfoCard(
      title: 'Account Information',
      editable: false,
      isLayer: isLayer,
      onRowChanged: _updateAccountRow,
      onEditAll: _editAllAccountInfo,
      rows: [
        InfoRow(label: 'Account Holder', value: _accountData['account_holder'] ?? ''),
        InfoRow(label: 'Account Number', value: _accountData['account_number'] ?? ''),
        InfoRow(
          label: 'IBAN',
          value: _accountData['iban'] ?? '',
          color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
        ),
        InfoRow(
          label: 'BIC / SWIFT',
          value: _accountData['bic'] ?? '',
          color: isLayer ? LayerColors.accentCyan : AppColors.accentBlue,
        ),
        InfoRow(label: 'Bank', value: _accountData['bank'] ?? ''),
        InfoRow(label: 'Branch', value: _accountData['branch'] ?? ''),
        InfoRow(label: 'Reg.No', value: _accountData['reg_no'] ?? ''),
        InfoRow(label: 'VAT ID', value: _accountData['vat_id'] ?? ''),
      ],
    );
  }

  Widget _serverInfoCard() {
    final isLayer = widget.dashboardType == 'LAYER';
    if (isLayer) {
      return const InfoCard(
        title: 'Layer VPN Gateway Server',
        statusText: 'LAYER SECURE',
        statusType: StatusType.online,
        isLayer: true,
        rows: [
          InfoRow(label: 'Gateway', value: '185.22.187.75 : 8443 (LAYER)', color: LayerColors.accentNeon),
          InfoRow(label: 'Version', value: 'LAYER Mesh Protocol v7.4.2'),
          InfoRow(label: 'Protocol', value: 'TCP 1.3 / NSP-256-GCM (LAYER)'),
          InfoRow(label: 'Certificate', value: 'LayerNet TLS RSA 4096-ECC'),
          InfoRow(label: 'Identity Code', value: 'LAYER-7X99-20EF60', color: LayerColors.accentNeon),
          InfoRow(label: 'Server ID', value: 'LAYER-S85375'),
          InfoRow(label: 'WTS Server', value: 'LAYER-S62605435'),
          InfoRow(label: 'Status', value: 'SECURE | TUNNEL ENCRYPTED', color: LayerColors.accentCyan),
        ],
      );
    }
    return const InfoCard(
      title: 'Alliance Access Server',
      statusText: 'ONLINE',
      statusType: StatusType.online,
      rows: [
        InfoRow(label: 'Gateway', value: '185.22.187.75 : 443', color: AppColors.accentGreen),
        InfoRow(label: 'Version', value: 'Alliance Access v7.4.2'),
        InfoRow(label: 'Protocol', value: 'TCP 1.3 / NSP-256-GCM'),
        InfoRow(label: 'Certificate', value: 'BigCert TLS RSA 4096-5'),
        InfoRow(label: 'Identity Code', value: 'B1C20EF60AT00X', color: AppColors.accentGreen),
        InfoRow(label: 'Server ID', value: 'A85375'),
        InfoRow(label: 'WTS Server', value: 'S62605435'),
        InfoRow(label: 'Status', value: 'SECURE | ENCRYPTED', color: AppColors.accentBlue),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final isLayer = widget.dashboardType == 'LAYER';
    return LayoutBuilder(
      builder: (context, c) {
        int cols = c.maxWidth > 800 ? 3 : 1;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: cols == 3 ? 1.3 : 2.5,
          children: [
            StatCard(
              label: 'Available Balance',
              value: _formatCurrency(_availableBalance),
              valueColor: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
              detail: _availableBalance > 0 ? 'Settled — 2 Transfers' : '-',
              isLayer: isLayer,
            ),
            StatCard(
              label: 'Blocked / Pending',
              value: _formatCurrency(_blockedBalance),
              valueColor: isLayer ? LayerColors.accentOrange : AppColors.accentOrange,
              detail: _blockedBalance > 0 ? '4 Transfers — Bill Processing' : '-',
              isLayer: isLayer,
            ),
            StatCard(
              label: 'Daily Transfer Limit',
              value: _formatCurrency(_dailyLimit),
              valueColor: isLayer ? LayerColors.accentCyan : AppColors.accentBlue,
              detail: _dailyLimit > 0 ? 'Remaining limit' : '-',
              isLayer: isLayer,
            ),
          ],
        );
      },
    );
  }

  Future<void> _editStatCard(String type) async {
    final isLayer = widget.dashboardType == 'LAYER';
    final ctrl = TextEditingController();
    final current = type == 'available'
        ? _availableBalance
        : type == 'blocked'
            ? _blockedBalance
            : _dailyLimit;

    if (current > 0) ctrl.text = current.toStringAsFixed(0);

    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isLayer ? LayerColors.bgCardSolid : AppColors.bgCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.borderColor),
        ),
        title: Text(
          'EDIT ${type.toUpperCase()}',
          style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue, fontSize: 13, letterSpacing: 1.5),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 16, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            prefixText: '€ ',
            prefixStyle: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 16, fontWeight: FontWeight.w700),
            hintText: '0',
            hintStyle: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? 0;
              Navigator.pop(context, v);
            },
            child: Text('SAVE', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (type == 'available') _availableBalance = result;
        if (type == 'blocked') _blockedBalance = result;
        if (type == 'limit') _dailyLimit = result;
      });
      _transferService.saveBalances(
        balance: _balance,
        available: _availableBalance,
        blocked: _blockedBalance,
        limit: _dailyLimit,
      );
    }
  }
}

// ============ LOADING STEP ============
class _LoadingStep extends StatelessWidget {
  final String status;
  final String text;
  final bool done;
  final bool isLayer;

  const _LoadingStep({
    required this.status,
    required this.text,
    required this.done,
    this.isLayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isLayer ? LayerColors.accentNeon : AppColors.accentGreen;
    final secondary = isLayer ? LayerColors.textSecondary : const Color(0xFFCBD5E1);
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

// ============ EDIT ALL DIALOG ============
class _EditAccountInfoDialog extends StatefulWidget {
  final Map<String, String> data;
  final bool isLayer;

  const _EditAccountInfoDialog({required this.data, this.isLayer = false});

  @override
  State<_EditAccountInfoDialog> createState() => _EditAccountInfoDialogState();
}

class _EditAccountInfoDialogState extends State<_EditAccountInfoDialog> {
  late Map<String, TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = {};
    widget.data.forEach((key, value) {
      _ctrls[key] = TextEditingController(text: value);
    });
  }

  @override
  void dispose() {
    _ctrls.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _save() {
    final result = <String, String>{};
    _ctrls.forEach((key, ctrl) {
      result[key] = ctrl.text;
    });
    Navigator.pop(context, result);
  }

  Widget _buildField(String label, String key) {
    final isLayer = widget.isLayer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _ctrls[key],
              style: TextStyle(
                color: isLayer ? LayerColors.textPrimary : AppColors.textPrimary,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                fillColor: isLayer ? LayerColors.bgInput : AppColors.bgInput,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: isLayer ? LayerColors.borderColor : AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    return AlertDialog(
      backgroundColor: isLayer ? LayerColors.bgCardSolid : AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.borderColor),
      ),
      title: Text(
        'EDIT ACCOUNT INFORMATION',
        style: TextStyle(
          color: isLayer ? LayerColors.accentNeon : AppColors.accentBlue,
          fontSize: 13,
          letterSpacing: 1.5,
        ),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Account Holder', 'account_holder'),
              _buildField('Account Number', 'account_number'),
              _buildField('IBAN', 'iban'),
              _buildField('BIC / SWIFT', 'bic'),
              _buildField('Bank', 'bank'),
              _buildField('Branch', 'branch'),
              _buildField('Reg.No', 'reg_no'),
              _buildField('VAT ID', 'vat_id'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL', style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, letterSpacing: 1)),
        ),
        TextButton(
          onPressed: _save,
          child: Text('SAVE ALL', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, letterSpacing: 1)),
        ),
      ],
    );
  }
}

