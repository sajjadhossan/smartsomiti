import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';
import '../models/somiti_model.dart';
import '../models/member_model.dart';
import '../models/deposit_model.dart';
import '../models/expense_model.dart';
import 'auth_service.dart';

class DriveService {
  static final DriveService _instance = DriveService._internal();
  factory DriveService() => _instance;
  DriveService._internal();

  final AuthService _authService = AuthService();

  Future<drive.DriveApi?> _getDriveApi() async {
    final client = await _authService.googleSignIn.authenticatedClient();
    if (client == null) {
      return null;
    }
    return drive.DriveApi(client);
  }

  Future<drive.File?> uploadSomitiBackupCsv({
    required SomitiModel somiti,
    required List<MemberModel> members,
    required List<DepositModel> deposits,
    List<ExpenseModel> expenses = const [],
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      throw Exception('Google Drive ক্লায়েন্ট অথেনটিকেটেড নয়। দয়া করে গুগল দিয়ে সাইন-ইন নিশ্চিত করুন।');
    }

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(now);
    final sanitizedName = somiti.name.replaceAll(RegExp(r'[^\w\s\u0980-\u09FF]'), '_');
    final fileName = '${sanitizedName}_Statement_$dateStr.csv';

    final double totalDeposit = members.fold(0.0, (sum, m) => sum + m.totalDeposit);
    final double totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final double cashInHand = totalDeposit - totalExpense;

    final buffer = StringBuffer();
    // UTF-8 BOM so Excel opens Bengali characters perfectly
    buffer.write('\uFEFF');

    buffer.writeln('====================================================');
    buffer.writeln('              ${somiti.name}');
    if (somiti.padHeader.isNotEmpty) {
      buffer.writeln('          "${somiti.padHeader}"');
    }
    buffer.writeln('====================================================');
    buffer.writeln('কার্যালয়,${somiti.address.isNotEmpty ? somiti.address : "দেওয়া নেই"}');
    buffer.writeln('সমিতি কোড,${somiti.somitiCode}');
    if (somiti.bankAccount.isNotEmpty) {
      buffer.writeln('ব্যাংক হিসাব,${somiti.bankAccount}');
    }
    if (somiti.bkashNumber.isNotEmpty) {
      buffer.writeln('বিকাশ/নগদ নম্বর,${somiti.bkashNumber}');
    }
    buffer.writeln('সভাপতি,${somiti.presidentName.isNotEmpty ? somiti.presidentName : "অনুল্লিখিত"}');
    buffer.writeln('সাধারণ সম্পাদক,${somiti.secretaryName.isNotEmpty ? somiti.secretaryName : "অনুল্লিখিত"}');
    buffer.writeln('কোষাধ্যক্ষ,${somiti.cashierName.isNotEmpty ? somiti.cashierName : "অনুল্লিখিত"}');
    buffer.writeln('রিপোর্ট তৈরির সময়,${DateFormat('dd-MMM-yyyy hh:mm a').format(now)}');
    buffer.writeln('মোট সদস্য সংখ্যা,${members.length} জন');
    buffer.writeln('মোট সঞ্চয় তহবিল,৳$totalDeposit');
    buffer.writeln('মোট সমিতি খরচ,৳$totalExpense');
    buffer.writeln('হাতে নগদ ক্যাশ (Cash in Hand),৳$cashInHand');
    buffer.writeln('মোট জমা লেনদেন,${deposits.length} টি');
    buffer.writeln('মোট খরচ এন্ট্রি,${expenses.length} টি');
    buffer.writeln('');

    buffer.writeln('----------------------------------------------------');
    buffer.writeln('                সদস্যভিত্তিক সঞ্চয় হিসাব');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('সদস্য নং,সদস্যের নাম,মোবাইল নম্বর,মোট সঞ্চয় (টাকা)');
    for (final m in members) {
      buffer.writeln('"${m.memberNumber}","${m.name}","${m.phone}",${m.totalDeposit}');
    }
    buffer.writeln('');

    buffer.writeln('----------------------------------------------------');
    buffer.writeln('             জমা ও কালেকশন লেনদেন হিস্ট্রি');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('তারিখ ও সময়,সদস্য নং,সদস্যের নাম,জমার ধরণ,পরিমাণ (টাকা),মন্তব্য/রসিদ,ডিভাইস');
    for (final d in deposits) {
      final formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(d.date);
      buffer.writeln('"$formattedDate","${d.memberNumber}","${d.memberName}","${d.type}",${d.amount},"${d.note}","${d.deviceSource}"');
    }
    buffer.writeln('');

    buffer.writeln('----------------------------------------------------');
    buffer.writeln('               সমিতির দৈনন্দিন খরচ খতিয়ান');
    buffer.writeln('----------------------------------------------------');
    buffer.writeln('তারিখ ও সময়,খরচের বিবরণ,ক্যাটাগরি,পরিমাণ (টাকা),নোট,রেকর্ডকারী');
    for (final e in expenses) {
      final formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(e.date);
      buffer.writeln('"$formattedDate","${e.title}","${e.category}",${e.amount},"${e.note}","${e.recordedBy}"');
    }

    final bytes = utf8.encode(buffer.toString());
    final media = drive.Media(Stream.value(bytes), bytes.length);

    final fileMetadata = drive.File()
      ..name = fileName
      ..mimeType = 'text/csv';

    return await driveApi.files.create(
      fileMetadata,
      uploadMedia: media,
      $fields: 'id, name, webViewLink',
    );
  }
}
