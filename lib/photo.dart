import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class photoPage extends StatelessWidget {
  const photoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 中央寄せ
            children: [
              const Text(
                'アイコン生成用写真撮影ページ', //顔写真とるページ
                style: TextStyle(
                  fontSize: 24, // 文字サイズ
                  fontWeight: FontWeight.bold, // 太字
                ),
              ),
              const SizedBox(height: 20), // 文字とボタンの間隔
              ElevatedButton(
                onPressed: () {
                  context.push('/role');
                  debugPrint('ボタンが押されました');
                },
                child: const Text('押してね'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
