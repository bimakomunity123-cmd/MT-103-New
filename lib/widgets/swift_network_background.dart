import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SwiftNetworkBackground extends StatefulWidget {
  final Widget child;
  final bool showHud;
  final bool isLayer;
  final bool isError;
  final VoidCallback? onBottomLeftTap;

  const SwiftNetworkBackground({
    super.key,
    required this.child,
    this.showHud = true,
    this.isLayer = false,
    this.isError = false,
    this.onBottomLeftTap,
  });

  @override
  State<SwiftNetworkBackground> createState() => _SwiftNetworkBackgroundState();
}

class _SwiftNetworkBackgroundState extends State<SwiftNetworkBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_NetworkNode> _nodes;
  late List<_DataPacket> _packets;
  late List<String> _logLines;
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();

    final isError = widget.isError;

    // Generate 32 financial nodes distributed across screen
    _nodes = List.generate(32, (index) {
      final isMajorHub = index < 6;
      return _NetworkNode(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        vx: (_random.nextDouble() - 0.5) * (isError ? 0.00018 : 0.0003),
        vy: (_random.nextDouble() - 0.5) * (isError ? 0.00018 : 0.0003),
        radius: isMajorHub ? 3.5 : 2.0,
        isMajorHub: isMajorHub,
        pulseOffset: _random.nextDouble() * pi * 2,
        label: isMajorHub
            ? (isError
                ? ['FRA-HALT', 'NYC-SUSP', 'LON-RTGS', 'TYO-ERR', 'SIN-HOLD', 'ZUR-LOCK'][index]
                : ['FRA-HUB', 'NYC-GW', 'LON-RTGS', 'TYO-FIN', 'SIN-CORE', 'ZUR-HSM'][index])
            : null,
      );
    });

    _packets = [];

    _logLines = isError
        ? [
            '[SWIFT-NET] CRITICAL ALERT: TOKEN EXHAUSTION (42.08%)',
            '[SEC-HSM] CRYPTOGRAPHIC TRANSFER TOKENS: 0 ACTIVE',
            '[GATEWAY] ROUTE SUSPENDED // STATUS: HALTED',
            '[FIN-CORE] SETTLEMENT ENGINE SUSPENDED (ERROR 0x4208)',
            '[ROUTING] ALLIANCE ACCESS: WIRE TRANSMISSION FROZEN',
            '[VPN] IPsec TUNNEL: IDLE // AWAITING RE-AUTHENTICATION',
            '[CLEARING] RTGS INTERBANK CLEARING: PAUSED',
            '[SECURITY] PROTOCOL LOCKOUT: INSUFFICIENT AUTH TOKENS',
          ]
        : [
            '[SWIFT-NET] SYSTEM BOOTSTRAP READY',
            '[PKI-AUTH] RSA-4096 / SHA-512 SIGNATURE OK',
            '[GATEWAY] ROUTE: 185.22.187.75:443 (SECURE)',
            '[FIN-CORE] ISO 20022 / MT103 PROTOCOL SYNCED',
            '[HSM] HARDWARE SECURITY MODULE: ONLINE',
            '[VPN] IPsec TUNNEL: AES-256-GCM ESTABLISHED',
            '[ROUTING] ALLIANCE ACCESS v7.4.2 RUNNING',
            '[CLEARING] CHAPS / TARGET2 / FEDWIRE LINKED',
          ];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(() {
        _updateNodes();
      })..repeat();
  }

  void _updateNodes() {
    for (final node in _nodes) {
      node.x += node.vx;
      node.y += node.vy;

      if (node.x <= 0 || node.x >= 1) node.vx = -node.vx;
      if (node.y <= 0 || node.y >= 1) node.vy = -node.vy;
    }

    // Spawn network packets
    if (_random.nextDouble() < 0.05 && _packets.length < 8) {
      final from = _nodes[_random.nextInt(_nodes.length)];
      final to = _nodes[_random.nextInt(_nodes.length)];
      if (from != to) {
        _packets.add(_DataPacket(from: from, to: to));
      }
    }

    // Update packets
    _packets.removeWhere((p) {
      p.progress += 0.02;
      return p.progress >= 1.0;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    final isError = widget.isError;
    final primaryAccent = isError
        ? const Color(0xFFF43F5E)
        : (isLayer ? const Color(0xFF00FF66) : const Color(0xFF00A8FF));

    return Stack(
      children: [
        // DEEP CYBER GRADIENT
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.1),
                radius: 1.25,
                colors: isError
                    ? const [
                        Color(0xFF1E040B), // Center emergency crimson tint
                        Color(0xFF110207),
                        Color(0xFF070104), // Deep dark edges
                      ]
                    : (isLayer
                        ? const [
                            Color(0xFF05160A), // Center glow (Matrix green tint)
                            Color(0xFF030D06),
                            Color(0xFF010603), // Deep dark edges
                          ]
                        : const [
                            Color(0xFF0C1626), // Center glow (SWIFT blue tint)
                            Color(0xFF070D18),
                            Color(0xFF03070E), // Deep dark edges
                          ]),
              ),
            ),
          ),
        ),

        // ANIMATED NETWORK MESH CANVAS
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return CustomPaint(
                painter: _SwiftMeshPainter(
                  nodes: _nodes,
                  packets: _packets,
                  animValue: _animController.value,
                  isLayer: isLayer,
                  isError: isError,
                ),
              );
            },
          ),
        ),

        if (widget.showHud) ...[
          // BACKGROUND TELEMETRY LOGS (LEFT SIDE - WATERMARK EFFECT)
          Positioned(
            left: 24,
            top: 80,
            bottom: 80,
            width: 290,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _logLines.map((line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      line,
                      style: GoogleFonts.jetBrainsMono(
                        color: primaryAccent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),

          // HUD OVERLAY: TOP LEFT
          Positioned(
            top: 20,
            left: 24,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: primaryAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: primaryAccent, blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isError
                      ? 'SWIFT.NET // INCIDENT ALERT: TOKEN DEPLETED [STATUS: HALTED]'
                      : (isLayer
                          ? 'SWIFT.NET // QUANTUM LAYER MESH [NODE: LIVE]'
                          : 'SWIFT.NET // ALLIANCE ACCESS v7.4.2 [NODE: LIVE]'),
                  style: GoogleFonts.jetBrainsMono(
                    color: isError ? const Color(0xFFF43F5E).withValues(alpha: 0.8) : const Color(0xFF64748B),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // HUD OVERLAY: TOP RIGHT
          Positioned(
            top: 20,
            right: 24,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryAccent.withValues(alpha: 0.1),
                    border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isError
                        ? 'SETTLEMENT SUSPENDED | ERROR: 0x4208'
                        : (isLayer ? 'LAYER-2 PROTOCOL | QUANTUM-GCM' : 'TLS 1.3 | AES-256-GCM'),
                    style: GoogleFonts.jetBrainsMono(
                      color: primaryAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // HUD OVERLAY: BOTTOM LEFT
          Positioned(
            bottom: 20,
            left: 24,
            child: widget.onBottomLeftTap != null
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onBottomLeftTap,
                      child: Text(
                        isError
                            ? 'TRANSACTION ERROR: WIRE TRANSMISSION SUSPENDED AT 42.08% // TOKENS EXHAUSTED'
                            : 'SECURE HSM ENVIRONMENT: CERTIFIED // 512-BIT QUANTUM SIGNED',
                        style: GoogleFonts.jetBrainsMono(
                          color: isError ? const Color(0xFFE11D48).withValues(alpha: 0.7) : const Color(0xFF334155),
                          fontSize: 9.5,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  )
                : Text(
                    isError
                        ? 'TRANSACTION ERROR: WIRE TRANSMISSION SUSPENDED AT 42.08% // TOKENS EXHAUSTED'
                        : 'SECURE HSM ENVIRONMENT: CERTIFIED // 512-BIT QUANTUM SIGNED',
                    style: GoogleFonts.jetBrainsMono(
                      color: isError ? const Color(0xFFE11D48).withValues(alpha: 0.7) : const Color(0xFF334155),
                      fontSize: 9.5,
                      letterSpacing: 1,
                    ),
                  ),
          ),

          // HUD OVERLAY: BOTTOM RIGHT
          Positioned(
            bottom: 20,
            right: 24,
            child: Text(
              isError ? 'RE-AUTHENTICATION REQUIRED // SYSTEM PROTOCOL HALT' : 'UNAUTHORIZED ACCESS PROHIBITED - © 2026 SWIFT RSDR',
              style: GoogleFonts.jetBrainsMono(
                color: isError ? const Color(0xFFE11D48).withValues(alpha: 0.6) : const Color(0xFF475569),
                fontSize: 9.5,
                letterSpacing: 1,
              ),
            ),
          ),
        ],

        // MAIN CONTENT
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _NetworkNode {
  double x;
  double y;
  double vx;
  double vy;
  final double radius;
  final bool isMajorHub;
  final double pulseOffset;
  final String? label;

  _NetworkNode({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.isMajorHub,
    required this.pulseOffset,
    this.label,
  });
}

class _DataPacket {
  final _NetworkNode from;
  final _NetworkNode to;
  double progress = 0.0;

  _DataPacket({required this.from, required this.to});
}

class _SwiftMeshPainter extends CustomPainter {
  final List<_NetworkNode> nodes;
  final List<_DataPacket> packets;
  final double animValue;
  final bool isLayer;
  final bool isError;

  _SwiftMeshPainter({
    required this.nodes,
    required this.packets,
    required this.animValue,
    this.isLayer = false,
    this.isError = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..strokeWidth = 0.8;
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;

    // Draw subtle grid lines
    final gridPaint = Paint()
      ..color = isError
          ? const Color(0x15FF2A55)
          : (isLayer ? const Color(0x0800FF66) : const Color(0x0800A8FF))
      ..strokeWidth = 1.0;

    const gridSize = 60.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Emergency scanline beam when in error state
    if (isError) {
      final scanY = (animValue * size.height * 1.5) % (size.height + 200) - 100;
      final scanRect = Rect.fromLTWH(0, scanY, size.width, 100);
      final scanPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0x10FF2A55),
            Colors.transparent,
          ],
        ).createShader(scanRect);
      canvas.drawRect(scanRect, scanPaint);
    }

    // Connect close nodes (Interbank mesh)
    const maxDist = 180.0;
    for (int i = 0; i < nodes.length; i++) {
      final p1 = Offset(nodes[i].x * size.width, nodes[i].y * size.height);

      for (int j = i + 1; j < nodes.length; j++) {
        final p2 = Offset(nodes[j].x * size.width, nodes[j].y * size.height);
        final dist = (p1 - p2).distance;

        if (dist < maxDist) {
          final alpha = (1.0 - dist / maxDist) * 0.28;
          linePaint.color = isError
              ? Color.fromRGBO(255, 42, 85, alpha * 0.85)
              : (isLayer
                  ? Color.fromRGBO(0, 255, 102, alpha)
                  : Color.fromRGBO(0, 168, 255, alpha));
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }

    // Draw traveling data packets
    final packetPaint = Paint()
      ..color = isError
          ? const Color(0xFFFF2A55)
          : (isLayer ? const Color(0xFF76FF03) : const Color(0xFF00FFCC))
      ..style = PaintingStyle.fill;

    for (final packet in packets) {
      final p1 = Offset(packet.from.x * size.width, packet.from.y * size.height);
      final p2 = Offset(packet.to.x * size.width, packet.to.y * size.height);
      final currentPos = Offset.lerp(p1, p2, packet.progress)!;

      canvas.drawCircle(currentPos, 2.5, packetPaint);
      canvas.drawCircle(
        currentPos,
        5.0,
        Paint()
          ..color = isError
              ? const Color(0x44FF2A55)
              : (isLayer ? const Color(0x4476FF03) : const Color(0x4400FFCC)),
      );
    }

    // Draw Nodes
    for (final node in nodes) {
      final pos = Offset(node.x * size.width, node.y * size.height);
      final pulse = (sin(animValue * pi * 4 + node.pulseOffset) + 1.0) / 2.0;

      if (node.isMajorHub) {
        // Glowing halo for major SWIFT hubs
        glowPaint.color = isError
            ? Color.fromRGBO(255, 42, 85, 0.14 + (0.16 * pulse))
            : (isLayer
                ? Color.fromRGBO(0, 255, 102, 0.12 + (0.15 * pulse))
                : Color.fromRGBO(0, 168, 255, 0.12 + (0.15 * pulse)));
        canvas.drawCircle(pos, 10.0 + (5.0 * pulse), glowPaint);

        nodePaint.color = isError
            ? const Color(0xFFFF2A55)
            : (isLayer ? const Color(0xFF00FF66) : const Color(0xFF00A8FF));
        canvas.drawCircle(pos, node.radius, nodePaint);

        // Center white core
        nodePaint.color = Colors.white;
        canvas.drawCircle(pos, node.radius * 0.5, nodePaint);
      } else {
        nodePaint.color = isError
            ? Color.fromRGBO(255, 42, 85, 0.45 + (0.35 * pulse))
            : (isLayer
                ? Color.fromRGBO(0, 255, 102, 0.4 + (0.3 * pulse))
                : Color.fromRGBO(0, 150, 255, 0.4 + (0.3 * pulse)));
        canvas.drawCircle(pos, node.radius, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SwiftMeshPainter oldDelegate) => true;
}

