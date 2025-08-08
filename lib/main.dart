import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // --- ▼▼▼ ここからが主な変更点 ▼▼▼ ---

  // 1. UIに表示するための状態変数を準備
  String _generatedText = 'ボタンを押して物語を生成してください';
  bool _isLoading = false;

  // 2. APIを呼び出すための関数を作成
  Future<void> _generateStory() async {
    // 処理中であることをUIに伝える
    setState(() {
      _isLoading = true;
    });

    try {
      // Geminiモデルを初期化（モデル名を正しいものに変更）
      final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-pro');
      final prompt = [Content.text('魔法のバックパックについての短い物語を書いて。')];
      final response = await model.generateContent(prompt);

      // 成功したら、結果を状態変数に保存してUIを更新
      setState(() {
        _generatedText = response.text ?? 'エラー: テキストが生成されませんでした';
        _isLoading = false;
      });
    } catch (e) {
      // エラーが発生した場合
      setState(() {
        _generatedText = 'エラーが発生しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // --- ▲▲▲ ここまでが主な変更点 ▲▲▲ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView( // 長い文章が表示されてもスクロールできるようにする
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 3. 状態に応じてUIの表示を切り替える
              if (_isLoading)
                const CircularProgressIndicator() // 処理中ならローディング表示
              else
                SelectableText( // 生成されたテキストを選択・コピー可能にする
                  _generatedText,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
      // 4. ボタンを押したらAPIを呼び出すように変更
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _generateStory, // 処理中はボタンを押せないようにする
        tooltip: 'Generate Story',
        child: const Icon(Icons.auto_awesome), // アイコンを変更
      ),
    );
  }
}