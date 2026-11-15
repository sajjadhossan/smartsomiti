import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  static const String _liveUrl = 'https://smartsomiti.vercel.app';
  static const String _chromeUserAgent =
      'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setUserAgent(_chromeUserAgent)
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

    _loadContent();
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          SystemNavigator.pop();
        }
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
