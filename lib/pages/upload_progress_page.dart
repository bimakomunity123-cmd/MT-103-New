import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/grid_background.dart';
import '../widgets/particle_system.dart';
import '../services/session_service.dart';
import 'connection_success_page.dart';

class UploadProgressPage extends StatefulWidget {
  const UploadProgressPage({Key? key}) : super(key: key);

  @override
  State<UploadProgressPage> createState() => _UploadProgressPageState();
}

class _UploadProgressPageState extends State<UploadProgressPage> {
  double _progress = 0.0;
  Timer? _timer;
  final _codeCtrl = TextEditingController();
  String _token = '';
  final _session = SessionService();

  @override
  void initState() {
    super.initState();
    _token = _generateToken();
    _session.saveToken(_token);
    _startProgress();
  }

  String _generateToken() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random();
    return 'DE${List.generate(6, (_) => chars[r.nextInt(chars.length)]).join()}';
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _progress += 0.05;
      });
      if (_progress >= 1.0) {
        _timer?.cancel();
        setState(() {
          _progress = 1.0;
        });
      }
    });
  }

  void _submit() async {
    if (_codeCtrl.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid code (min 3 chars)')),
      );
      return;
    }
    await _session.saveAuthCode(_codeCtrl.text);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ConnectionSuccessPage()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showCompleted = _progress >= 1.0;
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
              child: showCompleted ? _buildCompleted() : _buildProgress(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('\$ ', style: TextStyle(color: AppColors.accentGreen)),
            Text('global_server/status/DE34083776569896564', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 20),
        Text('UPLOADING ${(_progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 15),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            border: Border.all(color: AppColors.borderColor),
          ),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleted() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('UPLOAD COMPLETED',
          style: TextStyle(fontSize: 18, color: AppColors.accentGreen, letterSpacing: 3, fontWeight: FontWeight.w700)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            const Text('[1]', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 15),
            const Text('Input Code', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            const Text('[2]', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 15),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _codeCtrl,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            const Text('KEY :', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(width: 10),
            Text(_token, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 30),
        InkWell(
          onTap: _submit,
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
    );
  }
}
