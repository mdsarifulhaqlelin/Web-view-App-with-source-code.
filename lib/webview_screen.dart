// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'no_internet.dart';

// class WebViewScreen extends StatefulWidget {
//   const WebViewScreen({super.key});

//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late final WebViewController controller;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) {
//             setState(() => isLoading = true);
//           },
//           onPageFinished: (url) {
//             setState(() => isLoading = false);
//           },
//           onWebResourceError: (error) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => NoInternetScreen()),
//             );
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse("https://www.kothaipabo.xyz"));
//   }

//   Future<bool> _onWillPop() async {
//     if (await controller.canGoBack()) {
//       controller.goBack();
//       return false;
//     } else {
//       return true;
//     }
//   }

//   Future<void> _refreshPage() async {
//     controller.reload();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ignore: deprecated_member_use
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         body: RefreshIndicator(
//           onRefresh: _refreshPage,
//           child: Stack(
//             children: [
//               WebViewWidget(controller: controller),
//               if (isLoading)
//                 const Center(child: CircularProgressIndicator()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ✅ এখন আপনার AppBar — স্ক্রল করলে Hide হয়ে যাবে, আবার উপরের দিকে স্ক্রল করলে ফিরে আসবে।

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

  double appBarHeight = 56; // Default height
  double lastScroll = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => NoInternetScreen()),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse("https://www.kothaipabo.xyz"));
  }

  Future<bool> _onWillPop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    } else {
      return true;
    }
  }

  Future<void> _refreshPage() async {
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: appBarHeight,
            child: AppBar(
              title: const Text("Kothai Pabo"),
              centerTitle: true,
            ),
          ),
        ),

        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            double current = scrollInfo.metrics.pixels;

            if (current > lastScroll) {
              // scrolling down → hide AppBar
              setState(() => appBarHeight = 0);
            } else {
              // scrolling up → show AppBar
              setState(() => appBarHeight = 56);
            }

            lastScroll = current;
            return true;
          },

          child: RefreshIndicator(
            onRefresh: _refreshPage,
            child: Stack(
              children: [
                WebViewWidget(controller: controller),
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
