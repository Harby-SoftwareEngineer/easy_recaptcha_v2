library easy_recaptcha_v2;

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

const int _port = 8081;
final InAppLocalhostServer localhostServer = InAppLocalhostServer(port: _port);

class RecaptchaV2 extends StatefulWidget {
  final String apiKey;
  final String? lang;

  final ValueChanged<String>? onVerifiedSuccessfully;

  const RecaptchaV2({
    super.key,
    required this.apiKey,
    this.lang = "en",
    this.onVerifiedSuccessfully,
  });

  @override
  State<StatefulWidget> createState() => _RecaptchaV2State();
}

class _RecaptchaV2State extends State<RecaptchaV2> {
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    // The localhost server is now expected to be started by the app developer
    // before this widget is used.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(
                Uri.parse(
                  "http://localhost:$_port/packages/easy_recaptcha_v2/assets/index.html?api_key=${widget.apiKey}&hl=${widget.lang}",
                ),
              ),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) {},
            onLoadStop: (controller, url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              log("[easy_recaptcha_v2] consoleMessage ${consoleMessage.message}");
              if (consoleMessage.messageLevel == ConsoleMessageLevel.LOG &&
                  // Verifying if the string is a token or not.
                  consoleMessage.message.length > 70) {
                String token = consoleMessage.message;
                if (token.contains("verify")) {
                  token = token.substring(7);
                }
                widget.onVerifiedSuccessfully?.call(token);
              }
            },
          );
  }
}

Future<bool> verifyRecaptchaV2Token({
  required String token,
  required String apiSecret,
}) async {
  String url = "https://www.google.com/recaptcha/api/siteverify";
  http.Response response = await http.post(Uri.parse(url), body: {
    "secret": apiSecret,
    "response": token,
  });

  if (response.statusCode == 200) {
    dynamic json = jsonDecode(response.body);
    if (json['success']) {
      return true;
    } else {
      log("[easy_recaptcha_v2] Error while verifying recaptcha token: ${json['error-codes'].toString()}");
      return false;
    }
  }
  log("[easy_recaptcha_v2] Error while verifying recaptcha token");
  return false;
}
