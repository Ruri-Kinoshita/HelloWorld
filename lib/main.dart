import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'dart:typed_data';


import 'package:image_picker/image_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  // Initialize the Gemini Developer API backend service
  // Create a `GenerativeModel` instance with a Gemini model that supports image output
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash-preview-image-generation',
    // GenerationConfigの設定を調整
    generationConfig: GenerationConfig(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
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
  Uint8List? _generatedImageBytes;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  String _statusText = 'ボタンを押して物語を生成してください';
  String _generatedText = 'ここに生成された物語が表示されます。';

  final ImagePicker _picker = ImagePicker();

  // --- 2. ユーザーが画像を選択するための関数です ---
  Future<void> _pickImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _statusText = '画像が選択されました！下のボタンで生成を開始します。';
        _generatedImageBytes = null; // 新しい画像を選んだら前の結果をクリア
      });
    }
  }

  Future<void> _generateImage() async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先に画像を選択してください。')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusText = 'アートを生成中です...';
    });

    try {
      final vertexAI = FirebaseVertexAI.instanceFor(location: 'asia-northeast1');
      final model = vertexAI.generativeModel(model: 'gemini-1.5-pro');

      final prompt = [
        Content.multi([
          InlineDataPart('image/jpeg', _selectedImageBytes!),
          TextPart(
            'TASK: Image-to-Image Transformation. '
            'INPUT: 1 image (attached). '
            'OUTPUT_FORMAT: 1 image (image/png). '
            'STYLE: Pixel art, inspired by the game "Everskies". '
            'COMPOSITION: Full-body illustration. '
            'BACKGROUND: Transparent. '
            'INSTRUCTIONS: Faithfully reproduce clothing, hairstyle, accessories, facial expression, and colors from the attached input image. '
            'RESPONSE_CONSTRAINT: Your response must ONLY be the raw image data. DO NOT include any text, markdown, or explanatory sentences. Generate the image directly.'
          ),
        ])
      ];

      final response = await model.generateContent(prompt);
      debugPrint('AI Response: ${response.text}');

      Uint8List? imageBytes;
      String? responseText = response.text;

      // Base64データの抽出とデコード処理を改善
      if (responseText != null) {
        // Base64データの開始マーカーを探す
        final base64Marker = RegExp(r'iVBORw[a-zA-Z0-9+/=]*');
        final match = base64Marker.firstMatch(responseText);

        if (match != null) {
          String base64String = match.group(0)!;

          // 足りない '=' を補う
          switch (base64String.length % 4) {
            case 2:
              base64String += '==';
              break;
            case 3:
              base64String += '=';
              break;
          }

          try {
            imageBytes = base64Decode(base64String);
          } catch (e) {
            responseText = 'Base64デコードに失敗しました: $e';
          }
        } else {
          responseText = 'Base64データが見つかりませんでした。';
        }
      } else {
        responseText = 'AIの返答が空でした。';
      }

      if (imageBytes != null) {
        setState(() {
          _generatedImageBytes = imageBytes;
          _statusText = 'アートが完成しました！';
        });
      } else {
        setState(() {
          _statusText = 'エラー: AIは画像を生成しませんでした。\nAIの返答: ${responseText ?? "テキストもありませんでした。"}';
        });
      }
    } catch (e) {
      setState(() {
        _statusText = 'エラーが発生しました: ${e.toString()}';
      });
    } finally {
      setState(() {
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            // 画像表示エリア
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _generatedImageBytes != null
                      ? Image.memory(_generatedImageBytes!) // 生成された画像
                      : _selectedImageBytes != null
                          ? Image.memory(_selectedImageBytes!) // 選択された画像
                          : Icon(Icons.image, size: 100, color: Colors.grey[300]),
            ),
            const SizedBox(height: 20),
            Text(_statusText, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            // 画像選択ボタン
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('画像を選択'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      // 4. ボタンを押したらAPIを呼び出すように変更
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _generateImage, // 処理中はボタンを押せないようにする
        tooltip: 'Generate Image',
        child: const Icon(Icons.auto_awesome), // アイコンを変更
      ),
    );
  }
}