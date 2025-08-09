import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectRolePage extends StatelessWidget {
  const SelectRolePage({super.key});
/*
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
  */
  @override
  Widget build(BuildContext context) {
    // 画面の幅を取得して、レスポンシブな余白を計算
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05; // 左右に5%ずつの余白

    // 全てのボタンに共通のスタイルを定義
    final ButtonStyle baseButtonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 53), // 幅を最大にし、高さを53に設定
      backgroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      // ボタンを押した時の波紋効果を無効化したい場合
      // splashFactory: NoSplash.splashFactory,
      // 影を調整したい場合
      //elevation: 2,
      alignment: Alignment.centerLeft, // 中の要素を左揃えにする
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // 左右に20pxの内側余白を追加
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.0),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // テキストを左寄せにする
          children: <Widget>[
            const Text(
              '当てはまるものを選んでください',
              style: TextStyle(color: Color(0xFF333333), fontSize: 13),
            ),
            const SizedBox(height: 10), // 見出しと最初のボタンの間のスペース

            ElevatedButton(
              onPressed: () {},
              child: Text(
                'エンジニア',
                style: TextStyle(color: Color(0xFF0D8BD9), fontSize: 18),
              ),
              style: baseButtonStyle,
            ),
            const SizedBox(height: 7), // ボタン間のスペース

            ElevatedButton(
              onPressed: () {},
              child: Text(
                'デザイナー',
                style: TextStyle(color: Color(0xFF7638FA), fontSize: 18),
              ),
              style: baseButtonStyle,
            ),
            const SizedBox(height: 7), // ボタン間のスペース

            ElevatedButton(
              onPressed: () {},
              child: Text(
                'PM',
                style: TextStyle(color: Color(0xFFF47A44), fontSize: 18),
              ),
              style: baseButtonStyle,
            ),
            const SizedBox(height: 7), // ボタン間のスペース

            ElevatedButton(
              onPressed: () {},
              child: Text(
                'ビギナー（初心者）',
                style: TextStyle(color: Color(0xFF65AE5E), fontSize: 18),
              ),
              style: baseButtonStyle,
            ),
            const SizedBox(height: 7), // ボタン間のスペース
          ],
        ),
      ),
    );
  }
}
