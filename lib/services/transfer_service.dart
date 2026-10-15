import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TransferService {
  static const String _kTransfers = 'transfers';
  static const String _kBalance = 'dashboard_balance_eur';
  static const String _kAvailable = 'dashboard_available_eur';
  static const String _kBlocked = 'dashboard_blocked_eur';
  static const String _kLimit = 'dashboard_daily_limit_eur';
  static const String _kAccountData = 'dashboard_account_data';

  Future<String?> createTransfer({
    required String recipient,
    required String iban,
    String? bic,
    String? bankName,
    String? bankAddress,
    required double amount,
    String? purpose,
    required String securityKey,
    String? transferType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transfersJson = prefs.getString(_kTransfers) ?? '[]';
      final List transfers = jsonDecode(transfersJson);

      final id = 'TRF${_generateCode()}';
      final now = DateTime.now();
      final estCompletion = now.add(const Duration(days: 5));

      final transfer = {
        'id': id,
        'transfer_type': transferType ?? 'MT103 Cash Transfer',
        'recipient': recipient,
        'iban': iban,
        'bic': (bic != null && bic.isNotEmpty) ? bic : 'DEUTDEDDXXX',
        'bank_name': (bankName != null && bankName.isNotEmpty) ? bankName : 'Deutsche Bank Frankfurt',
        'bank_address': (bankAddress != null && bankAddress.isNotEmpty) ? bankAddress : 'Mainzer Landstrasse 11-17, Frankfurt',
        'amount': amount,
        'purpose': purpose ?? '',
        'status': 'PENDING',
        'created_at': now.toIso8601String(),
        'est_completion': estCompletion.toIso8601String(),
        'approved_at': null,
        'settled_at': null,
        'rejected_at': null,
        'rejection_reason': null,
      };

      transfers.insert(0, transfer);
      await prefs.setString(_kTransfers, jsonEncode(transfers));
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<void> completeAndSettleTransfer({
    required String transferId,
    required String transferType,
    required String recipient,
    required String iban,
    String bic = '',
    String bankName = '',
    String bankAddress = '',
    required double amount,
    String purpose = '',
    String trn = '',
    String uetr = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transfersJson = prefs.getString(_kTransfers) ?? '[]';
      final List transfers = jsonDecode(transfersJson);
      final now = DateTime.now();

      final cleanBic = bic.isNotEmpty ? bic : 'DEUTDEDDXXX';
      final cleanBank = bankName.isNotEmpty ? bankName : 'Deutsche Bank Frankfurt';
      final cleanBranch = bankAddress.isNotEmpty ? bankAddress : 'Mainzer Landstrasse 11-17, Frankfurt';
      final cleanTrn = trn.isNotEmpty ? trn : 'TRN-${now.year}${_pad(now.month)}${_pad(now.day)}-${_generateCode()}';
      final cleanUetr = uetr.isNotEmpty ? uetr : '${_generateCode()}-${_generateCode()}-${_generateCode()}';

      bool found = false;
      for (var i = 0; i < transfers.length; i++) {
        if (transfers[i]['id'] == transferId) {
          transfers[i]['status'] = 'SETTLED';
          transfers[i]['transfer_type'] = transferType;
          transfers[i]['recipient'] = recipient;
          transfers[i]['iban'] = iban;
          transfers[i]['bic'] = cleanBic;
          transfers[i]['bank_name'] = cleanBank;
          transfers[i]['bank_address'] = cleanBranch;
          transfers[i]['amount'] = amount;
          transfers[i]['purpose'] = purpose;
          transfers[i]['trn'] = cleanTrn;
          transfers[i]['uetr'] = cleanUetr;
          transfers[i]['approved_at'] = now.toIso8601String();
          transfers[i]['settled_at'] = now.toIso8601String();
          found = true;
          break;
        }
      }

      if (!found) {
        transfers.insert(0, {
          'id': transferId.isNotEmpty ? transferId : 'TRF${_generateCode()}',
          'transfer_type': transferType,
          'recipient': recipient,
          'iban': iban,
          'bic': cleanBic,
          'bank_name': cleanBank,
          'bank_address': cleanBranch,
          'amount': amount,
          'purpose': purpose,
          'status': 'SETTLED',
          'trn': cleanTrn,
          'uetr': cleanUetr,
          'created_at': now.toIso8601String(),
          'approved_at': now.toIso8601String(),
          'settled_at': now.toIso8601String(),
        });
      }

      await prefs.setString(_kTransfers, jsonEncode(transfers));

      // 1. Auto-Increase Balances (Gambar ke-1: Total Balance & Available Balance)
      final currentBalance = prefs.getDouble(_kBalance) ?? 0.0;
      final currentAvailable = prefs.getDouble(_kAvailable) ?? 0.0;
      final newBalance = currentBalance + amount;
      final newAvailable = currentAvailable + amount;

      await prefs.setDouble(_kBalance, newBalance);
      await prefs.setDouble(_kAvailable, newAvailable);

      // 2. Auto-Update Account Information (Gambar ke-4: Account Info)
      final currentAccJson = prefs.getString(_kAccountData);
      Map<String, String> accData = {};
      if (currentAccJson != null) {
        try {
          final Map decoded = jsonDecode(currentAccJson);
          accData = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        } catch (_) {}
      }

      accData['account_holder'] = recipient.isNotEmpty ? recipient : (accData['account_holder'] ?? 'ESTHER');
      accData['account_number'] = iban.isNotEmpty ? iban : (accData['account_number'] ?? 'DE89 3704 0044 0532 0130 00');
      accData['iban'] = iban.isNotEmpty ? iban : (accData['iban'] ?? 'DE89 3704 0044 0532 0130 00');
      accData['bic'] = cleanBic;
      accData['bank'] = cleanBank;
      accData['branch'] = cleanBranch;
      if (!accData.containsKey('reg_no') || (accData['reg_no']?.isEmpty ?? true)) {
        accData['reg_no'] = 'HRB 30 000 / DE-8839201';
      }
      if (!accData.containsKey('vat_id') || (accData['vat_id']?.isEmpty ?? true)) {
        accData['vat_id'] = 'DE 114 103 362';
      }

      await prefs.setString(_kAccountData, jsonEncode(accData));
    } catch (e) {
      // ignore
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransfers() async {
    final prefs = await SharedPreferences.getInstance();
    final transfersJson = prefs.getString(_kTransfers) ?? '[]';
    final List transfers = jsonDecode(transfersJson);
    return transfers.cast<Map<String, dynamic>>();
  }

  Future<Map<String, double>> getBalances() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'balance': prefs.getDouble(_kBalance) ?? 0.0,
      'available': prefs.getDouble(_kAvailable) ?? 0.0,
      'blocked': prefs.getDouble(_kBlocked) ?? 0.0,
      'limit': prefs.getDouble(_kLimit) ?? 0.0,
    };
  }

  Future<void> saveBalances({
    double? balance,
    double? available,
    double? blocked,
    double? limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (balance != null) await prefs.setDouble(_kBalance, balance);
    if (available != null) await prefs.setDouble(_kAvailable, available);
    if (blocked != null) await prefs.setDouble(_kBlocked, blocked);
    if (limit != null) await prefs.setDouble(_kLimit, limit);
  }

  Future<Map<String, String>> getAccountInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kAccountData);
    if (jsonStr != null) {
      try {
        final Map decoded = jsonDecode(jsonStr);
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      } catch (_) {}
    }
    return {};
  }

  Future<void> saveAccountInfo(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccountData, jsonEncode(data));
  }

  Future<bool> approveTransfer(String id) async {
    return _updateStatus(id, 'APPROVED', approvedAt: DateTime.now().toIso8601String());
  }

  Future<bool> rejectTransfer(String id, String reason) async {
    return _updateStatus(id, 'REJECTED',
      rejectedAt: DateTime.now().toIso8601String(), reason: reason);
  }

  Future<bool> _updateStatus(String id, String status, {String? approvedAt, String? rejectedAt, String? reason}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transfersJson = prefs.getString(_kTransfers) ?? '[]';
      final List transfers = jsonDecode(transfersJson);

      for (var i = 0; i < transfers.length; i++) {
        if (transfers[i]['id'] == id) {
          transfers[i]['status'] = status;
          if (approvedAt != null) transfers[i]['approved_at'] = approvedAt;
          if (rejectedAt != null) transfers[i]['rejected_at'] = rejectedAt;
          if (reason != null) transfers[i]['rejection_reason'] = reason;
          break;
        }
      }
      await prefs.setString(_kTransfers, jsonEncode(transfers));
      return true;
    } catch (e) {
      return false;
    }
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }
}