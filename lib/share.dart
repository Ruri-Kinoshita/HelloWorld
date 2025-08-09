import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sharepage extends StatelessWidget {
  const Sharepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 中央寄せ
            children: [
              const Text(
                '最終盤のプロフィールが出るページ', //リンクとかが出るのもここ
                style: TextStyle(
                  fontSize: 24, // 文字サイズ
                  fontWeight: FontWeight.bold, // 太字
                ),
              ),
              const SizedBox(height: 20), // 文字とボタンの間隔
              ElevatedButton(
                onPressed: () {
                  context.push('/');
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
