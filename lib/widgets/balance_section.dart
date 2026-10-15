import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class BalanceSection extends StatefulWidget {
  final double? initialValue;
  final Function(double)? onChanged;
  final bool isLayer;

  const BalanceSection({
    super.key,
    this.initialValue,
    this.onChanged,
    this.isLayer = false,
  });

  @override
  State<BalanceSection> createState() => _BalanceSectionState();
}

class _BalanceSectionState extends State<BalanceSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double? _value;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: _value ?? 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (_value != null && _value! > 0) {
      _hasAnimated = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BalanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _value = widget.initialValue;
        _hasAnimated = true;
      });
      _controller.reset();
      _animation = Tween<double>(begin: 0, end: widget.initialValue ?? 0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      if (widget.initialValue != null && widget.initialValue! > 0) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    final formatter = NumberFormat('#,##0', 'de_DE');
    return formatter.format(value).replaceAll(',', '.');
  }

  Future<void> _editAmount() async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _EditAmountDialog(initialValue: _value ?? 0, isLayer: widget.isLayer),
    );

    if (result != null) {
      setState(() {
        _value = result;
        _hasAnimated = true;
      });
      _controller.reset();
      _animation = Tween<double>(begin: 0, end: result).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward();

      if (widget.onChanged != null) {
        widget.onChanged!(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    final cardBg = isLayer
        ? const Color(0xC404150A)
        : const Color(0xC4081324);
    final borderColor = isLayer
        ? const Color(0x3D00FF66)
        : const Color(0x3D00A8FF);
    final neonColor = isLayer ? LayerColors.accentNeon : AppColors.accentGreen;
    final accentColor = isLayer ? LayerColors.accentNeon : AppColors.accentBlue;
    final textSecondary = isLayer ? const Color(0xFF86E7A4) : const Color(0xFF94A3B8);
    final textMuted = isLayer ? const Color(0xFF3B7A4E) : const Color(0xFF475569);
    final hasValue = _value != null && _value! > 0;

    // Derived exchange rates
    final curVal = _value ?? 0;
    final usdVal = curVal * 1.08;
    final gbpVal = curVal * 0.85;
    final chfVal = curVal * 0.95;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: neonColor.withValues(alpha: 0.08),
            blurRadius: 18,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top glowing accent line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    neonColor.withValues(alpha: 0.9),
                    accentColor.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                // Top telemetry row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: neonColor.withValues(alpha: 0.12),
                            border: Border.all(color: neonColor.withValues(alpha: 0.35)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            ':32A: SETTLED VALUE',
                            style: GoogleFonts.jetBrainsMono(
                              color: neonColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TOTAL ACCOUNT BALANCE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: textSecondary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'ISO 20022 / EUR RTGS',
                        style: GoogleFonts.jetBrainsMono(
                          color: accentColor,
                          fontSize: 9,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Grand Glowing Balance
                InkWell(
                  onTap: _editAmount,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => Text(
                        hasValue && _hasAnimated
                            ? '€ ${_formatNumber(_animation.value)},00'
                            : '€ 0,00',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: neonColor,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: neonColor.withValues(alpha: 0.65),
                              blurRadius: 22,
                            ),
                            Shadow(
                              color: neonColor.withValues(alpha: 0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  hasValue ? 'ONE TRILLION EURO ONLY — UNCONDITIONAL RSDR GUARANTEED' : 'NO SETTLED FUNDS DEPOSITED',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    color: hasValue ? textSecondary : textMuted,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        borderColor.withValues(alpha: 0.1),
                        borderColor,
                        borderColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Converted Multi-Currency Telemetry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _currencyItem(
                      ':32B: USD',
                      hasValue ? '\$ ${_formatNumber(usdVal)},00' : '\$ 0,00',
                      isLayer,
                    ),
                    Container(width: 1, height: 28, color: borderColor.withValues(alpha: 0.4)),
                    _currencyItem(
                      ':32B: GBP',
                      hasValue ? '£ ${_formatNumber(gbpVal)},00' : '£ 0,00',
                      isLayer,
                    ),
                    Container(width: 1, height: 28, color: borderColor.withValues(alpha: 0.4)),
                    _currencyItem(
                      ':32B: CHF',
                      hasValue ? 'CHF ${_formatNumber(chfVal)},00' : 'CHF 0,00',
                      isLayer,
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

  Widget _currencyItem(String tagAndCode, String value, bool isLayer) {
    final textSecondary = isLayer ? const Color(0xFF86E7A4) : const Color(0xFF94A3B8);
    final textPrimary = isLayer ? LayerColors.textPrimary : AppColors.textPrimary;

    return Column(
      children: [
        Text(
          tagAndCode,
          style: GoogleFonts.jetBrainsMono(
            color: textSecondary,
            fontSize: 9.5,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            color: textPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _EditAmountDialog extends StatefulWidget {
  final double initialValue;
  final bool isLayer;
  const _EditAmountDialog({required this.initialValue, this.isLayer = false});

  @override
  State<_EditAmountDialog> createState() => _EditAmountDialogState();
}

class _EditAmountDialogState extends State<_EditAmountDialog> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialValue > 0 ? widget.initialValue.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isLayer ? LayerColors.accentNeon : AppColors.accentGreen;
    final dialogBg = widget.isLayer ? LayerColors.bgCardSolid : const Color(0xFF0C1626);

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
      ),
      title: Text(
        ':32A: SET TOTAL BALANCE',
        style: GoogleFonts.jetBrainsMono(
          color: accentColor,
          fontSize: 13,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter settled liquid funds (EUR):',
            style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8), fontSize: 11),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.jetBrainsMono(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              prefixText: '€ ',
              prefixStyle: GoogleFonts.jetBrainsMono(
                color: accentColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              hintText: '1000000000000',
              hintStyle: GoogleFonts.jetBrainsMono(color: const Color(0xFF475569)),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: accentColor.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCEL',
            style: GoogleFonts.jetBrainsMono(color: const Color(0xFF64748B)),
          ),
        ),
        TextButton(
          onPressed: () {
            final value = double.tryParse(_ctrl.text) ?? 0;
            Navigator.pop(context, value);
          },
          child: Text(
            'SAVE BALANCE',
            style: GoogleFonts.jetBrainsMono(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
