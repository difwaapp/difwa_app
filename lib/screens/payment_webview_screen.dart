import 'package:difwa_app/utils/theme_constant.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final double amount;
  final String userId;

  const PaymentWebViewScreen({
    super.key,
    required this.initialUrl,
    required this.amount,
    required this.userId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true; // to manage loading state

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        // Handling URL changes
        onUrlChange: (UrlChange urlChange) {
          print("🌐 Loading URL: ${urlChange.url}");

          setState(() {
            _isLoading = true;
          });

          String url = urlChange.url.toString();

          // Parse the URL
          Uri uri = Uri.parse(url);

          // Extract query parameters
          String? paymentId = uri.queryParameters["payment_id"];
          String? status = uri.queryParameters["status"];

          // Print values
          print("URL: $url");
          print("Payment ID: $paymentId");
          print("Status: $status");

          // Check if URL contains the required query parameters
          if (urlChange.url!.contains("status") &&
              urlChange.url!.contains("payment_id")) {
            Uri uri = Uri.parse(urlChange.url!); // Convert URL to Uri object
            String? status = uri.queryParameters["status"];
            String? paymentId = uri.queryParameters["payment_id"];

            print("Parsed URL: $uri");
            print("Payment Status: $status");
            print("Payment ID: $paymentId");

            // Handle payment result
            if (status != null && paymentId != null) {
              if (status == "success") {
                Navigator.pop(
                    context, {"status": "success", "payment_id": paymentId});
              } else {
                Navigator.pop(context, {"status": "failed"});
              }
            } else {
              // In case status or payment_id is missing
              print("Error: status or payment_id is missing.");
              Navigator.pop(context, {"status": "failed"});
            }
          } else {
            print("URL does not contain required parameters.");
          }
        },

        // This gets called when the page finishes loading
        onPageFinished: (String url) {
          print("✅ Finished Loading: $url");

          if (url.contains("status") && url.contains("payment_id")) {
            Uri uri = Uri.parse(url);
            String? status = uri.queryParameters["status"];
            String? paymentId = uri.queryParameters["payment_id"];
            print("Payment Status: $status");
            print("Payment ID: $paymentId");
          }

          setState(() {
            _isLoading = false;
          });
        },

        // Handling WebView errors
        onWebResourceError: (WebResourceError error) {
          print("❌ Webview Error: $error");
          setState(() {
            _isLoading = false;
          });
        },
      ))
      ..loadRequest(Uri.parse(widget.initialUrl)); // Load the initial URL

    // Handle Android-specific WebChromeClient issues
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setOnPlatformPermissionRequest(
        (request) => request.grant(),
      );
    }
  }

  // Handle back navigation
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Preventing back navigation if necessary
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // WebView
              WebViewWidget(controller: _controller),

              // Loading Indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: ThemeConstants.primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
