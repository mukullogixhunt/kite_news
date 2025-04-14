import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewArticle extends StatefulWidget {
  final String url;

  const WebViewArticle({super.key, required this.url});

  @override
  State<WebViewArticle> createState() => _WebViewArticleState();
}

class _WebViewArticleState extends State<WebViewArticle> {
  late final WebViewController _webViewController;

  void _showErrorToast(String message) {}

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {});
              },

              onPageFinished: (String url) {
                setState(() {});
              },

              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },

              onWebResourceError: (WebResourceError error) {
                setState(() {
                  _showErrorToast(error.description);
                });
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url), method: LoadRequestMethod.get);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
