library easy_recaptcha_v2;

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

InAppLocalhostServer localhostServer = InAppLocalhostServer();

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await localhostServer.start();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(
                Uri.parse(
                  "http://localhost:8080/packages/easy_recaptcha_v2/assets/index.html?api_key=${widget.apiKey}&hl=${widget.lang}",
                ),
              ),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) {},
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
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

  @override
  void dispose() {
    localhostServer.close();
    super.dispose();
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
