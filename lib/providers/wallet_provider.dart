import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/wallet_transaction.dart';
import '../core/services/public_apis_service.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 150.0; // Initial demo balance in EGP
  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'tx_init',
      type: TransactionType.topUp,
      amount: 150.0,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      description: 'رصيد ترحيبي تجريبي بكابتن إسنا',
      paymentMethod: 'فوري (Fawry)',
      status: TransactionStatus.completed,
    ),
  ];

  double get balance => _balance;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  bool deductCommission(double amount, String rideId) {
    if (_balance < amount) {
      // Allow minor negative balance up to -20 EGP in inDrive to avoid mid-ride disruption
      if (_balance - amount < -20.0) {
        return false;
      }
    }

    _balance -= amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'tx_comm_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.commissionDeduction,
        amount: amount,
        timestamp: DateTime.now(),
        description: 'خصم عمولة المنصة (7%) - رحلة #$rideId',
        paymentMethod: 'المحفظة الداخلية',
        status: TransactionStatus.completed,
      ),
    );
    notifyListeners();
    return true;
  }

  void refundCommission(double amount, String rideId, String reason) {
    _balance += amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'tx_ref_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.commissionRefund,
        amount: amount,
        timestamp: DateTime.now(),
        description: 'استرداد عمولة الرحلة #$rideId ($reason)',
        paymentMethod: 'المحفظة الداخلية',
        status: TransactionStatus.completed,
      ),
    );
    notifyListeners();
  }

  /// Request Fawry Top-up with 10-digit reference number and QR code
  Map<String, dynamic> initiateFawryTopUp(double amount) {
    final randomDigits = 100000 + Random().nextInt(900000);
    final refCode = '982$randomDigits';
    final qrData = 'FAWRY:REF:$refCode:AMOUNT:$amount:CURRENCY:EGP:ESNADRIVE';
    final qrUrl = PublicApisService.getQrCodeUrl(qrData, size: 220);

    final tx = WalletTransaction(
      id: 'tx_fwr_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.topUp,
      amount: amount,
      timestamp: DateTime.now(),
      description: 'شحن فوري - كود دفع $refCode',
      paymentMethod: 'فوري (Fawry)',
      fawryRefCode: refCode,
      status: TransactionStatus.completed, // Auto-completed in demo for instant testing
    );

    _balance += amount;
    _transactions.insert(0, tx);
    notifyListeners();

    return {
      'refCode': refCode,
      'qrUrl': qrUrl,
      'amount': amount,
    };
  }

  /// Request Vodafone Cash / InstaPay top-up
  void initiateMobileWalletTopUp(double amount, String provider, String senderPhone) {
    final tx = WalletTransaction(
      id: 'tx_mob_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.topUp,
      amount: amount,
      timestamp: DateTime.now(),
      description: 'شحن رصيد عبر $provider من رقم $senderPhone',
      paymentMethod: provider,
      status: TransactionStatus.completed,
    );

    _balance += amount;
    _transactions.insert(0, tx);
    notifyListeners();
  }
}
