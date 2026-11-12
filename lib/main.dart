import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'models/note_model.dart';
import 'services/auth_service.dart';
import 'services/drive_service.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
  runApp(const CloudSyncApp());
}

class CloudSyncApp extends StatelessWidget {
  const CloudSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Sync & Drive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return SyncHomeScreen(user: user);
        }

        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final cred = await AuthService().signInWithGoogle();
      if (cred == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সাইন-ইন বাতিল করা হয়েছে।')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('লগইন ব্যর্থ হয়েছে: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_sync_rounded,
                    size: 72,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cloud Sync & Drive',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'রিয়েলটাইম ডিভাইস-টু-ডিভাইস এবং ওয়েব ডেটা সিঙ্ক ও গুগল ড্রাইভ ব্যাকআপ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                _FeatureItem(
                  icon: Icons.account_circle_outlined,
                  title: 'Google অ্যাকাউন্ট লগইন',
                  subtitle: 'এক ক্লিকে নিরাপদ গুগল সাইন-ইন',
                ),
                const SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.add_to_drive_outlined,
                  title: 'Google ড্রাইভ সিঙ্ক',
                  subtitle: 'নোট ও ডকুমেন্ট স্বয়ংক্রিয়ভাবে ড্রাইভে সেভ',
                ),
                const SizedBox(height: 16),
                _FeatureItem(
                  icon: Icons.sync_rounded,
                  title: 'রিয়েলটাইম ক্রস-ডিভাইস সিঙ্ক',
                  subtitle: 'মোবাইল বা ওয়েবে যা লিখবেন, সব ডিভাইসে সাথে সাথে সিঙ্ক হবে',
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  FilledButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'Google দিয়ে সরাসরি সাইন-ইন করুন',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SyncHomeScreen extends StatefulWidget {
  final User user;
  const SyncHomeScreen({super.key, required this.user});

  @override
  State<SyncHomeScreen> createState() => _SyncHomeScreenState();
}

class _SyncHomeScreenState extends State<SyncHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final DriveService _driveService = DriveService();

  void _showNoteDialog({NoteModel? existingNote}) {
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');
    bool syncToDrive = existingNote?.driveFileId != null || existingNote == null;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existingNote == null ? 'নতুন নোট / ডকুমেন্ট' : 'নোট সম্পাদনা'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'শিরোনাম (Title)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'বিস্তারিত কনটেন্ট (Content)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Google ড্রাইভে সেভ/ব্যাকআপ রাখুন'),
                    value: syncToDrive,
                    onChanged: isSaving
                        ? null
                        : (val) {
                            setDialogState(() => syncToDrive = val ?? false);
                          },
                  ),
                  if (isSaving)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('ড্রাইভ ও ক্লাউডে সিঙ্ক হচ্ছে...'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final content = contentController.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('দয়া করে একটি শিরোনাম লিখুন')),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);

                        String? driveFileId = existingNote?.driveFileId;
                        String? webViewLink = existingNote?.driveWebViewLink;

                        if (syncToDrive) {
                          try {
                            final driveFile = await _driveService.uploadTextFile(
                              title: title,
                              content: content,
                              existingFileId: driveFileId,
                            );
                            if (driveFile != null) {
                              driveFileId = driveFile.id;
                              webViewLink = driveFile.webViewLink;
                            }
                          } catch (e) {
                            debugPrint('Google Drive sync note: $e');
                          }
                        }

                        final String device = kIsWeb
                            ? 'Web Browser'
                            : 'Mobile Device';

                        final note = NoteModel(
                          id: existingNote?.id ?? '',
                          title: title,
                          content: content,
                          driveFileId: driveFileId,
                          driveWebViewLink: webViewLink,
                          updatedAt: DateTime.now(),
                          deviceSource: device,
                        );

                        await _firestoreService.saveNote(widget.user.uid, note);

                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('রিয়েলটাইমে সিঙ্ক সম্পন্ন হয়েছে!')),
                          );
                        }
                      },
                child: const Text('সেভ করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteNote(NoteModel note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নোট মুছে ফেলতে চান?'),
        content: Text('"${note.title}" সম্পূর্ণভাবে ডিলিট হয়ে যাবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('ডিলিট'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (note.driveFileId != null) {
        await _driveService.deleteFile(note.driveFileId!);
      }
      await _firestoreService.deleteNote(widget.user.uid, note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মুছে ফেলা হয়েছে')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cloud Sync & Drive',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email ?? user.displayName ?? '',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'লগআউট',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            child: Row(
              children: [
                const Icon(
                  Icons.sensors_rounded,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'লাইভ সিঙ্ক চালু আছে: যেকোনো ডিভাইসে যোগ করলে এখানে স্বয়ংক্রিয়ভাবে আপডেট হবে',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<NoteModel>>(
              stream: _firestoreService.getNotesStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'ডেটা লোড করতে সমস্যা হয়েছে:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  );
                }

                final notes = snapshot.data ?? [];
                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'এখনও কোনো নোট নেই',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'নিচের বাটনে ট্যাপ করে নতুন নোট যোগ করুন।',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                final dateFormat = DateFormat('dd MMM, hh:mm a');

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final isDriveBackedUp = note.driveFileId != null && note.driveFileId!.isNotEmpty;

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateFormat.format(note.updatedAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (isDriveBackedUp)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                                        SizedBox(width: 4),
                                        Text(
                                          'Drive Synced',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showNoteDialog(existingNote: note);
                            } else if (value == 'delete') {
                              _deleteNote(note);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('সম্পাদনা'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('মুছে ফেলুন', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showNoteDialog(existingNote: note),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('নতুন ডেটা যোগ করুন'),
      ),
    );
  }
}
