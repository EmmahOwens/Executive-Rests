import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _publicKey = 'FLUTTERWAVE_PUBLIC_KEY'; // Replace with actual key in production
  
  // Process payment using Flutterwave (supports Mobile Money in Uganda)
  Future<Map<String, dynamic>> processPayment({
    required BuildContext context,
    required String email,
    required String phoneNumber,
    required String name,
    required double amount,
    required String propertyId,
    required String tenantId,
    required String landlordId,
    required String currency = 'UGX', // Ugandan Shilling
    required String paymentType, // 'rent', 'deposit', 'booking'
  }) async {
    try {
      final String txRef = const Uuid().v4();
      final String orderRef = const Uuid().v4();
      
      final customer = Customer(
        name: name,
        phoneNumber: phoneNumber,
        email: email
      );

      final flutterwave = Flutterwave(
        context: context,
        publicKey: _publicKey,
        currency: currency,
        redirectUrl: 'https://executiverests.com/payments/verify',
        txRef: txRef,
        orderRef: orderRef,
        amount: amount.toString(),
        customer: customer,
        paymentOptions: "mobilemoneyuganda, card, ussd",
        customization: Customization(
          title: "Executive Rests Payment",
          description: "Payment for $paymentType",
          logo: "https://executiverests.com/logo.png"
        ),
        isTestMode: true, // Set to false in production
      );

      final ChargeResponse response = await flutterwave.charge();

      if (response.success == true) {
        // Record payment in Firestore
        final paymentData = {
          'id': txRef,
          'amount': amount,
          'currency': currency,
          'tenantId': tenantId,
          'landlordId': landlordId,
          'propertyId': propertyId,
          'paymentType': paymentType,
          'status': 'completed',
          'paymentMethod': response.mobileMoneyUgandaToken != null ? 'Mobile Money' : 'Card',
          'transactionReference': response.transactionId,
          'timestamp': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('payments').doc(txRef).set(paymentData);

        return {
          'success': true,
          'message': 'Payment successful',
          'data': paymentData,
        };
      } else {
        return {
          'success': false,
          'message': 'Payment failed or was cancelled',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment error: $e',
      };
    }
  }

  // Get payment history for a tenant
  Stream<List<Map<String, dynamic>>> getTenantPaymentHistory(String tenantId) {
    return _firestore
        .collection('payments')
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Get payment history for a landlord
  Stream<List<Map<String, dynamic>>> getLandlordPaymentHistory(String landlordId) {
    return _firestore
        .collection('payments')
        .where('landlordId', isEqualTo: landlordId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Get payment details
  Future<Map<String, dynamic>?> getPaymentDetails(String paymentId) async {
    final DocumentSnapshot doc = await _firestore.collection('payments').doc(paymentId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Generate payment receipt
  Future<String> generatePaymentReceipt(String paymentId) async {
    // In a real app, this would generate a PDF receipt
    // For now, we'll just return a URL to a hypothetical receipt
    return 'https://executiverests.com/receipts/$paymentId';
  }

  // Calculate rent due dates and amounts
  Map<String, dynamic> calculateRentSchedule({
    required double monthlyRent,
    required DateTime startDate,
    required int leaseDurationMonths,
  }) {
    final List<Map<String, dynamic>> schedule = [];
    DateTime currentDate = startDate;

    for (int i = 0; i < leaseDurationMonths; i++) {
      schedule.add({
        'dueDate': DateTime(currentDate.year, currentDate.month + i, currentDate.day),
        'amount': monthlyRent,
        'status': i == 0 ? 'current' : 'upcoming',
      });
    }

    return {
      'totalAmount': monthlyRent * leaseDurationMonths,
      'monthlyAmount': monthlyRent,
      'startDate': startDate,
      'endDate': DateTime(startDate.year, startDate.month + leaseDurationMonths, startDate.day),
      'schedule': schedule,
    };
  }
}