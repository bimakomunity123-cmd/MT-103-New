import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/swift_network_background.dart';
import '../services/session_service.dart';

class CompliancePage extends StatefulWidget {
  const CompliancePage({super.key});

  @override
  State<CompliancePage> createState() => _CompliancePageState();
}

class _CompliancePageState extends State<CompliancePage> {
  String _username = 'DeutscheBank_Betty_Bima';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = await SessionService().getUsername();
    if (user != null && mounted) {
      setState(() => _username = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        showHud: false,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    AppSidebar(
                      activeIndex: 4,
                      username: _username,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Compliance & Risk Status', style: TextStyle(fontSize: 18, color: AppColors.textPrimary)),
                            const SizedBox(height: 5),
                            const Text('Real-time regulatory compliance monitoring',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(height: 25),
                            _buildComplianceGrid(),
                            const SizedBox(height: 25),
                            _buildRegulatorySection(),
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

  Widget _buildComplianceGrid() {
    final items = [
      {'icon': '✓', 'color': AppColors.accentGreen, 'title': 'AML SCREENING', 'sub': 'LAST 23.06.2026 19:11:42', 'desc': 'Transaction monitoring system is operational with no suspected transactions detected'},
      {'icon': '✓', 'color': AppColors.accentGreen, 'title': 'KYC VERIFIED', 'sub': 'LEVEL 3 AUTHENTICATED', 'desc': 'Know-Your-Customer (KYC) verification completed with full compliance'},
      {'icon': '✓', 'color': AppColors.accentGreen, 'title': 'SANCTIONS CLEAR', 'sub': 'OFAC / EFA / EU / UN', 'desc': 'All entities checked against global Sanctioning Lists and Watch List'},
      {'icon': '!', 'color': AppColors.accentYellow, 'title': 'RISK SCORE LOW', 'sub': '3 USERS PENDING REVIEW', 'desc': 'Credit risk level is currently low. Limit / Market risk within bounds'},
    ];

    return LayoutBuilder(builder: (context, c) {
      int cols = c.maxWidth > 900 ? 4 : (c.maxWidth > 600 ? 2 : 1);
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: cols == 4 ? 0.9 : 1.5,
        children: items.map((item) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              Text(item['icon'] as String, style: TextStyle(color: item['color'] as Color, fontSize: 32, fontWeight: FontWeight.w700)),
              const SizedBox(height: 15),
              Text(item['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(item['sub'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 1)),
              const SizedBox(height: 15),
              Text(item['desc'] as String, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        )).toList(),
      );
    });
  }

  Widget _buildRegulatorySection() {
    final items = [
      ['BaFin Registration', 'REGISTERED | 163733 | 06/2116', AppColors.accentGreen],
      ['ECB Oversight', 'COMPLIANT | SSM PERMANENT', AppColors.accentGreen],
      ['FATCA / CRS', 'REGISTERED | GIIN AVAILABLE', AppColors.accentGreen],
      ['PSD2 / Open Banking', 'COMPLIANT | SCA', AppColors.accentGreen],
      ['MiFID II', 'COMPLIANT', AppColors.accentGreen],
      ['Last Audit', '19-GRID-19R0J1 | 19.10.2025', AppColors.accentBlue],
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('REGULATORY STATUS', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1.5)),
          Container(margin: const EdgeInsets.symmetric(vertical: 10), height: 1, color: AppColors.borderColor),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item[0] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(item[1] as String, style: TextStyle(fontSize: 10, color: item[2] as Color, fontWeight: FontWeight.w600, letterSpacing: 1)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
