import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/swift_network_background.dart';
import 'account_dashboard_page.dart';

class SwiftErrorPage extends StatefulWidget {
  final String transferId;
  final String transferType;
  final String recipient;
  final String iban;
  final String bic;
  final String bankName;
  final String bankAddress;
  final double amount;
  final String purpose;
  final String trn;
  final String uetr;
  final bool isLayer;

  const SwiftErrorPage({
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
    required this.trn,
    required this.uetr,
    this.isLayer = false,
  });

  @override
  State<SwiftErrorPage> createState() => _SwiftErrorPageState();
}

class _ErrorConsoleLineData {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;

  _ErrorConsoleLineData(
    this.text, {
    this.color,
    this.fontWeight,
  });
}

class _SwiftErrorPageState extends State<SwiftErrorPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _cursorBlinkController;
  late ScrollController _scrollController;
  bool _autoScrolledToBottom = false;

  late String _sessionId;
  late String _msgRef;
  late String _dateTimeStr;
  late String _mir;
  late String _mor;
  late String _chk;
  late String _pkiSignature;

  // Typewriter streaming duration: 15 MENIT (900 SECONDS)
  static const Duration _streamDuration = Duration(minutes: 15);
  Timer? _fastTimer;
  bool _isAccelerated = false;

  @override
  void initState() {
    super.initState();

    final r = Random();
    _sessionId = 'err${r.nextInt(899999) + 100000}x';
    _msgRef = '${r.nextInt(899999999) + 1000000000}-${r.nextInt(899999999) + 1000000000}';
    _chk = '${r.nextInt(899999999) + 100000000}${r.nextInt(899999999) + 100000000}${r.nextInt(89999) + 10000}';
    _pkiSignature = '${r.nextInt(899999999) + 1000000000}';

    final now = DateTime.now();
    _dateTimeStr =
        '${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';

    final bicCode = widget.bic.isNotEmpty ? widget.bic.toUpperCase().trim() : 'BRINIDJA';
    final yearShort = now.year.toString().substring(2);
    _mir = '$yearShort${_twoDigits(now.month)}${_twoDigits(now.day)}DEUTDEFFAXXX${r.nextInt(899999999) + 1000000000}';
    _mor = '$yearShort${_twoDigits(now.month)}${_twoDigits(now.day)}${bicCode}XXXX${r.nextInt(899999999) + 1000000000}';

    _scrollController = ScrollController();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    _cursorBlinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: _streamDuration,
      vsync: this,
    )..addListener(() {
        if (_scrollController.hasClients) {
          if (_progressController.value >= 0.999 && !_autoScrolledToBottom) {
            _autoScrolledToBottom = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              }
            });
          } else {
            // Keep smoothly scrolled to bottom as new error logs appear
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        }
      })..forward();
  }

  void _accelerate() {
    if (_progressController.value >= 1.0) return;

    setState(() {
      _isAccelerated = true;
      _progressController.value = (_progressController.value + 0.05).clamp(0.0, 1.0);
    });

    if (_fastTimer == null || !_fastTimer!.isActive) {
      _progressController.stop();
      _fastTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_progressController.value >= 1.0) {
          timer.cancel();
          setState(() {
            _progressController.value = 1.0;
          });
          return;
        }
        setState(() {
          _progressController.value = (_progressController.value + 0.005).clamp(0.0, 1.0);
        });
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _cursorBlinkController.dispose();
    _scrollController.dispose();
    _fastTimer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatAmount(double value) {
    final formatter = value.toStringAsFixed(2);
    final parts = formatter.split('.');
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final whole = parts[0].replaceAllMapped(reg, (m) => '${m[1]},');
    return '$whole.${parts[1]}';
  }

  List<_ErrorConsoleLineData> _generateErrorDocumentLines() {
    final recipientName = widget.recipient.isNotEmpty
        ? widget.recipient.toUpperCase().trim()
        : 'BENEFICIARY HOLDER';
    final recipientIban = widget.iban.isNotEmpty
        ? widget.iban.toUpperCase().trim()
        : '0811-01-021431-50-8';
    final recipientBic = widget.bic.isNotEmpty
        ? widget.bic.toUpperCase().trim()
        : 'BRINIDJA';
    final bankNameDisplay = widget.bankName.isNotEmpty
        ? widget.bankName.toUpperCase().trim()
        : 'PT. BANK RAKYAT INDONESIA (PERSERO) TBK';
    final bankAddrDisplay = widget.bankAddress.isNotEmpty
        ? widget.bankAddress.toUpperCase().trim()
        : 'MAIN BRANCH SETTLEMENT DESK, FINANCIAL WIRE NETWORK';
    final amountFormatted = _formatAmount(widget.amount);
    final swiftType = widget.transferType.isNotEmpty
        ? widget.transferType.toUpperCase().trim()
        : 'SWIFT MT103';
    final purposeText = widget.purpose.isNotEmpty
        ? widget.purpose.toUpperCase().trim()
        : 'INVESTMENT SETTLEMENT WIRE // $swiftType';

    const headerDivider = Color(0xFF475569);
    const alertRed = Color(0xFFFF3355);
    const brightRed = Color(0xFFFF4D6D);
    const darkRed = Color(0xFFE53935);
    const warningAmber = Color(0xFFFFB300);
    const textMuted = Color(0xFF94A3B8);
    const textDim = Color(0xFFCBD5E1);
    const white = Colors.white;

    final lines = <_ErrorConsoleLineData>[
      // =========================================================================
      // SECTION 1: INITIAL NEGATIVE ACKNOWLEDGMENT (NAK 504)
      // =========================================================================
      _ErrorConsoleLineData('------------------------------------------------------------------------------------------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('MESSAGE REFERENCE: $_msgRef                                                           SYSTEM AUDIT: REJECTION NAK', fontWeight: FontWeight.w700, color: white),
      _ErrorConsoleLineData('------------------------------------SWIFT FIN NAK (NEGATIVE ACKNOWLEDGMENT)------------------------------------', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('*** STATUS                       : REJECTED BY CENTRAL SWIFT CLEARING NETWORK (NAK-504)', color: alertRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('*** ERROR CATEGORY               : CRITICAL SETTLEMENT REJECTION // CODE: ERR_MT103_INSUFFICIENT_LIQUIDITY', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('*** ISO 20022 ERROR CODE         : pacs.002.001.10 / RJCT / MS03 (ZERO CLEARED BALANCE)', color: warningAmber, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('*** CLEARING GATEWAY             : SWIFT ALLIANCE CORE // HOST DEUTDEFFAXXX', color: textMuted),
      _ErrorConsoleLineData('*** TRANSACTION TYPE             : $swiftType', color: white, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('*** TRANSACTION REFERENCE (TRN)  : ${widget.trn}', color: white),
      _ErrorConsoleLineData('*** UETR CODE                    : ${widget.uetr}', color: textMuted),
      _ErrorConsoleLineData('*** EXECUTION ATTEMPT TIMESTAMP  : $_dateTimeStr', color: textMuted),
      _ErrorConsoleLineData('*** MESSAGE INPUT REFERENCE      : 1735 $_mir', color: textMuted),
      _ErrorConsoleLineData('*** MESSAGE OUTPUT REFERENCE     : 1735 $_mor', color: textMuted),

      // =========================================================================
      // SECTION 2: ORIGINATING ACCOUNT & ZERO LIQUIDITY AUDIT
      // =========================================================================
      _ErrorConsoleLineData('---------------------------------------ORIGINATING ACCOUNT & LIQUIDITY AUDIT---------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('*** ORDERING INSTITUTION         : DEUTSCHE BANK AG (DEUTDEFFAXXX)', color: white),
      _ErrorConsoleLineData('*** ORDERING ACCOUNT NAME        : AVANTULO S.A.', color: white),
      _ErrorConsoleLineData('*** ORDERING ACCOUNT NUMBER      : DE60500700100361982244', color: textDim),
      _ErrorConsoleLineData('*** BENEFICIARY ACCOUNT          : $recipientIban ($recipientName)', color: textDim),
      _ErrorConsoleLineData('*** BENEFICIARY BANK SWIFT       : $recipientBic ($bankNameDisplay)', color: textDim),
      _ErrorConsoleLineData('*** BENEFICIARY BANK ADDRESS     : $bankAddrDisplay', color: textMuted),
      _ErrorConsoleLineData('*** INSTRUCTED SETTLEMENT AMOUNT : € $amountFormatted EUR', color: white, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('*** SOURCE LEDGER CLEARED BALANCE: € 0.00 EUR  <-- [ CRITICAL: EMPTY BALANCE / ZERO FUNDS ]', color: alertRed, fontWeight: FontWeight.w900),
      _ErrorConsoleLineData('*** SOURCE AVAILABLE LIQUIDITY   : € 0.00 EUR  <-- [ INSUFFICIENT COVER FOR WIRE ]', color: alertRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('*** LIQUIDITY DEFICIT SHORTFALL  : -€ $amountFormatted EUR  <-- [ TRANSACTION CANNOT BE SETTLED ]', color: brightRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('*** OVERDRAFT FACILITY STATUS    : UNAPPROVED // FACILITY LIMIT: € 0.00 EUR', color: textMuted),
      _ErrorConsoleLineData('*** ESCROW RESERVATION ATTEMPT   : FAILED -> ZERO LEDGER BALANCE DETECTED', color: alertRed),

      // =========================================================================
      // SECTION 3: MULTI-NODE INTERBANK CLEARING FAILURE TRACE
      // =========================================================================
      _ErrorConsoleLineData('-------------------------------------MULTI-NODE INTERBANK CLEARING FAILURE TRACE------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('[NODE 01: FRANKFURT CORE DEUTDEFF] : QUERYING ACCOUNT DE60500700100361982244 -> BALANCE RECORD: € 0.00 EUR [REJECT]', color: alertRed),
      _ErrorConsoleLineData('[NODE 02: SWIFT ALLIANCE SWHQBEBB] : INTERBANK LIQUIDITY CHECK FAILED -> COVER RATIO: 0.00% [REJECT]', color: alertRed),
      _ErrorConsoleLineData('[NODE 03: TARGET2 RTGS INTERFACE ] : SETTLEMENT DISPATCH BLOCKED -> NIL CLEARED FUNDS DETECTED [REJECT]', color: alertRed),
      _ErrorConsoleLineData('[NODE 04: FEDWIRE RELAY GATEWAY  ] : AUTOMATED STP ROUTING CANCELLED -> CODE NAK-504 DISPATCHED', color: textDim),
      _ErrorConsoleLineData('[NODE 05: SEPA CLEARING RELAY    ] : CANNOT DEBIT ORDERING ACCOUNT WITH ZERO BALANCE', color: textDim),
      _ErrorConsoleLineData('[NODE 06: NOSTRO LEDGER RECON    ] : RESERVATION DENIED -> INSUFFICIENT ACCOUNT LIQUIDITY', color: alertRed),
      _ErrorConsoleLineData('[NODE 07: COMPLIANCE AUDIT ENGINE] : FLAGGED AS NON-EXECUTABLE TRANSACTION // UNCOVERED WIRE', color: warningAmber),
      _ErrorConsoleLineData('[NODE 08: HSM SECURITY CONTROLLER] : TOKEN SIGNATURE REVOKED -> TRANSMISSION HALTED', color: warningAmber),
      _ErrorConsoleLineData('[NODE 09: CLEARING ENGINE PAC002 ] : GENERATING REJECTION PAYLOAD RJCT_MS03', color: textMuted),
      _ErrorConsoleLineData('[NODE 10: BENEFICIARY DESK       ] : NO CREDIT POSTED TO $recipientIban -> SESSION TERMINATED', color: textMuted),
      _ErrorConsoleLineData('[NODE 11: GLOBAL ROUTING SWITCH  ] : MT103 PACKET DROPPED AT INTERBANK HANDSHAKE (ZERO ASSETS)', color: alertRed),
      _ErrorConsoleLineData('[NODE 12: RTGS CORE LEDGER       ] : POST-PROCESSING BLOCKED // REASON: SENDER_BALANCE_NIL', color: alertRed),

      // =========================================================================
      // SECTION 4: SWIFT MT103 FIELD BREAKDOWN & REJECTION AUDIT
      // =========================================================================
      _ErrorConsoleLineData('---------------------------------------SWIFT MT103 FIELD-BY-FIELD REJECTION BREAKDOWN---------------------------------', color: headerDivider),
      _ErrorConsoleLineData('*** F20: TRANSACTION REFERENCE CODE    : ${widget.trn} [INVALIDATED]', color: textMuted),
      _ErrorConsoleLineData('*** F23B: BANK OPERATION CODE          : CRED [EXECUTION ABORTED]', color: textMuted),
      _ErrorConsoleLineData('*** F32A: CURRENCY / AMOUNT INSTRUCTED : EUR $amountFormatted [UNCOVERED]', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('*** F33B: ORIGINAL ORDERED AMOUNT      : EUR $amountFormatted [DEFICIT 100%]', color: alertRed),
      _ErrorConsoleLineData('*** F50K: ORDERING CUSTOMER            : AVANTULO S.A. / DE60500700100361982244 (BALANCE: € 0.00 EUR)', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('*** F52A: ORDERING INSTITUTION         : DEUTSCHE BANK AG / DEUTDEFFAXXX', color: white),
      _ErrorConsoleLineData('*** F57A: ACCOUNT WITH INSTITUTION     : $recipientBic / $bankNameDisplay', color: textDim),
      _ErrorConsoleLineData('*** F59 : BENEFICIARY CUSTOMER         : $recipientName / $recipientIban', color: textDim),
      _ErrorConsoleLineData('*** F70 : REMITTANCE INFORMATION       : $purposeText', color: textMuted),
      _ErrorConsoleLineData('*** F71A: DETAILS OF CHARGES           : OUR [UNCOLLECTIBLE DUE TO ZERO BALANCE]', color: textMuted),
      _ErrorConsoleLineData('*** F72 : SENDER TO RECEIVER INFO      : /REJT/504 INSUFFICIENT FUNDS / ZERO BALANCE', color: alertRed, fontWeight: FontWeight.w600),
      _ErrorConsoleLineData('*** F77B: REGULATORY REPORTING         : REJECTION RECORDED IN SWIFT GLOBAL AUDIT ENGINE', color: textMuted),

      // =========================================================================
      // SECTION 5: SWIFT ALLIANCE REJECTION NARRATIVE
      // =========================================================================
      _ErrorConsoleLineData('------------------------------------------SWIFT ALLIANCE REJECTION NARRATIVE---------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('*** F79 / REJECT NARRATIVE:', color: warningAmber, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('/// CRITICAL REJECTION: SWIFT ALLIANCE CORE INTERBANK PROTOCOL DETECTED ZERO FUNDS ON ORIGINATING LEDGER.', color: textDim),
      _ErrorConsoleLineData('/// THE SENDER ACCOUNT DE60500700100361982244 HOLDS A RECORDED CLEARED BALANCE OF € 0.00 EUR (NIL BALANCE).', color: alertRed, fontWeight: FontWeight.w600),
      _ErrorConsoleLineData('/// AUTOMATED INTERBANK CLEARING REJECTED: UNABLE TO DEBIT ZERO-BALANCE ACCOUNT FOR THE REQUESTED € $amountFormatted EUR.', color: textDim),
      _ErrorConsoleLineData('/// TRANSACTION HAS BEEN IMMEDIATELY ABORTED AND FLAGGED WITH NAK REJECTION CODE 504.', color: alertRed),
      _ErrorConsoleLineData('/// NO DEBIT HAS OCCURRED ON THE SENDER LEDGER, AND NO CREDIT WILL BE POSTED TO BENEFICIARY ACCOUNT $recipientIban.', color: textDim),
      _ErrorConsoleLineData('/// INTERBANK WIRE CANCELLED BY ALLIANCE ACCESS HOST CONTROLLER.', color: textMuted),

      // =========================================================================
      // SECTION 6: AUTOMATED RETRY CYCLES & REJECTION VERIFICATION (STAGE 1)
      // =========================================================================
      _ErrorConsoleLineData('------------------------------------AUTOMATED RE-VERIFICATION & RETRY CYCLES (STAGE 1)-------------------------------', color: headerDivider),
      _ErrorConsoleLineData('>>> [CYCLE 01/20] QUERYING LEDGER DE60500700100361982244 ... RESULT: € 0.00 EUR -> LIQUIDITY DEFICIT [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 02/20] RE-VERIFYING CLEARING DEPOSIT ... RESULT: € 0.00 EUR -> ZERO BALANCE CONFIRMED [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 03/20] CHECKING OVERDRAFT AUTHORIZATION ... RESULT: NOT AUTHORIZED FOR € $amountFormatted EUR [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 04/20] REQUESTING EMERGENCY LIQUIDITY INJECTION ... RESULT: TIMEOUT / NO COVER DETECTED [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 05/20] POLLING DEUTSCHE BANK SETTLEMENT QUEUE ... RESULT: RECORD REJECTED / NIL COVER [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 06/20] CHECKING CENTRAL BANK SETTLEMENT RESERVES ... RESULT: 0.00 EUR RESERVED [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 07/20] TESTING NOSTRO ACCOUNT POOL ... RESULT: INSUFFICIENT SUB-ALLOCATION [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 08/20] EXECUTING REAL-TIME LEDGER RESCAN ... RESULT: BALANCE UNCHANGED (€ 0.00 EUR) [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 09/20] INTERBANK STP VALIDATION PASS ... RESULT: EXCEPTION TRIGGERED (CODE NAK-504) [FAILED]', color: alertRed),
      _ErrorConsoleLineData('>>> [CYCLE 10/20] FINAL SETTLEMENT VALIDATION ... RESULT: NIL FUNDS (€ 0.00 EUR) [FAILED]', color: alertRed),
      _ErrorConsoleLineData('*** STAGE 1 CLEARING ATTEMPTS TERMINATED WITH ZERO-BALANCE REJECTION CODE 504 ***', color: alertRed, fontWeight: FontWeight.w800),

      // =========================================================================
      // SECTION 7: REAL-TIME LEDGER RECONCILIATION & NOSTRO/VOSTRO DEFICIT TRACE
      // =========================================================================
      _ErrorConsoleLineData('-------------------------------------NOSTRO / VOSTRO LIQUIDITY RECONCILIATION---------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('NOSTRO LEDGER DEUTDEFF-RTGS-01       : OPENED AT € 0.00 EUR // CLEARED: € 0.00 EUR [EMPTY]', color: alertRed),
      _ErrorConsoleLineData('VOSTRO LEDGER $recipientBic-EUR-01        : PENDING CREDIT CANCELLED // CAUSE: SENDER NIL COVER', color: textDim),
      _ErrorConsoleLineData('COLLATERAL ALLOCATION STATUS         : ZERO COLLATERAL PLEDGED FOR WIRE ID ${widget.transferId}', color: alertRed),
      _ErrorConsoleLineData('LIQUIDITY BUFFER SHORTAGE            : -€ $amountFormatted EUR (100.00% DEFICIT)', color: brightRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('MARGIN CALL STATUS                   : INSUFFICIENT ORIGINATING CAPITAL DETECTED', color: warningAmber),
      _ErrorConsoleLineData('SETTLEMENT SYSTEM RESPONSE           : REJECT_CODE_AC01_INSUFFICIENT_FUNDS_IN_ORIGIN_ACCOUNT', color: alertRed, fontWeight: FontWeight.w700),

      // =========================================================================
      // SECTION 8: ISO 20022 PAC.002 & PAC.004 PROTOCOL ERROR STACK
      // =========================================================================
      _ErrorConsoleLineData('--------------------------------------ISO 20022 PACS.002 ERROR PROTOCOL STACK---------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('ISO_MSG_TYPE         : pacs.002.001.10 (Payment Status Report)', color: white),
      _ErrorConsoleLineData('ORIG_MSG_ID          : MSG-${widget.trn}', color: textMuted),
      _ErrorConsoleLineData('TX_STATUS            : RJCT (Rejected)', color: alertRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('STATUS_REASON_CODE   : MS03 / AC01 (Incorrect Account / Insufficient Cleared Liquidity)', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('CLEARING_SYSTEM      : SWIFT ALLIANCE STP REAL-TIME ENGINE', color: textMuted),
      _ErrorConsoleLineData('SETTLEMENT_AMOUNT    : EUR $amountFormatted [NIL COVERED]', color: alertRed),
      _ErrorConsoleLineData('AVAILABLE_AMOUNT     : EUR 0.00 [ZERO FUNDS IN ACCOUNT]', color: alertRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('SETTLEMENT_METHOD    : CLRG (Clearing System Automated Rejection)', color: textMuted),
      _ErrorConsoleLineData('REJECTION_TIMESTAMP  : $_dateTimeStr.892+01:00', color: textMuted),

      // =========================================================================
      // SECTION 9: INTERBANK SOCKET & HEX STACK TRACE
      // =========================================================================
      _ErrorConsoleLineData('--------------------------------------INTERBANK SOCKET & CORE MEMORY STACK DUMP-------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('0x00000000  46 49 4e 20 4e 41 4b 2d  35 30 34 20 5a 45 52 4f  FIN NAK- 504 ZERO', color: textMuted),
      _ErrorConsoleLineData('0x00000010  20 42 41 4c 41 4e 43 45  20 44 45 54 45 43 54 45   BALANCE  DETECTE', color: textMuted),
      _ErrorConsoleLineData('0x00000020  44 3a 20 44 45 36 30 35  30 30 37 30 30 31 30 30  D: DE605 00700100', color: textMuted),
      _ErrorConsoleLineData('0x00000030  33 36 31 39 38 32 32 34  34 20 3d 20 30 2e 30 30  36198224 4 = 0.00', color: alertRed),
      _ErrorConsoleLineData('0x00000040  20 45 55 52 20 5b 52 45  4a 45 43 54 5d 00 00 00   EUR [RE JECT]...', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('0x00000050  55 45 54 52 3a 20 ${widget.uetr.substring(0, min(16, widget.uetr.length))} ... ABORTED_NO_FUNDS', color: textMuted),
      _ErrorConsoleLineData('STACK TRACE: swift.engine.settlement.DebitValidator.assertClearedBalance(DebitValidator.java:412)', color: alertRed),
      _ErrorConsoleLineData('             at swift.alliance.core.stp.FinProtocolEngine.processMT103(FinProtocolEngine.java:1089)', color: textDim),
      _ErrorConsoleLineData('             at swift.alliance.gateway.FinWireHandler.dispatchSettlement(FinWireHandler.java:234)', color: textDim),
      _ErrorConsoleLineData('             at swift.alliance.router.InterbankRouter.routeWire(InterbankRouter.java:88)', color: textDim),
      _ErrorConsoleLineData('EXCEPTION: InsufficientFundsException: Account DE60500700100361982244 has cleared balance of 0.00 EUR', color: alertRed, fontWeight: FontWeight.w800),

      // =========================================================================
      // SECTION 10: SECONDARY RETRY CYCLES & CONFIRMATION (STAGE 2)
      // =========================================================================
      _ErrorConsoleLineData('------------------------------------AUTOMATED RE-VERIFICATION & RETRY CYCLES (STAGE 2)-------------------------------', color: headerDivider),
      _ErrorConsoleLineData('>>> [CYCLE 11/20] RE-PINGING DEUTSCHE BANK CORE BACKEND ... RESULT: 0.00 EUR [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 12/20] ATTEMPTING COLLATERALIZED CLEARING ... RESULT: NO COLLATERAL FOUND [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 13/20] PROBING SEPA INSTANT CLEARING SWITCH ... RESULT: UNCOVERED PAYMENT CANCELLED [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 14/20] RE-CONFIRMING BENEFICIARY ROUTING $recipientBic ... RESULT: ROUTE VALID, BUT ZERO SENDER FUNDS [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 15/20] TESTING BACKUP LIQUIDITY BRIDGE (LUXEMBOURG) ... RESULT: NO AUTHORIZED BALANCE [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 16/20] QUERYING TREASURY SETTLEMENT DESK ... RESULT: ZERO COVER AVAILABLE (€ 0.00 EUR) [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 17/20] RE-CHECKING CLEARING RESERVE LIMITS ... RESULT: DEFICIT SHORTFALL 100% [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 18/20] SUBMITTING RE-VALIDATION TO TARGET2 RTGS ... RESULT: IMMEDIATE FIN NAK-504 [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 19/20] VERIFYING INTRA-DAY CREDIT LINE ... RESULT: ZERO FACILITY APPROVED [REJECT]', color: darkRed),
      _ErrorConsoleLineData('>>> [CYCLE 20/20] EXECUTING PERMANENT SETTLEMENT LOCKOUT ... RESULT: TRANSACTION IRREVOCABLY REJECTED', color: alertRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('*** EXHAUSTED ALL 20 AUTOMATED CLEARING ATTEMPTS - ZERO BALANCE PERMANENTLY CONFIRMED ***', color: alertRed, fontWeight: FontWeight.w800),

      // =========================================================================
      // SECTION 11: MULTI-HOP INTERMEDIARY ROUTING ENGINE REJECTION
      // =========================================================================
      _ErrorConsoleLineData('---------------------------------------INTERMEDIARY ROUTING NETWORK REJECTION LOG------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('ROUTING HOP 1 [DEUTDEFF -> SWIFTNET CENTRAL] : ACK RECEIVED, VALIDATING BALANCE... STATUS: NIL [504]', color: alertRed),
      _ErrorConsoleLineData('ROUTING HOP 2 [SWIFTNET -> EBA EURO1 CLEARING] : MESSAGE PACKET CANCELLED BEFORE TRANSMISSION', color: textDim),
      _ErrorConsoleLineData('ROUTING HOP 3 [EURO1 -> TARGET2 SETTLEMENT]  : RTGS TRANSACTION WINDOW CLOSED FOR UNCOVERED ORDER', color: textDim),
      _ErrorConsoleLineData('ROUTING HOP 4 [TARGET2 -> CORRESPONDENT DESK]: INSTRUCTION PURGED FROM CLEARING QUEUE', color: textDim),
      _ErrorConsoleLineData('ROUTING HOP 5 [CORRESPONDENT -> $recipientBic] : NOTIFICATION SENT: PAYMENT NOT EXECUTED (ZERO SENDER COVER)', color: textDim),
      _ErrorConsoleLineData('OVERALL ROUTING STATUS                       : REJECTED AT INGRESS NODE // ZERO LIQUIDITY', color: alertRed, fontWeight: FontWeight.w800),

      // =========================================================================
      // SECTION 12: FINANCIAL AUDIT & ZERO-BALANCE AFFIDAVIT
      // =========================================================================
      _ErrorConsoleLineData('------------------------------------------FINANCIAL AUDIT & CLEARING AFFIDAVIT------------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('AUDIT CERTIFICATE ID : AUD-NAK-504-${widget.trn.replaceAll('-', '').substring(0, min(12, widget.trn.replaceAll('-', '').length))}', color: white),
      _ErrorConsoleLineData('AUDIT FINDING        : SENDER ACCOUNT HELD INSUFFICIENT CLEARED LIQUIDITY (CURRENT CLEARED ASSETS: € 0.00 EUR)', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('REQUIRED LIQUIDITY   : € $amountFormatted EUR', color: white),
      _ErrorConsoleLineData('DEFICIT PERCENTAGE   : 100.00% UNDER-FUNDED', color: brightRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('AUDIT ACTION         : MT103 FIN WIRE ABORTED IMMEDIATELY IN ACCORDANCE WITH SWIFT USER HANDBOOK FIN RULE 504', color: textDim),
      _ErrorConsoleLineData('LEGAL NOTICE         : NO DEBITS OR CREDITS APPLIED TO ANY INTERBANK LEDGER DURING THIS SESSION', color: textMuted),

      // =========================================================================
      // SECTION 13: HSM CRYPTO & SECURITY AUDIT REVOCATION
      // =========================================================================
      _ErrorConsoleLineData('--------------------------------------------------SECURITY & HSM AUDIT--------------------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('SECURITY AUDIT       : HSM CRYPTOGRAPHIC AUTHORIZATION TOKEN REVOKED (SESSION $_sessionId)', color: warningAmber),
      _ErrorConsoleLineData('PKI SIGNATURE        : INVALIDATED DUE TO ZERO BALANCE VERIFICATION FAILURE ($_pkiSignature)', color: warningAmber),
      _ErrorConsoleLineData('CHK CODE             : $_chk [REJECTION ENCRYPTED & SIGNED]', color: textMuted),
      _ErrorConsoleLineData('CHIEF AUDITOR        : REJECTION RECORD PERMANENTLY LOGGED TO SWIFT AUDIT LOG ARCHIVE', color: textMuted),

      // =========================================================================
      // SECTION 14: RAW SWIFT PAYLOAD REJECTION DUMP
      // =========================================================================
      _ErrorConsoleLineData('-------------------------------------------RAW REJECTION PAYLOAD DUMP (SWIFT)-------------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('{1:F01DEUTDEFFAXXX0000000000}{2:I103${recipientBic}XXXXN504}{3:{108:$_msgRef}}{4:', color: textMuted),
      _ErrorConsoleLineData(':20:${widget.trn}', color: textMuted),
      _ErrorConsoleLineData(':23B:CRED', color: textMuted),
      _ErrorConsoleLineData(':32A:${_dateTimeStr.split(' ')[0]}EUR$amountFormatted', color: textMuted),
      _ErrorConsoleLineData(':50K:/DE60500700100361982244\nAVANTULO S.A.\nPANAMA CITY, PANAMA', color: textMuted),
      _ErrorConsoleLineData(':52A:DEUTDEFFAXXX', color: textMuted),
      _ErrorConsoleLineData(':57A:$recipientBic', color: textMuted),
      _ErrorConsoleLineData(':59:/$recipientIban\n$recipientName', color: textMuted),
      _ErrorConsoleLineData(':70:$purposeText', color: textMuted),
      _ErrorConsoleLineData(':79:/REJT/504 INSUFFICIENT CLEARED BALANCE IN ORIGINATING ACCOUNT', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData(':79:/ERR/SOURCE LEDGER DE60500700100361982244 CURRENT BALANCE IS € 0.00 EUR (EMPTY)', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData(':79:/DEFICIT/-€ $amountFormatted EUR', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData(':79:/STAT/SETTLEMENT_ABORTED_NIL_FUNDS', color: alertRed, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('-}{5:{CHK:$_chk}{PAC002:RJCT_MS03_EMPTY_BALANCE}{MAC:00000000}}', color: textMuted),

      // =========================================================================
      // SECTION 15: TERMINATION SUMMARY & LOG END
      // =========================================================================
      _ErrorConsoleLineData('--------------------------------------------------END OF REJECTION LOG--------------------------------------------------', color: headerDivider),
      _ErrorConsoleLineData('*** ALLIANCE ACCESS CLEARING PROTOCOL: TRANSACTION COMPLETED AS FAILED (ERR-504) ***', color: alertRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('*** ZERO FINANCIAL SETTLEMENT EXECUTED // NO CAPITAL TRANSFERRED ***', color: warningAmber, fontWeight: FontWeight.w700),
      _ErrorConsoleLineData('root@swift-gateway:~# ERROR: TRANSACTION_ABORTED_DUE_TO_ZERO_ACCOUNT_BALANCE (CODE 504)', color: alertRed, fontWeight: FontWeight.w800),
      _ErrorConsoleLineData('root@swift-gateway:~# SESSION_STATE=DISCONNECTED // ALLIANCE_ACCESS_RETRY_COUNT=20 // FINAL_STATUS=REJECTED_NIL_BALANCE', color: textMuted),
    ];

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final isLayer = widget.isLayer;
    const cardBg = Color(0xEE120609);
    const borderColor = Color(0x88FF3355);
    const glowColor = Color(0xFFFF3355);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0306),
      body: SwiftNetworkBackground(
        showHud: true,
        isLayer: isLayer,
        onBottomLeftTap: _accelerate,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Container(
                    width: 1100,
                    height: 820,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 1.3),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0x99000000),
                          blurRadius: 45,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.18),
                          blurRadius: 35,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // WINDOW TITLE BAR
                        _buildTitleBar(),

                        // GLOWING RED WARNING / PROGRESS BAR
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

              // SPEED UP BUTTON (BOTTOM LEFT - FAINT / SAMAR)
              Positioned(
                bottom: 24,
                left: 24,
                child: _FaintAccelerateButton(
                  onTap: _accelerate,
                  isAccelerated: _isAccelerated,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    const barBg = Color(0xFA1E0A0F);
    const borderColor = Color(0x55FF3355);
    const accentRed = Color(0xFFFF3355);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: barBg,
        borderRadius: BorderRadius.only(
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
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(color: Color(0xFFFF3355), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(color: Color(0xFF64748B), shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Text(
                'tty://swiftnet-wire/rejection-$_sessionId',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentRed.withValues(alpha: 0.15),
                  border: Border.all(color: accentRed.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'ALLIANCE ACCESS v7.4.2 // FIN WIRE REJECTION (NAK-504)',
                  style: GoogleFonts.jetBrainsMono(
                    color: accentRed,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x33FF3355),
                  border: Border.all(color: const Color(0xFFFF3355)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3355), size: 12),
                    const SizedBox(width: 5),
                    Text(
                      'CRITICAL TRANSACTION REJECTED',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFFFF3355),
                        fontSize: 9.5,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountDashboardPage(
                        dashboardType: widget.isLayer ? 'LAYER' : 'MT 103',
                      ),
                    ),
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(2),
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.close, color: Color(0xFF94A3B8), size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    const barBg = Color(0xD0170509);
    const borderColor = Color(0x44FF3355);
    const accentRed = Color(0xFFFF3355);

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final progress = _progressController.value;
        final percent = (progress * 100).clamp(0.0, 100.0).toStringAsFixed(1);
        final isFinished = progress >= 0.999;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: barBg,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: accentRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentRed.withValues(alpha: 0.9),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFinished
                          ? '● TRANSACTION ABORTED : ZERO BALANCE DETECTED (€ 0.00 EUR) - 100%'
                          : '● SWIFT INTERBANK REJECTION AUDIT : $percent% [15 MIN ESTIMATE]',
                      style: GoogleFonts.jetBrainsMono(
                        color: accentRed,
                        fontSize: 12.5,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // RED PROGRESS BAR
              Container(
                height: 8,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B0307),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF55101A), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33FF3355),
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
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF1744),
                              Color(0xFFFF3355),
                              Color(0xFFFF80AB),
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFFF3355),
                              blurRadius: 8,
                              spreadRadius: 1,
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
        );
      },
    );
  }

  Widget _buildTypewriterConsoleBody() {
    final allLines = _generateErrorDocumentLines();
    final totalLines = allLines.length;
    const accentRed = Color(0xFFFF3355);

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

                final startP = 0.002 + (index / totalLines) * 0.96;
                final endP = 0.002 + ((index + 1) / totalLines) * 0.96;

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
                          const TextSpan(
                            text: ' █',
                            style: TextStyle(
                              color: accentRed,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // FINAL ERROR BANNER & RETURN BUTTON
              if (p >= 0.999) ...[
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glow = _pulseController.value;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x33FF1744),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Color.lerp(const Color(0xFFFF3355), const Color(0xFFFF80AB), glow)!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3355).withValues(alpha: 0.25 + 0.25 * glow),
                            blurRadius: 16 + 10 * glow,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF3355), size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRANSACTION REJECTED (SWIFT REJECT 504) - SOURCE BALANCE EMPTY',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFFFF3355),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Source account DE60500700100361982244 balance is € 0.00 EUR (Empty). Insufficient funds to process transfer of € ${_formatAmount(widget.amount)} EUR.',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFFF1F5F9),
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26050C),
                              foregroundColor: const Color(0xFFFF3355),
                              side: const BorderSide(color: Color(0xFFFF3355), width: 1.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              elevation: 4,
                            ),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AccountDashboardPage(
                                    dashboardType: widget.isLayer ? 'LAYER' : 'MT 103',
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.dashboard_outlined, size: 16, color: Color(0xFFFF3355)),
                            label: Text(
                              '[ RETURN TO DASHBOARD ]',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFFF3355),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    const barBg = Color(0xFA1E0A0F);
    const borderColor = Color(0x55FF3355);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: barBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'HSM CRYPTO: REJECTION SIGNED // ERROR LOGGED IN SYSTEM AUDIT',
            style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8), fontSize: 9.5),
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3355),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF3355),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'STATUS: SETTLEMENT ABORTED (ERR-504)',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFFFF3355),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ FAINT ACCELERATE BUTTON ============
class _FaintAccelerateButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isAccelerated;

  const _FaintAccelerateButton({
    required this.onTap,
    required this.isAccelerated,
  });

  @override
  State<_FaintAccelerateButton> createState() => _FaintAccelerateButtonState();
}

class _FaintAccelerateButtonState extends State<_FaintAccelerateButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const normalColor = Color(0xFF475569);
    const hoverColor = Color(0xFF94A3B8);
    final activeColor = const Color(0xFFFF3355).withValues(alpha: 0.6);

    final currentColor = widget.isAccelerated
        ? (_isHovered ? const Color(0xFFFF3355) : activeColor)
        : (_isHovered ? hoverColor : normalColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0306).withValues(alpha: 0.7),
            border: Border.all(
              color: currentColor.withValues(alpha: _isHovered ? 0.6 : 0.3),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            widget.isAccelerated
                ? '[ >> ACCELERATING LOG... ]'
                : '[ >> ACCELERATE STREAM ]',
            style: GoogleFonts.jetBrainsMono(
              color: currentColor,
              fontSize: 9.5,
              letterSpacing: 1,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
