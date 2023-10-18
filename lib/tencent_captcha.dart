import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TencentCaptcha {
  static String? sdkAppId;
  static Function(dynamic)? dismissCallback;
  static Function(dynamic)? verifySuccessCallback;
  static Function(dynamic)? verifyFailCallback;
  static num viewSize = 350.0;

  static void init(String appId) {
    sdkAppId = appId;
  }

  static Future<void> verify(
      {required BuildContext context, String? appId}) async {
    appId ??= sdkAppId;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          backgroundColor: Colors.transparent,
          content: appId != null
              ? Container(
                  height: viewSize.toDouble(),
                  width: viewSize.toDouble(),
                  color: Colors.white,
                  child: Center(child: TencentCaptchaView(appId: appId)))
              : SizedBox(
                  height: viewSize.toDouble(),
                  width: viewSize.toDouble(),
                  child: const Center(child: Text('请先初始化验证SDK'))),
        );
      },
    );
  }
}

class TencentCaptchaResult {
  String? appId;
  int? ret;
  String? ticket;
  String? randStr;

  TencentCaptchaResult({this.appId, this.ret, this.ticket, this.randStr});

  TencentCaptchaResult.fromJson(Map<String, dynamic> json) {
    appId = json['appid'];
    ret = json['ret'];
    ticket = json['ticket'];
    randStr = json['randstr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['appid'] = appId;
    data['ret'] = ret;
    data['ticket'] = ticket;
    data['randstr'] = randStr;
    return data;
  }
}

class TencentCaptchaView extends StatefulWidget {
  final String appId;

  const TencentCaptchaView({Key? key, required this.appId}) : super(key: key);

  @override
  State<TencentCaptchaView> createState() => _TencentCaptchaViewState();
}

class _TencentCaptchaViewState extends State<TencentCaptchaView> {
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        cacheMode: AndroidCacheMode.LOAD_NO_CACHE, // 禁用缓存
      ),
      ios: IOSInAppWebViewOptions());

  num _viewSize = 350.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _viewSize.toDouble(),
      height: _viewSize.toDouble(),
      child: InAppWebView(
        initialData:
            InAppWebViewInitialData(data: webBridgeHtmlJS(appId: widget.appId)),
        initialOptions: options,
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
              handlerName: 'loadAction',
              callback: (args) {
                // 加载成功, 更新webview的frame
                _viewSize = args.first['sdkView']['width'];
                print(_viewSize);
                if (mounted) {
                  setState(() {});
                }
              });
          controller.addJavaScriptHandler(
              handlerName: 'verifiedAction',
              callback: (args) {
                // 划动验证
                TencentCaptchaResult result =
                    TencentCaptchaResult.fromJson(args.first);
                if (result.ret == 0) {
                  Navigator.pop(context, true);
                  // 验证成功
                  TencentCaptcha.verifySuccessCallback != null
                      ? TencentCaptcha.verifySuccessCallback!(result)
                      : null;
                } else if (result.ret == 2) {
                  // 点击关闭
                  Navigator.pop(context, true);
                  TencentCaptcha.dismissCallback != null
                      ? TencentCaptcha.dismissCallback!(result)
                      : null;
                } else {
                  debugPrint('verifiedActionResult == ${result.toJson()}');
                }
              });
          controller.addJavaScriptHandler(
              handlerName: 'errorAction',
              callback: (args) {
                TencentCaptcha.verifyFailCallback != null
                    ? TencentCaptcha.verifyFailCallback!(args.first)
                    : null;
              });
        },
      ),
    );
  }

  String webBridgeHtmlJS({required String appId}) {
    var random =
        (DateTime.now().millisecondsSinceEpoch / 100).toStringAsFixed(0);
    return """
          <!DOCTYPE html>
          <html>
          <head>
                  <meta charset="UTF-8">
                  <meta http-equiv="X-UA-Compatible" content="IE=edge">
                  <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0">
                  <script src="https://turing.captcha.qcloud.com/TCaptcha.js?$random" type="text/javascript"></script>
          </head>
          <body>
          
          <script type="text/javascript">
                     (function() {
                         // 验证成功返回ticket
                         window.SDKTCaptchaVerifyCallback = function(retJson) {
                             if (retJson) {
                                 window.flutter_inappwebview.callHandler('verifiedAction', ...[retJson]);
                             }
                         };
                         // 验证码加载完成的回调，用来设置webview尺寸
                         window.SDKTCaptchaReadyCallback = function(retJson) {
                             if (retJson && retJson.sdkView && retJson.sdkView.width && retJson.sdkView.height && parseInt(retJson.sdkView.width) > 0 && parseInt(retJson.sdkView.height) > 0) {
                                 window.flutter_inappwebview.callHandler('loadAction', ...[retJson]);
                             }
                         };
                         window.onerror = function(msg, url, line, col, error) {
                             if (window.TencentCaptcha == null) {
                                 window.flutter_inappwebview.callHandler('errorAction', ...[error]);
                             }
                         };
                         var sdkOptions = {"sdkOpts": {"width": $_viewSize, "height": $_viewSize}};
                         sdkOptions.ready = window.SDKTCaptchaReadyCallback;
                         window.onload = function () {
                             // appid
                             new TencentCaptcha("$appId", SDKTCaptchaVerifyCallback, sdkOptions).show();
                         };
                      })();
          </script>
          </body>
          </html>
          """;
  }
}
