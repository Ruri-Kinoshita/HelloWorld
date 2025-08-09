import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld/routes.dart'; // goRouter が定義されている想定
import 'package:app_links/app_links.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart'; // context.goNamed を使うため

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // ★ GoRouter の「下」に DeepLinkListener を配置
      builder: (context, child) {
        return _DeepLinkListener(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// GoRouter の context が有効な階層でディープリンクを処理するウィジェット
class _DeepLinkListener extends StatefulWidget {
  const _DeepLinkListener({required this.child});
  final Widget child;

  @override
  State<_DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<_DeepLinkListener> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();

    // 起動後に受け取るリンク（ホット/バックグラウンド → フォアグラウンド）
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (!mounted || uri == null) return;
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error receiving link: $err');
    });

    // ※ 必要なら「初期リンク（cold start）」もここで拾って同じハンドラに流す
    //  app_links 6.x には getInitialAppLink が無いため、ネイティブ連携等が必要。
    //  実装する場合は、初期リンクを取得して _handleDeepLink(initialUri) を呼んでください。
  }

  void _handleDeepLink(Uri uri) {
    // カスタムスキーム例:
    // helloWorld://receive
    // helloWorld://receive?name=kinoshita
    final host = uri.host; // 'receive'
    final qp = uri.queryParameters; // {'name': 'kinoshita'} など

    // 1フレーム後に遷移（build 中の呼び出しを避けるため）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (host == 'receive') {
        if (qp.isNotEmpty) {
          context.goNamed('receivepage', queryParameters: qp);
        } else {
          context.goNamed('receivepage');
        }
      } else {
        // 想定外は必要に応じてホーム等へ
        // context.goNamed('home');
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
