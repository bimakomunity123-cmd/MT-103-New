import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/session_service.dart';
import '../pages/welcome_login_page.dart';
import 'status_badge.dart';

class AppTopBar extends StatefulWidget {
  final bool isLayer;
  const AppTopBar({super.key, this.isLayer = false});

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  late String _time;
  late Stream<int> _stream;

  @override
  void initState() {
    super.initState();
    _time = DateFormat('HH:mm:ss').format(DateTime.now());
    _stream = Stream.periodic(const Duration(seconds: 1), (i) => i);
    _stream.listen((_) {
      if (mounted) {
        setState(() {
          _time = DateFormat('HH:mm:ss').format(DateTime.now());
        });
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    final isLayer = widget.isLayer;
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
      final session = SessionService();
      await session.clear();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeLoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: isLayer ? LayerColors.bgSecondary : AppColors.bgSecondary,
        border: Border(bottom: BorderSide(color: isLayer ? LayerColors.borderColor : AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT
          Row(
            children: [
              Text('● ', style: TextStyle(color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen, fontSize: 10)),
              Text(isLayer ? 'LAYER Access v7.4.2' : 'Access v7.4.2',
                style: TextStyle(color: isLayer ? LayerColors.textSecondary : AppColors.textSecondary, fontSize: 10)),
              const SizedBox(width: 15),
              Text(_time, style: TextStyle(color: isLayer ? LayerColors.textMuted : AppColors.textMuted, fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
          // RIGHT
          Row(
            children: [
              StatusBadge(text: isLayer ? 'LAYER ADMIN' : '17 ADMIN', type: StatusType.active, fontSize: 9),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _logout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  side: const BorderSide(color: AppColors.accentRed, width: 0.5),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text('LOGOUT', style: TextStyle(fontSize: 9, letterSpacing: 1)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
