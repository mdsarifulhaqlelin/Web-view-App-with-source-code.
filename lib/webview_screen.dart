import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'no_internet.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  double appBarHeight = 56;

  @override
  void initState() {
    super.initState();
    checkInternet();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),

          // Real No Internet Detection
          onWebResourceError: (error) {
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.timeout) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NoInternetScreen()),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse("https://www.kothaipabo.xyz"));
  }

  /// Internet check
  void checkInternet() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NoInternetScreen()),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    }
    return true;
  }

  Future<void> _refreshPage() async {
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            /// WebView with bottom padding
            RefreshIndicator(
              onRefresh: _refreshPage,
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent && event.scrollDelta.dy > 0) {
                    setState(() => appBarHeight = 0); // hide on scroll down
                  }
                  if (event is PointerScrollEvent && event.scrollDelta.dy < 0) {
                    setState(() => appBarHeight = 56); // show on scroll up
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),   // ⬅️ bottom: 20 added
                  child: WebViewWidget(controller: controller),
                ),
              ),
            ),

            /// Animated AppBar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 0,
              left: 0,
              right: 0,
              height: appBarHeight,
              child: AppBar(
                title: const Text("Kothai Pabo"),
                centerTitle: true,
                elevation: 2,
                backgroundColor: Colors.blue,
              ),
            ),

            /// Loader
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
