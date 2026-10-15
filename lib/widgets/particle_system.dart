import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ParticleSystem extends StatefulWidget {
  final int count;
  const ParticleSystem({Key? key, this.count = 8}) : super(key: key);

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (i) => _Particle(
      left: (i * 37) % 100 / 100,
      top: (i * 53) % 100 / 100,
      delay: Duration(milliseconds: i * 300),
    ));
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _particles.map((p) {
            final t = (_controller.value + p.delay.inMilliseconds / 3000) % 1;
            return Positioned(
              left: MediaQuery.of(context).size.width * p.left,
              top: MediaQuery.of(context).size.height * p.top,
              child: Opacity(
                opacity: 0.4 + 0.5 * (1 - (t - 0.5).abs() * 2),
                child: Transform.translate(
                  offset: Offset(0, -20 * (1 - (t - 0.5).abs() * 2)),
                  child: Container(
                    width: 4,
                    height: 4,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Particle {
  final double left;
  final double top;
  final Duration delay;
  _Particle({required this.left, required this.top, required this.delay});
}
