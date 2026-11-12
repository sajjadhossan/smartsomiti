import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
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

  Future<drive.File?> uploadTextFile({
    required String title,
    required String content,
    String? existingFileId,
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      throw Exception('Google Drive client is not authenticated.');
    }

    final bytes = utf8.encode(content);
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
    );

    if (existingFileId != null && existingFileId.isNotEmpty) {
      final fileMetadata = drive.File()..name = '$title.txt';
      return await driveApi.files.update(
        fileMetadata,
        existingFileId,
        uploadMedia: media,
      );
    } else {
      final fileMetadata = drive.File()
        ..name = '$title.txt'
        ..mimeType = 'text/plain';

      return await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
        $fields: 'id, name, webViewLink',
      );
    }
  }

  Future<void> deleteFile(String fileId) async {
    final driveApi = await _getDriveApi();
    if (driveApi != null && fileId.isNotEmpty) {
      try {
        await driveApi.files.delete(fileId);
      } catch (_) {
        // Ignored if already removed
      }
    }
  }
}
