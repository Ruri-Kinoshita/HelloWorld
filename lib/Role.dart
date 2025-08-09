import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectRolePage extends StatelessWidget {
  const SelectRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 中央寄せ
            children: [
              const Text(
                '役職選ぶページ', //4つの選択肢から選ぶ
                style: TextStyle(
                  fontSize: 24, // 文字サイズ
                  fontWeight: FontWeight.bold, // 太字
                ),
              ),
              const SizedBox(height: 20), // 文字とボタンの間隔
              ElevatedButton(
                onPressed: () {
                  context.push('/create');
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
