import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/grid_background.dart';
import '../widgets/particle_system.dart';
import '../services/session_service.dart';
import 'account_dashboard_page.dart';

class ConnectionSuccessPage extends StatefulWidget {
  const ConnectionSuccessPage({Key? key}) : super(key: key);

  @override
  State<ConnectionSuccessPage> createState() => _ConnectionSuccessPageState();
}

class _ConnectionSuccessPageState extends State<ConnectionSuccessPage> {
  String _token = '';
  final _session = SessionService();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _loadToken() async {
    final token = await _session.getToken() ?? 'DE340837';
    setState(() => _token = token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBackground(),
          const ParticleSystem(),
          Center(
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('CONNECTED!!!',
                    style: TextStyle(
                      fontSize: 20, color: AppColors.accentGreen, letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: Color(0x8000FF88), blurRadius: 20)],
                    )),
                  const SizedBox(height: 25),
                  const Text('21/06/2026 23:09:28 (GMT +0100)',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Text('TKN : $_token',
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 25),
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountDashboardPage()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Text('[ SUBMIT ]', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
