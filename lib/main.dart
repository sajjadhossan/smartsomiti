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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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
  int _loadingProgress = 0;
  bool _isLoading = true;
  bool _hasError = false;

  static const String _liveUrl = 'https://smartsomiti.vercel.app';
  static const String _chromeUserAgent =
      'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8F9FA))
      ..setUserAgent(_chromeUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebResourceError: ${error.errorCode} - ${error.description}');
            if (error.isForMainFrame ?? false) {
              _loadOfflineFallback();
            }
          },
        ),
      );

    _loadInitialContent();
  }

  Future<void> _loadInitialContent() async {
    try {
      await _controller.loadRequest(Uri.parse(_liveUrl));
    } catch (e) {
      debugPrint('Failed to load live URL, loading offline fallback: $e');
      await _loadOfflineFallback();
    }
  }

  Future<void> _loadOfflineFallback() async {
    if (mounted) {
      setState(() {
        _hasError = false;
      });
    }
    try {
      await _controller.loadFlutterAsset('assets/index.html');
    } catch (e) {
      debugPrint('Error loading offline asset: $e');
      if (mounted) {
        setState(() {
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
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFF0F9D58),
                onRefresh: () async {
                  await _controller.reload();
                },
                child: WebViewWidget(controller: _controller),
              ),
              if (_isLoading)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: _loadingProgress / 100.0,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F9D58)),
                    minHeight: 2.5,
                  ),
                ),
              if (_hasError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 56,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ইন্টারনেট সংযোগ পাওয়া যায়নি',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'অনুগ্রহ করে ডাটা বা ওয়াইফাই সংযোগ চালু করে আবার চেষ্টা করুন।',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            _controller.reload();
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
            ],
          ),
        ),
      ),
    );
  }
}
