import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SomitiApp());
}

class SomitiApp extends StatelessWidget {
  const SomitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'স্মার্ট সমিতি',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58),
          primary: const Color(0xFF0F9D58),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: const SomitiWebWrapperScreen(),
    );
  }
}

class SomitiWebWrapperScreen extends StatefulWidget {
  const SomitiWebWrapperScreen({super.key});

  @override
  State<SomitiWebWrapperScreen> createState() => _SomitiWebWrapperScreenState();
}

class _SomitiWebWrapperScreenState extends State<SomitiWebWrapperScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadTimeoutTimer;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  static const String _liveUrl = 'https://smartsomiti.vercel.app';
  static const String _chromeUserAgent =
      'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36';

  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _requestStartupPermissions();
    _initController();
  }

  Future<void> _requestStartupPermissions() async {
    try {
      final statuses = await [
        Permission.camera,
        Permission.photos,
        Permission.storage,
        Permission.notification,
      ].request();
      debugPrint('Startup permissions requested: $statuses');
    } catch (e) {
      debugPrint('Startup permission notice: $e');
    }
  }

  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _performNativeGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('Google Sign-In cancelled by user');
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;
      final String email = account.email;
      final String displayName = account.displayName ?? '';
      final String photoUrl = account.photoUrl ?? '';
      final String uid = account.id;

      // Sync Firebase Auth natively
      try {
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      } catch (fbErr) {
        debugPrint('Native FirebaseAuth sync notice: $fbErr');
      }

      final payload = jsonEncode({
        'idToken': idToken,
        'accessToken': accessToken,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'uid': uid,
      });

      await _controller.runJavaScript('''
        if (typeof window.handleNativeGoogleSignInResult === 'function') {
          window.handleNativeGoogleSignInResult($payload);
        }
      ''');
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      final errPayload = jsonEncode(e.toString());
      await _controller.runJavaScript('''
        alert("গুগল সাইন-ইন সম্পন্ন করা সম্ভব হয়নি: " + $errPayload);
      ''');
    }
  }

  Future<void> _handleNativeSignOut() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Native signOut notice: $e');
    }
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setUserAgent(_chromeUserAgent)
      ..addJavaScriptChannel(
        'NativeAuthBridge',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'google_sign_in') {
            _performNativeGoogleSignIn();
          } else if (message.message == 'google_sign_out') {
            _handleNativeSignOut();
          }
        },
      )
      ..addJavaScriptChannel(
        'NativePermissionBridge',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'request_permissions') {
            _requestStartupPermissions();
          }
        },
      )
      ..addJavaScriptChannel(
        'NativeFileBridge',
        onMessageReceived: (JavaScriptMessage message) async {
          if (message.message.startsWith('pick_image:')) {
            final callbackId = message.message.substring('pick_image:'.length);
            try {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                final bytes = await image.readAsBytes();
                final base64Str = base64Encode(bytes);
                final mimeType = image.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
                final dataUrl = 'data:$mimeType;base64,$base64Str';
                final escapedUrl = jsonEncode(dataUrl);
                await _controller.runJavaScript('''
                  if (typeof window.handleNativePickedImage === 'function') {
                    window.handleNativePickedImage("$callbackId", $escapedUrl);
                  }
                ''');
              }
            } catch (err) {
              debugPrint('Native image picker bridge error: $err');
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress >= 70 && mounted && _isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            debugPrint('Page started: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished: $url');
            _loadTimeoutTimer?.cancel();
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebResourceError (${error.errorCode}): ${error.description}');
            if (error.isForMainFrame ?? false) {
              _loadOfflineFallback();
            }
          },
        ),
      );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final platform = _controller.platform;
      if (platform is AndroidWebViewController) {
        platform.setOnShowFileSelector(_androidFilePicker);
      }
    }

    _loadContent();
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    try {
      final ImagePicker picker = ImagePicker();
      if (params.mode == FileSelectorMode.openMultiple) {
        final List<XFile> images = await picker.pickMultiImage();
        return images.map((img) => Uri.file(img.path).toString()).toList();
      } else {
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          return [Uri.file(image.path).toString()];
        }
      }
    } catch (e) {
      debugPrint('Error in _androidFilePicker: $e');
    }
    return [];
  }

  Future<void> _loadContent() async {
    // 7 second timeout: if live URL fails or hangs, switch to bundled offline asset
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = Timer(const Duration(seconds: 7), () {
      if (mounted && _isLoading) {
        debugPrint('Live URL timeout, switching to local offline asset...');
        _loadOfflineFallback();
      }
    });

    try {
      await _controller.loadRequest(Uri.parse(_liveUrl));
    } catch (e) {
      debugPrint('Exception loading live URL: $e');
      await _loadOfflineFallback();
    }
  }

  Future<void> _loadOfflineFallback() async {
    _loadTimeoutTimer?.cancel();
    try {
      await _controller.loadFlutterAsset('assets/index.html');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Exception loading offline asset: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _handleBackPress() async {
    try {
      final dynamic jsHandled = await _controller.runJavaScriptReturningResult(
        "(function() { return (typeof window.handleAndroidBack === 'function') ? window.handleAndroidBack() : false; })();",
      );
      if (jsHandled == true || jsHandled == 'true') {
        // Modal, overlay, or subview handled by JavaScript
        return;
      }
    } catch (e) {
      debugPrint('Back navigation error: $e');
    }

    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'অ্যাপ থেকে বের হতে আবার ব্যাক চাপুন',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        );
      }
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Full-screen WebView filling the entire screen perfectly
              Positioned.fill(
                child: WebViewWidget(controller: _controller),
              ),

              // 2. Branded Splash / Loading screen (avoids any blank white screen)
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFFFFFFF),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE8F5E9),
                              border: Border.all(
                                color: const Color(0xFF0F9D58),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F9D58).withOpacity(0.18),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🏛️', style: TextStyle(fontSize: 42)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'স্মার্ট সমিতি',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F9D58),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'ডিজিটাল সমবায় ও হিসাব ব্যবস্থাপনা',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0F9D58),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'লোড হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন...',
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 3. Error state if both live and offline asset fail
              if (_hasError)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 56,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'অ্যাপ লোড করা সম্ভব হয়নি',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _hasError = false;
                              });
                              _loadContent();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0F9D58),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('আবার চেষ্টা করুন'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
