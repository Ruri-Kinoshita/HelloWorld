import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Startpage extends StatelessWidget {
  const Startpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 中央寄せ
            children: [
              const Text(
                'スタートページ', //一番最初のページ，もらったと作ったのページ
                style: TextStyle(
                  fontSize: 24, // 文字サイズ
                  fontWeight: FontWeight.bold, // 太字
                ),
              ),
              const SizedBox(height: 20), // 文字とボタンの間隔
              ElevatedButton(
                onPressed: () {
                  context.push('/photo');
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
