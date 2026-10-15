import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String? blockTag;
  final String? statusText;
  final StatusType? statusType;
  final List<InfoRow> rows;
  final bool editable;
  final bool isLayer;
  final Function(int, String)? onRowChanged;
  final VoidCallback? onEditAll;

  const InfoCard({
    super.key,
    required this.title,
    required this.rows,
    this.blockTag,
    this.statusText,
    this.statusType,
    this.editable = false,
    this.isLayer = false,
    this.onRowChanged,
    this.onEditAll,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isLayer
        ? const Color(0xBF04150A)
        : const Color(0xBF081324);
    final borderColor = isLayer
        ? const Color(0x3D00FF66)
        : const Color(0x3D00A8FF);
    final accentColor = isLayer
        ? const Color(0xFF00FF66)
        : const Color(0xFF00A8FF);
    final textPrimary = isLayer
        ? LayerColors.textPrimary
        : AppColors.textPrimary;
    final textSecondary = isLayer
        ? const Color(0xFF86E7A4)
        : const Color(0xFF94A3B8);
    final textMuted = isLayer
        ? const Color(0xFF3B7A4E)
        : const Color(0xFF475569);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top subtle cyber accent bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.8),
                    accentColor.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (blockTag != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              blockTag!,
                              style: GoogleFonts.jetBrainsMono(
                                color: accentColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11.5,
                            color: textSecondary,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (statusText != null) ...[
                          StatusBadge(text: statusText!, type: statusType ?? StatusType.active),
                          const SizedBox(width: 8),
                        ],
                        if (editable)
                          InkWell(
                            onTap: onEditAll,
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.tune, color: accentColor, size: 11),
                                  const SizedBox(width: 4),
                                  Text(
                                    'EDIT',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: accentColor,
                                      fontSize: 9.5,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        borderColor,
                        borderColor.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Data Rows
                if (rows.isEmpty)
                  InkWell(
                    onTap: onEditAll,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.fingerprint, color: textMuted, size: 24),
                          const SizedBox(height: 8),
                          Text(
                            'NO SWIFT DATA — CLICK EDIT TO CONFIGURE',
                            style: GoogleFonts.jetBrainsMono(
                              color: textMuted,
                              fontSize: 10.5,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(rows.length, (i) {
                    final row = rows[i];
                    final isEven = i % 2 == 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5.5),
                      decoration: BoxDecoration(
                        color: isEven ? Colors.white.withValues(alpha: 0.015) : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          // Field Tag (:50K:, etc.)
                          if (row.tag != null) ...[
                            Container(
                              width: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: (row.color ?? accentColor).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                row.tag!,
                                style: GoogleFonts.jetBrainsMono(
                                  color: (row.color ?? accentColor).withValues(alpha: 0.75),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Label
                          SizedBox(
                            width: 140,
                            child: Text(
                              row.label,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Value
                          Expanded(
                            child: Text(
                              row.value.isEmpty ? '—' : row.value,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11.5,
                                color: row.value.isEmpty
                                    ? textMuted
                                    : (row.color ?? textPrimary),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                fontStyle: row.value.isEmpty ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                          ),

                          if (editable) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _editSingleRow(context, i, row),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: accentColor.withValues(alpha: 0.8),
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editSingleRow(BuildContext context, int index, InfoRow row) async {
    final ctrl = TextEditingController(text: row.value);
    final accentColor = isLayer ? LayerColors.accentNeon : AppColors.accentBlue;
    final dialogBg = isLayer ? LayerColors.bgCardSolid : const Color(0xFF0C1626);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
        ),
        title: Text(
          'EDIT ${row.tag != null ? "${row.tag} " : ""}${row.label.toUpperCase()}',
          style: GoogleFonts.jetBrainsMono(
            color: accentColor,
            fontSize: 12.5,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: ctrl,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter ${row.label}...',
            hintStyle: GoogleFonts.jetBrainsMono(color: const Color(0xFF475569)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: accentColor.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: accentColor),
            ),
          ),
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
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(
              'SAVE',
              style: GoogleFonts.jetBrainsMono(
                color: isLayer ? LayerColors.accentNeon : AppColors.accentGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && onRowChanged != null) {
      onRowChanged!(index, result);
    }
  }
}

class InfoRow {
  final String? tag;
  final String label;
  final String value;
  final Color? color;

  const InfoRow({
    this.tag,
    required this.label,
    required this.value,
    this.color,
  });
}
