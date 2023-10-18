# tencent_captcha

Flutter 版本的腾讯云验证码
 
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
 

<!-- END doctoc generated TOC please keep comment here to allow auto update -->
 
## 快速开始

### 安装

将此添加到包的 pubspec.yaml 文件中：

```yaml
dependencies:
  tencent_captcha: ^0.1.0
```

您可以从命令行安装软件包：

```bash
$ flutter packages get
```

### 使用

#### 初始化 SDK

```dart
TencentCaptcha.init('<appId>');
```

#### 开始验证

> 详细文档请参见：https://cloud.tencent.com/document/product/1110/36841

```dart
import 'package:flutter/material.dart';
import 'package:tencent_captcha/tencent_captcha.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TencentCaptcha.init('111111111');
    return MaterialApp(
      title: 'Flutter Tencent Captcha Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Tencent Captcha Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void showCaptcha() {
    TencentCaptcha.verify(context: context);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.orange,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showCaptcha,
        tooltip: 'showCaptcha',
        child: const Icon(Icons.verified),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
```

## 许可证

[MIT](./LICENSE)