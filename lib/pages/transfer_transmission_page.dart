import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/swift_network_background.dart';
import 'settlement_loading_page.dart';

class TransferTransmissionPage extends StatefulWidget {
  final String transferId;
  final String transferType;
  final String recipient;
  final String iban;
  final String bic;
  final String bankName;
  final String bankAddress;
  final double amount;
  final String purpose;
  final bool isLayer;

  const TransferTransmissionPage({
    super.key,
    required this.transferId,
    required this.transferType,
    required this.recipient,
    required this.iban,
    required this.bic,
    this.bankName = '',
    this.bankAddress = '',
    required this.amount,
    this.purpose = '',
    this.isLayer = false,
  });

  @override
  State<TransferTransmissionPage> createState() => _TransferTransmissionPageState();
}

class _ConsoleLineData {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final bool isValidRow;
  final String? validPrefix;

  _ConsoleLineData(
    this.text, {
    this.color,
    this.fontWeight,
    this.isValidRow = false,
    this.validPrefix,
  });
}

class _TransferTransmissionPageState extends State<TransferTransmissionPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _cursorBlinkController;
  late ScrollController _scrollController;
  bool _autoScrolledToBottom = false;
  late String _sessionId;
  late String _uetr;
  late String _trn;
  late String _chk;
  late String _pkiSignature;
  late String _f20;
  late String _f32Date;
  late String _msgRef;
  late String _mir;
  late String _mor;
  late String _dateTimeStr;

  // 10 MENIT PROGRESS TRANSMISI
  static const Duration _totalDuration = Duration(minutes: 10);

  @override
  void initState() {
    super.initState();

    final r = Random();
    _sessionId = 'oc${r.nextInt(899999) + 100000}a';
    _uetr = _generateUetr();
    final now = DateTime.now();
    _trn = 'MT103-${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}-${r.nextInt(8999) + 1000}';
    _chk = '${r.nextInt(899999999) + 100000000}${r.nextInt(899999999) + 100000000}${r.nextInt(89999) + 10000}';
    _pkiSignature = '${r.nextInt(899999999) + 1000000000}';
    _f20 = 'DE${r.nextInt(899999999) + 100000000}${r.nextInt(89999) + 10000}';
    _f32Date = '${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year}';
    _msgRef = '${r.nextInt(899999999) + 1000000000}-${r.nextInt(899999999) + 1000000000}';

    final bicCode = widget.bic.isNotEmpty ? widget.bic.toUpperCase().trim() : 'BRINIDJA';
    final yearShort = now.year.toString().substring(2);
    _mir = '$yearShort${_twoDigits(now.month)}${_twoDigits(now.day)}DEUTDEFFAXXX${r.nextInt(899999999) + 1000000000}';
    _mor = '$yearShort${_twoDigits(now.month)}${_twoDigits(now.day)}${bicCode}XXXX${r.nextInt(899999999) + 1000000000}';
    _dateTimeStr = '${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';

    _scrollController = ScrollController();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _cursorBlinkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: _totalDuration,
      vsync: this,
    )..addListener(() {
        if (_scrollController.hasClients) {
          if (_progressController.value >= 0.999 && !_autoScrolledToBottom) {
            _autoScrolledToBottom = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                );
              }
            });
          } else if (_scrollController.position.maxScrollExtent - _scrollController.offset < 200) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        }
      })..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _cursorBlinkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _generateUetr() {
    final r = Random();
    String hex(int len) {
      const chars = '0123456789abcdef';
      return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
    }
    return '${hex(8)}-${hex(4)}-4${hex(3)}-8${hex(3)}-${hex(12)}';
  }

  String _formatAmount(double value) {
    final formatter = value.toStringAsFixed(2);
    final parts = formatter.split('.');
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final whole = parts[0].replaceAllMapped(reg, (m) => '${m[1]},');
    return '$whole.${parts[1]}';
  }

  String _swiftInputText() {
    final t = widget.transferType.toUpperCase().trim();
    if (t.contains('SWIFT')) return t;
    return 'SWIFT $t';
  }

  String _numberToWords(double amount) {
    final intVal = amount.floor();
    if (intVal == 0) return '(ZERO EUROS)';

    final units = [
      '', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE',
      'TEN', 'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN', 'SIXTEEN',
      'SEVENTEEN', 'EIGHTEEN', 'NINETEEN'
    ];
    final tens = [
      '', '', 'TWENTY', 'THIRTY', 'FORTY', 'FIFTY', 'SIXTY', 'SEVENTY', 'EIGHTY', 'NINETY'
    ];

    String convertChunk(int n) {
      String res = '';
      if (n >= 100) {
        res += '${units[n ~/ 100]} HUNDRED ';
        n %= 100;
      }
      if (n >= 20) {
        res += tens[n ~/ 10];
        if (n % 10 > 0) res += '-${units[n % 10]}';
        res += ' ';
      } else if (n > 0) {
        res += '${units[n]} ';
      }
      return res.trim();
    }

    int temp = intVal;
    String words = '';

    if (temp >= 1000000000000) {
      final t = temp ~/ 1000000000000;
      words += '${convertChunk(t)} TRILLION ';
      temp %= 1000000000000;
    }
    if (temp >= 1000000000) {
      final b = temp ~/ 1000000000;
      words += '${convertChunk(b)} BILLION ';
      temp %= 1000000000;
    }
    if (temp >= 1000000) {
      final m = temp ~/ 1000000;
      words += '${convertChunk(m)} MILLION ';
      temp %= 1000000;
    }
    if (temp >= 1000) {
      final th = temp ~/ 1000;
      words += '${convertChunk(th)} THOUSAND ';
      temp %= 1000;
    }
    if (temp > 0) {
      words += '${convertChunk(temp)} ';
    }

    return '(${words.trim()} EUROS)';
  }

  String _formatBankAddress(String input, int indentSpaces) {
    if (input.trim().isEmpty) return '';
    final indent = ' ' * indentSpaces;
    // For indent <= 25 (e.g. Section 1), max chars allowed before wrapping is 105
    // For indent > 25 (e.g. F57A with 47 spaces), max chars allowed before wrapping is 60 so that line + indent <= 107
    final maxLineLen = indentSpaces <= 25 ? 105 : 60;

    String text = input.trim();
    // Normalize newlines if needed
    if (text.contains('BOGOR, JAWABARAT, INDONESIA') && !text.contains('\nBOGOR, JAWABARAT, INDONESIA')) {
      text = text.replaceFirst('BOGOR, JAWABARAT, INDONESIA', '\nBOGOR, JAWABARAT, INDONESIA');
    } else if (text.contains('BOGOR, JAWA BARAT BOGOR') && !text.contains('\n')) {
      text = text.replaceFirst('BOGOR, JAWA BARAT BOGOR', 'BOGOR, JAWA BARAT\nBOGOR');
    }

    final rawLines = text.split('\n');
    final allSplitLines = <String>[];

    for (final rawLine in rawLines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.length <= maxLineLen) {
        allSplitLines.add(trimmed);
      } else {
        // Wrap long line into multiple lines <= maxLineLen
        String remaining = trimmed;
        while (remaining.length > maxLineLen) {
          int splitIdx = -1;

          final commaIdx = remaining.lastIndexOf(',', maxLineLen);
          if (commaIdx != -1 && commaIdx >= 20) {
            splitIdx = commaIdx + 1;
          } else {
            final spaceIdx = remaining.lastIndexOf(' ', maxLineLen);
            if (spaceIdx != -1 && spaceIdx >= 20) {
              splitIdx = spaceIdx;
            } else {
              splitIdx = maxLineLen;
            }
          }

          final chunk = remaining.substring(0, splitIdx).trim();
          if (chunk.isNotEmpty) {
            allSplitLines.add(chunk);
          }
          remaining = remaining.substring(splitIdx).trim();
        }
        if (remaining.isNotEmpty) {
          allSplitLines.add(remaining);
        }
      }
    }

    final formattedLines = <String>[];
    for (int i = 0; i < allSplitLines.length; i++) {
      final line = allSplitLines[i];
      if (i == 0) {
        formattedLines.add(line);
      } else {
        formattedLines.add('$indent$line');
      }
    }

    return formattedLines.join('\n');
  }

  Map<String, String> _getBankReceiverInfo(String bic) {
    if (widget.bankName.isNotEmpty) {
      final customAddr = widget.bankAddress.isNotEmpty
          ? widget.bankAddress
          : 'MAIN BRANCH SETTLEMENT DESK, FINANCIAL WIRE NETWORK,\nSWIFT CLEARING CENTER';
      return {
        'name': widget.bankName.toUpperCase().trim(),
        'address': _formatBankAddress(customAddr, 25),
        'addressShort': _formatBankAddress(customAddr, 47),
      };
    }

    final upper = bic.toUpperCase().trim();
    if (upper.contains('BRIN') || upper.contains('BRI')) {
      const rawBriAddr = 'BANK BRI UNIT SEMPLAK JI. RAYA SEMPLAK NO.36, RT.02/RW.01, SEMPLAK, KEC. BOGOR BAR., KOTA BOGOR, JAWA BARAT\nBOGOR, JAWABARAT, INDONESIA 16114';
      return {
        'name': 'PT. BANK RAKYAT INDONESIA (PERSERO) TBK',
        'address': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawBriAddr, 25),
        'addressShort': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawBriAddr, 47),
      };
    } else if (upper.contains('BCA') || upper.contains('CENA')) {
      const rawBcaAddr = 'MENARA BCA, GRAND INDONESIA, JL. M.H. THAMRIN NO. 1,\nJAKARTA PUSAT, DKI JAKARTA, INDONESIA 10310';
      return {
        'name': 'PT. BANK CENTRAL ASIA TBK',
        'address': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawBcaAddr, 25),
        'addressShort': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawBcaAddr, 47),
      };
    } else if (upper.contains('BMRI') || upper.contains('MAND')) {
      const rawMandiriAddr = 'PLAZA MANDIRI, JL. JEND. GATOT SUBROTO KAV. 36-38,\nJAKARTA SELATAN, DKI JAKARTA, INDONESIA 12190';
      return {
        'name': 'PT. BANK MANDIRI (PERSERO) TBK',
        'address': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawMandiriAddr, 25),
        'addressShort': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawMandiriAddr, 47),
      };
    } else if (upper.contains('BNI') || upper.contains('BNIN')) {
      const rawBniAddr = 'GRHA BNI, JL. JEND. SUDIRMAN KAV. 1, KARET TENGSIN,\nTANAH ABANG, JAKARTA PUSAT, INDONESIA 10220';
      return {
        'name': 'PT. BANK NEGARA INDONESIA (PERSERO) TBK',
        'address': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawBniAddr, 25),
        'addressShort': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawBniAddr, 47),
      };
    } else if (upper.contains('DEUT')) {
      const rawDeutAddr = 'TAUNUSANLAGE 12, 60254 FRANKFURT AM MAIN, GERMANY';
      return {
        'name': 'DEUTSCHE BANK AG',
        'address': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawDeutAddr, 25),
        'addressShort': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawDeutAddr, 47),
      };
    }

    final displayBic = upper.isNotEmpty ? upper : 'INTERBANK';
    const rawDefaultAddr = 'MAIN BRANCH SETTLEMENT DESK, FINANCIAL WIRE NETWORK,\nSWIFT CLEARING CENTER';
    return {
      'name': 'BANK $displayBic INTERNATIONAL',
      'address': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawDefaultAddr, 25),
      'addressShort': _formatBankAddress(widget.bankAddress.isNotEmpty ? widget.bankAddress : rawDefaultAddr, 47),
    };
  }

  String _centerDivider(String title, [int totalWidth = 120]) {
    final titleLen = title.length;
    if (titleLen >= totalWidth) return title;
    final remaining = totalWidth - titleLen;
    final leftDashes = remaining ~/ 2;
    final rightDashes = remaining - leftDashes;
    return '${'-' * leftDashes}$title${'-' * rightDashes}';
  }

  List<_ConsoleLineData> _generateAllDocumentLines() {
    final recipientName = widget.recipient.isNotEmpty ? widget.recipient.toUpperCase().trim() : 'IMAN KUKUH PRIBADI';
    final recipientIban = widget.iban.isNotEmpty ? widget.iban.toUpperCase().trim() : '0811-01-021431-50-8';
    final recipientBic = widget.bic.isNotEmpty ? widget.bic.toUpperCase().trim() : 'BRINIDJA';
    final amountFormatted = _formatAmount(widget.amount);
    final swiftType = _swiftInputText();
    final purposeText = widget.purpose.isNotEmpty
        ? widget.purpose.toUpperCase().trim()
        : 'INVESTMENT AGREEMENT NO. : $swiftType 10T/01182025';

    final bankInfo = _getBankReceiverInfo(recipientBic);
    final bankReceiverName = bankInfo['name']!;
    final bankReceiverAddr = bankInfo['address']!;
    final bankReceiverAddrShort = bankInfo['addressShort']!;
    final amountWords = _numberToWords(widget.amount);
    const accentGreen = Color(0xFF00FF66);
    const accentCyan = Color(0xFF00E5FF);
    const headerDivider = Color(0xFF334155);

    return [
      // ==========================================
      // BAGIAN 1 (ACK & SWIFT HEADER)
      // ==========================================
      _ConsoleLineData('------------------------------------------------------------------------------------------------------------------------', color: headerDivider),
      _ConsoleLineData('MESSAGE REFERENCE: $_msgRef                                                           CUSTOMER\'S COPY', fontWeight: FontWeight.w700, color: Colors.white),
      _ConsoleLineData(_centerDivider('INSTANCE TYPE AND TRANSMISSION'), color: headerDivider),
      _ConsoleLineData('*** NOTIFICATION (TRANSMISSION) OF ORIGINAL SENT TO SWIFT (ACK)', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('*** NETWORK DELIVERY STATUS       : RECEIVED', color: accentGreen),
      _ConsoleLineData('*** PRIORITY/DELIVERY            : URGENT SAME DAY', color: const Color(0xFFFFCC00)),
      _ConsoleLineData('*** MESSAGE INPUT REFERENCE      : 1735 $_mir', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('*** MESSAGE OUTPUT REFERENCE     : 1735 $_mor', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData(_centerDivider('SWIFT MESSAGE HEADER'), color: headerDivider),
      _ConsoleLineData('***SWIFT INPUT         : $swiftType', color: Colors.white, fontWeight: FontWeight.w700),
      _ConsoleLineData('FROM:', color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
      _ConsoleLineData('***SENDER              : DEUTDEFFAXXX', color: accentCyan),
      _ConsoleLineData('***BANK NAME           : DEUTSCHE BANK AG', color: Colors.white),
      _ConsoleLineData('***BANK ADDRESS        : TAUNUSANLAGE 12, 60254 FRANKFURT AM MAIN, GERMANY', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('***ACCOUNT NAME        : AVANTULO S.A.', color: Colors.white),
      _ConsoleLineData('***ACCOUNT NUMBER      : DE60500700100361982244', color: accentGreen),
      _ConsoleLineData('***SWIFT CODE          : DEUTDEFFAXXX', color: accentCyan),
      _ConsoleLineData('TO:', color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600),
      _ConsoleLineData('***BANK NAME           : $bankReceiverName', color: Colors.white),
      _ConsoleLineData('***BANK ADDRESS        : $bankReceiverAddr', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('***ACCOUNT NAME        : $recipientName', color: Colors.white),
      _ConsoleLineData('***ACCOUNT NUMBER      : $recipientIban', color: accentGreen),
      _ConsoleLineData('***SWIFT CODE          : $recipientBic', color: accentCyan),
      _ConsoleLineData(_centerDivider('MESSAGE TEXT'), color: headerDivider),
      _ConsoleLineData('*** F20:   TRANSACTION REFERENCE CODE        : $_f20', color: accentCyan, fontWeight: FontWeight.w600),
      _ConsoleLineData('*** F23B:  BANK OPERATION CODE               : CRED', color: Colors.white),
      _ConsoleLineData('*** F32A:  CURRENCY/INSTRUCTED', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           DATE                              : $_f32Date', color: Colors.white),
      _ConsoleLineData('           CURRENCY                          : EURO', color: Colors.white),
      _ConsoleLineData('           AMOUNT                            : \u20AC$amountFormatted', color: accentGreen, fontWeight: FontWeight.w800),
      _ConsoleLineData('*** F33B:  CURRENCY/ORIGINAL ORDERED AMOUNT', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           CURRENCY                          : EURO', color: Colors.white),
      _ConsoleLineData('           AMOUNT                            : \u20AC$amountFormatted', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('*** F50K:  ORDERING CUSTOMER-NAME & ADDRESS', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           ACCOUNT NUMBER                    : DE60500700100361982244', color: accentGreen),
      _ConsoleLineData('           ACCOUNT NAME                      : AVANTULO S.A.', color: Colors.white),
      _ConsoleLineData('           ACCOUNT ADDRESS                   : AVANTULO TOWER SI, II, II & SOHO CENTRE CALLE 50, BANK DIS, PANAMA CITY, PANAMA', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('*** F52A:  ORDERING INSTITUTION', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           SENDER                            : DEUTDEFFAXXX', color: accentCyan),
      _ConsoleLineData('           BANK NAME                         : DEUTSCHE BANK AG', color: Colors.white),
      _ConsoleLineData('           BANK ADDRESS                      : TAUNUSANLAGE 12, 60254 FRANKFURT AM MAIN, GERMANY', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('*** F57A:  ACCOUNT WITH INSTITUTION', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           RECEIVER SWIFT                    : $recipientBic', color: accentCyan),
      _ConsoleLineData('           BANK RECEIVER                     : $bankReceiverName', color: Colors.white),
      _ConsoleLineData('           BANK ADDRESS                      : $bankReceiverAddrShort', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('*** F59    BENEFICIARY CUSTOMER', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           ACCOUNT NAME                      : $recipientName', color: Colors.white),
      _ConsoleLineData('           ACCOUNT NUMBER                    : $recipientIban', color: accentGreen),
      _ConsoleLineData('*** F70:   REMITTANCE INFORMATION            : $purposeText', color: const Color(0xFFE2E8F0)),

      // ====================================================
      // BAGIAN 2 (NARRATIVE & OFFICERS)
      // ====================================================
      _ConsoleLineData('*** F71A:  DETAILS OF CHARGES                : OUR', color: Colors.white),
      _ConsoleLineData('*** F72:   SENDER TO RECEIVER INFORMATION    : FOR INVESTMENT', color: Colors.white),
      _ConsoleLineData('           /// PLEASE ADVISE THE BENEFICIARY OF THIS SWIFT THIS TRANSFER IS VALID FOR PAYMENT', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           /// UPON IDENTIFICATION, THE DAY OF RECEIPT. THIS IRREVOCABLE CASH BACKED SWIFT', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('           /// $swiftType CAN BE RELIED UPON FOR FULL CASH.', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('*** F77B:  REGULATORY REPORTING: \u20AC$amountFormatted $amountWords', color: Colors.white, fontWeight: FontWeight.w700),
      _ConsoleLineData('*** F79:   NARRATIVE', color: accentCyan, fontWeight: FontWeight.w700),
      _ConsoleLineData('/// FOR AND ON BEHALF OF OUR CLIENT AVANTULO S.A., WITH ACCOUNT NUMBER: DE60500700100361982244, WE DEUTSCHE BANK AG, TAUNUSANLAGE 12, 60254 FRANKFURT AM MAIN, GERMANY HEREBY CONFIRM WITH FULL BANKING RESPONSIBILITY THAT THE ABOVE FUNDS ARE GOOD, CLEAN, CLEAR AND TAXED FUNDS OF NON-CRIMINAL ORIGIN, FREE FROM ANY LIENS OR ENCUMBRANCES AND PAID FOR INVESTMENTS PURPOSES $swiftType WITH UETR CODE IS FOR IMMEDIATE CASH-INSTANT SAME DAY VALUE AND NO MAIL OR SWIFT CONFIRMATION SHALL FOLLOW.', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('FOR AND ON BEHALF OF DEUTSCHE BANK AG, TAUNUSANLAGE 12, 60254 FRANKFURT AM MAIN, GERMANY.', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('AUTOMATED MESSAGE DOESN\'T NEED ANY SIGNATURE', color: const Color(0xFF64748B)),
      _ConsoleLineData('------------------------------------------------------------------------------------------------------------------------', color: headerDivider),
      _ConsoleLineData('AUTHORIZED OFFICER 1: MR. JAMES VON MOLTKE, CHIEF FINANCIAL OFFICER (PIN: J78414M )', color: Colors.white, fontWeight: FontWeight.w600),
      _ConsoleLineData('AUTHORIZED OFFICER 2: MR. CARSTEN LEWERENZ, HEAD OF BUSINESS CUSTOMERS (PIN: 53329)', color: Colors.white, fontWeight: FontWeight.w600),
      _ConsoleLineData('FOR AND ON BEHALF OF DEUTSCHE BANK AG', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('TAUNUSANLAGE 12, 60254 FRANKFURT AM MAIN, GERMANY.', color: const Color(0xFF64748B)),

      // ====================================================
      // BAGIAN 3 (TRAILER, INTERVENSI, 14 VALID)
      // ====================================================
      _ConsoleLineData(_centerDivider('MESSAGE TRAILER'), color: headerDivider),
      _ConsoleLineData('CHK:$_chk', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('PKI-SIGNATURE:$_pkiSignature', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('TRACKING CODE:$_uetr', color: accentCyan),
      _ConsoleLineData(_centerDivider('INTERVENTIONS'), color: headerDivider),
      _ConsoleLineData('CONFIRMED AND RECEIVED', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('TRANSACTION STATUS: APPROVED', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('SWIFT MESSAGE: $swiftType', color: Colors.white),
      _ConsoleLineData('SWIFT COVERAGE: YES', color: accentGreen),
      _ConsoleLineData('CATEGORY: NETWORK REPORT', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('CREATION DATE & TIME: $_dateTimeStr', color: Colors.white),
      _ConsoleLineData('APPLICATION: SWIFT', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('OPERATION: SYSTEM', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('RECEIVER: $recipientBic', color: accentCyan),
      _ConsoleLineData('TEXT:{1:F01DEUTDEFFAXXX$_mir}{2:I103${recipientBic}XXXXU}3:119:STP}}', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('{4:$_f20}5:{MAC:00000000}{PDE:}{S:{SAC:}}{COP:P}}', color: const Color(0xFFCBD5E1)),
      _ConsoleLineData('------------------------------------------------------------------------------------------------------------------------', color: headerDivider),
      _ConsoleLineData('ANSWERBACK AND ACKNOWLEDGMENT MESSAGE AUTOMATED FILE TRANSFER (AFT) GATEWAY RESPONSE VALIDATION', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('    SERVICE PROVIDER LOG/APPLICATION GENERATED REPORT ACKNOWLEDGMENT AND AUTHENTICATION', color: const Color(0xFF94A3B8)),
      _ConsoleLineData('        ACK/NAG DELIVERY FTA/FTI CONFIRMATION STATEMENT PASS/ACK STATUS', color: const Color(0xFF94A3B8)),

      // 14 VALID ROWS
      _ConsoleLineData('0050 CNT, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0050 CNT'),
      _ConsoleLineData('0060 RFF-DTM, ---------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0060 RFF-DTM'),
      _ConsoleLineData('0070 RFF, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0070 RFF'),
      _ConsoleLineData('0080 DTM, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0080 DTM'),
      _ConsoleLineData('0090 NAD-CTA-COM, ------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0090 NAD-CTA-COM'),
      _ConsoleLineData('0100 NAD, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0100 NAD'),
      _ConsoleLineData('0120 COM, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0120 COM'),
      _ConsoleLineData('0130 ERC-FTX-5G4, ------------------------------------------------------------------------------ VALID', isValidRow: true, validPrefix: '0130 ERC-FTX-5G4'),
      _ConsoleLineData('0140 ERC, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0140 ERC'),
      _ConsoleLineData('0150 FTX, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0150 FTX'),
      _ConsoleLineData('0160 RFF-FTX, ---------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0160 RFF-FTX'),
      _ConsoleLineData('0170 REF, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0170 REF'),
      _ConsoleLineData('0180 FTX, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0180 FTX'),
      _ConsoleLineData('0190 UNT, -------------------------------------------------------------------------------------- VALID', isValidRow: true, validPrefix: '0190 UNT'),

      _ConsoleLineData('------------------------------------------------------------------------------------------------------------------------', color: headerDivider),
      _ConsoleLineData('{XMT DELIVERY REPORT}', fontWeight: FontWeight.w700, color: accentCyan),
      _ConsoleLineData('MESSAGE TYPE: $swiftType', color: Colors.white),
      _ConsoleLineData('PRIORITY: URGENT', color: const Color(0xFFFFCC00)),
      _ConsoleLineData('RECEIVED: $recipientBic', color: accentCyan),
      _ConsoleLineData('TRANSACTION REFERENCE NUMBER: $_f20', color: Colors.white),
      _ConsoleLineData('TRANSACTION STATUS: APPROVED', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('AMOUNT TRANSFERRED: \u20AC$amountFormatted', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('DATE OF EXECUTION: $_dateTimeStr', color: Colors.white),
      _ConsoleLineData('INPUT-OUTPUT: ACK NAK DUP AUTH', color: const Color(0xFF94A3B8)),
      _ConsoleLineData(_centerDivider('CONFIRMED AND RECEIVED'), color: headerDivider),
      _ConsoleLineData('TRANSACTION STATUS: APPROVED', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('AMOUNT TRANSFERED: \u20AC$amountFormatted', color: accentGreen, fontWeight: FontWeight.w700),
      _ConsoleLineData('DATE OF EXECUTION: $_dateTimeStr', color: Colors.white),
      _ConsoleLineData(_centerDivider('END OF TRANSMISSION'), color: headerDivider),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    final cardBg = isLayer
        ? const Color(0xC2041409)
        : const Color(0xC4081324);
    final borderColor = isLayer
        ? const Color(0x5500FF66)
        : const Color(0x5500A8FF);
    final glowColor = isLayer
        ? const Color(0xFF00FF66)
        : const Color(0xFF00A8FF);

    return Scaffold(
      backgroundColor: isLayer ? const Color(0xFF020904) : const Color(0xFF03070E),
      body: SwiftNetworkBackground(
        showHud: true,
        isLayer: isLayer,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                width: 1100,
                height: 800,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x88000000),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // WINDOW TITLE BAR
                    _buildTitleBar(),

                    // GLOWING PROGRESS BAR (0% - 100% OVER 10 MINUTES)
                    _buildProgressBar(),

                    // DYNAMIC TYPEWRITER CONSOLE BODY
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        child: _buildTypewriterConsoleBody(),
                      ),
                    ),

                    // BOTTOM STATUS BAR
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // TYPEWRITER EFFECT: Left-to-right character-by-character stream
  // ==============================================================
  Widget _buildTypewriterConsoleBody() {
    final allLines = _generateAllDocumentLines();
    final totalLines = allLines.length;
    final isLayer = widget.isLayer;
    final accentGreen = isLayer ? const Color(0xFF00FF66) : const Color(0xFF00FF66);

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final p = _progressController.value;

        return DefaultTextStyle(
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12.5,
            height: 1.48,
            color: const Color(0xFFF1F5F9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...List.generate(totalLines, (index) {
                final line = allLines[index];
                
                final startP = 0.005 + (index / totalLines) * 0.945;
                final endP = 0.005 + ((index + 1) / totalLines) * 0.945;

                if (p < startP) {
                  return const SizedBox.shrink();
                }

                final isCurrentlyTyping = p >= startP && p < endP;
                final isFullyTyped = p >= endP;

                final fullLength = line.text.length;
                final fraction = isFullyTyped
                    ? 1.0
                    : ((p - startP) / (endP - startP)).clamp(0.0, 1.0);
                final visibleChars = (fullLength * fraction).floor().clamp(0, fullLength);
                final typedText = line.text.substring(0, visibleChars);

                final textColor = line.color ?? const Color(0xFFF1F5F9);
                final textWeight = line.fontWeight ?? FontWeight.w400;

                if (line.isValidRow && isFullyTyped) {
                  return _buildDocValidRow(line.validPrefix ?? line.text);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.8),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12.5,
                        height: 1.48,
                        color: textColor,
                        fontWeight: textWeight,
                      ),
                      children: [
                        TextSpan(text: typedText),
                        if (isCurrentlyTyping)
                          TextSpan(
                            text: ' █',
                            style: TextStyle(
                              color: accentGreen,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              // Terminal Prompt & Smooth Transitioning Submit Button (Hanya muncul saat semua teks selesai diketik)
              if (p >= 0.95) ...[
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'root@swift-gateway:~# ',
                      style: GoogleFonts.jetBrainsMono(
                        color: accentGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInQuad,
                      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final isBtn = child.key == const ValueKey('submit_button');
                        if (isBtn) {
                          return FadeTransition(
                            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.06, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.88,
                                  end: 1.0,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                                child: child,
                              ),
                            ),
                          );
                        }
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: p < 0.999
                          ? AnimatedBuilder(
                              key: const ValueKey('blinking_cursor'),
                              animation: _cursorBlinkController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _cursorBlinkController.value < 0.5 ? 1.0 : 0.0,
                                  child: Container(
                                    width: 8,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: accentGreen,
                                    ),
                                  ),
                                );
                              },
                            )
                          : AnimatedBuilder(
                              key: const ValueKey('submit_button'),
                              animation: _pulseController,
                              builder: (context, child) {
                                final glow = _pulseController.value;
                                return InkWell(
                                  onTap: _finalizeTransfer,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: accentGreen,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentGreen.withValues(alpha: 0.45 + (0.45 * glow)),
                                          blurRadius: 12 + (12 * glow),
                                          spreadRadius: 1 + (3 * glow),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.verified, color: Color(0xFF000000), size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'PROCEED TO SETTLEMENT',
                                          style: GoogleFonts.jetBrainsMono(
                                            color: const Color(0xFF000000),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocValidRow(String code) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.2),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$code,',
              style: GoogleFonts.jetBrainsMono(color: const Color(0xFFCBD5E1), fontSize: 12.5),
            ),
          ),
          Expanded(
            child: Text(
              '--------------------------------------------------------------------------------------',
              style: GoogleFonts.jetBrainsMono(color: const Color(0xFF334155), fontSize: 12.5),
              overflow: TextOverflow.clip,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'VALID',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF22FF88),
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
              letterSpacing: 1.2,
              shadows: const [
                Shadow(
                  color: Color(0xFF00FF66),
                  blurRadius: 7,
                ),
                Shadow(
                  color: Color(0x6600FF66),
                  blurRadius: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    final isLayer = widget.isLayer;
    final barBg = isLayer ? const Color(0xDF030E07) : const Color(0xDF060E1A);
    final borderColor = isLayer ? const Color(0x3300FF66) : const Color(0x3300A8FF);
    final accentColor = isLayer ? const Color(0xFF00FF66) : const Color(0xFF00A8FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: barBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
              const SizedBox(width: 16),
              Text(
                'tty://swiftnet-wire/session-$_sessionId',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  isLayer ? 'SWIFT.NET LAYER QUANTUM' : 'ALLIANCE ACCESS v7.4.2 // FIN WIRE',
                  style: GoogleFonts.jetBrainsMono(
                    color: accentColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF66).withValues(alpha: 0.1),
                  border: Border.all(color: const Color(0xFF00FF66).withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'SECURE TRANSMISSION ACTIVE',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF00FF66),
                    fontSize: 9.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(2),
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.close, color: Color(0xFF64748B), size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final isLayer = widget.isLayer;
    final barBg = isLayer ? const Color(0x99030E06) : const Color(0x99060E1A);
    final borderColor = isLayer ? const Color(0x3300FF66) : const Color(0x3300A8FF);
    const accentGreen = Color(0xFF00FF66);

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final progress = _progressController.value;
        final percent = (progress * 100).clamp(0, 100).toStringAsFixed(1);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: barBg,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CENTERED HEADER ABOVE PROGRESS BAR
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accentGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentGreen.withValues(alpha: 0.9),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TRANSACTION PROCESSING BANK : $percent%',
                      style: GoogleFonts.jetBrainsMono(
                        color: accentGreen,
                        fontSize: 13,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // PROGRESS BAR
              Container(
                height: 10,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF020705),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFF1B3D2B), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3300FF66),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final targetWidth = (constraints.maxWidth * progress).clamp(4.0, constraints.maxWidth);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: targetWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00DD77),
                              Color(0xFF00FF66),
                              Color(0xFF55FFAA),
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF00FF66),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Color(0x6600FF88),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // COMPLETION STATUS BADGE (WHEN 100%)
              if (progress >= 0.999) ...[
                const SizedBox(height: 8),
                Center(
                  child: AnimatedOpacity(
                    opacity: progress >= 0.999 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0x2200FF66),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: const Color(0x8800FF66)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF00FF66), size: 13),
                          const SizedBox(width: 6),
                          Text(
                            'SWIFT TRANSMISSION ACKNOWLEDGED & COMPLETE',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF00FF66),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final isLayer = widget.isLayer;
    final barBg = isLayer ? const Color(0xDF030E07) : const Color(0xDF060E1A);
    final borderColor = isLayer ? const Color(0x3300FF66) : const Color(0x3300A8FF);

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final isComplete = _progressController.value >= 0.999;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: barBg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
            border: Border(top: BorderSide(color: borderColor, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HSM CRYPTO: AES-256-GCM / SHA-512 SIGNED // ALLIANCE ACCESS v7.4.2',
                style: GoogleFonts.jetBrainsMono(color: const Color(0xFF64748B), fontSize: 9.5),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF66),
                      shape: BoxShape.circle,
                      boxShadow: isComplete
                          ? [
                              const BoxShadow(
                                color: Color(0xFF00FF66),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      isComplete ? 'STATUS: READY TO SUBMIT' : 'STATUS: LIVE ONLINE',
                      key: ValueKey<bool>(isComplete),
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF00FF66),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _finalizeTransfer() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SettlementLoadingPage(
          transferId: widget.transferId,
          transferType: widget.transferType,
          recipient: widget.recipient,
          iban: widget.iban,
          bic: widget.bic,
          bankName: widget.bankName,
          bankAddress: widget.bankAddress,
          amount: widget.amount,
          purpose: widget.purpose,
          trn: _trn,
          uetr: _uetr,
          isLayer: widget.isLayer,
        ),
      ),
    );
  }
}
