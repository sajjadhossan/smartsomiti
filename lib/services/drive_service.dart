import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';
import '../models/member_model.dart';
import '../models/deposit_model.dart';
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
    required List<MemberModel> members,
    required List<DepositModel> deposits,
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      throw Exception('Google Drive ক্লায়েন্ট অথেনটিকেটেড নয়। দয়া করে পুনরায় সাইন-ইন করুন।');
    }

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(now);
    final fileName = 'Somiti_Statement_$dateStr.csv';

    final double totalFund = members.fold(0.0, (sum, m) => sum + m.totalDeposit);

    final buffer = StringBuffer();
    // UTF-8 BOM so Excel opens Bengali text properly
    buffer.write('\uFEFF');

    buffer.writeln('--- সমিতি রিপোর্ট ও পূর্ণাঙ্গ স্টেটমেন্ট ---');
    buffer.writeln('তারিখ,${DateFormat('dd-MMM-yyyy hh:mm a').format(now)}');
    buffer.writeln('মোট সদস্য,${members.length}');
    buffer.writeln('মোট সঞ্চয়/তহবিল,৳$totalFund');
    buffer.writeln('');

    buffer.writeln('--- সদস্যভিত্তিক সারসংক্ষেপ ---');
    buffer.writeln('সদস্য নং,সদস্যের নাম,মোবাইল নম্বর,মোট জমা (টাকা)');
    for (final m in members) {
      buffer.writeln('"${m.memberNumber}","${m.name}","${m.phone}",${m.totalDeposit}');
    }
    buffer.writeln('');

    buffer.writeln('--- জমা ও কালেকশন স্টেটমেন্ট ---');
    buffer.writeln('তারিখ,সদস্য নং,সদস্যের নাম,জমার ধরণ,পরিমাণ (টাকা),মন্তব্য,ডিভাইস');
    for (final d in deposits) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(d.date);
      buffer.writeln('"$formattedDate","${d.memberNumber}","${d.memberName}","${d.type}",${d.amount},"${d.note}","${d.deviceSource}"');
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
