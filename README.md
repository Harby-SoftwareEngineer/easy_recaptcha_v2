<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

A Flutter package that enables seamless integration of Google reCAPTCHA v2 into your app.
Version (0.1.0)
## Demo

![DemoGIF](https://i.postimg.cc/1zp02MDV/flutter-easy-recaptcha-v2.gif)

## Getting started

Add easy_recaptcha_v2 under your dependencies in the pubspec.yaml file.

```yml
 dependencies:
  flutter:
    sdk: flutter
  easy_recaptcha_v2: any
```
Import it to your Widget 

```dart
import 'package:easy_recaptcha_v2/easy_recaptcha_v2.dart';
```
And enjoy adding reCAPTCHA v2 to your without the need for any external web page.

## Configuration

🤖 Android: Make sure to add ```android:usesCleartextTraffic="true"``` under android/app/src/main/AndroidManifest.xml

```xml
 <application
    android:usesCleartextTraffic="true"
    ... >
```
🍏 IOS: No configuration required

## Usage

```dart
 void _showRecaptchaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 700,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    weight: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(
                height: 600,
                child: RecaptchaV2(
                  // Your API Key
                  apiKey: "Your api key",
                  onVerifiedSuccessfully: (token) async {
                    log("Recaptcha token $token");
                    // It is recommended to verify the token on your server but you can also verify it here.
                    final bool isTokenVerified = await verifyRecaptchaV2Token(
                      token: token,
                      apiSecret: "Your api secret",
                    );
                    if (isTokenVerified) {
                      log("Token verified successfully");
                      // Implement your logic here
                    } else {
                      log("Token verification failed");
                      // Implement your logic here
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
```

## Author

- [@MohamedBenHalima](https://github.com/mohamedbenalima)

Contact the developer : [![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mohamed-ben-halima-0967b217a/)
