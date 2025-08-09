import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image/image.dart' as img;


import 'package:image_picker/image_picker.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  // Initialize the Gemini Developer API backend service
  // Create a `GenerativeModel` instance with a Gemini model that supports image output
 

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

  final ImagePicker _picker = ImagePicker();

  Uint8List downscaleJpeg(Uint8List input, {int maxSide = 1024, int quality = 85}) {
  final original = img.decodeImage(input);
  if (original == null) return input;
  final w = original.width, h = original.height;
  if (w <= maxSide && h <= maxSide) {
    return Uint8List.fromList(img.encodeJpg(original, quality: quality));
  }
  final scale = (w > h) ? maxSide / w : maxSide / h;
  final resized = img.copyResize(original, width: (w * scale).round(), height: (h * scale).round());
  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}


  // --- 2. ユーザーが画像を選択するための関数です ---
  Future<void> _pickImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final small = downscaleJpeg(bytes);
      setState(() {
        _selectedImageBytes = small;
        _statusText = '画像が選択されました！下のボタンで生成を開始します。';
        _generatedImageBytes = null; // 新しい画像を選んだら前の結果をクリア
      });
    }
  }

  Future<void> _generateImageViaFunctions() async {
  if (_selectedImageBytes == null) {
    // 画像未選択
    return;
  }

  setState(() {
    _isLoading = true;
    _statusText = 'サーバ側で画像を編集中...';
  });

  try {
    final base64Input = base64Encode(_selectedImageBytes!);

    // ★ Functionsのリージョンは "asia-northeast1" に合わせる
    final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
        .httpsCallable('editImage');

    final res = await callable.call(<String, dynamic>{
      'imageBase64': base64Input,
      'mimeType': 'image/jpeg',
      'prompt':
          "Bust-up pixel art portrait of a cute, fashionable character. From chest up, with detailed clothing faithfully matching the provided reference. Chibi/anime-inspired proportions, large expressive eyes, and a gentle smile. Drawn in authentic retro 16-bit style with visible large pixels, clean 1-pixel outlines, flat 2D cel shading, and no gradients or smooth blending. Color palette limited to soft pastel and bright vibrant colors, 20–30 colors max. High contrast between character and transparent background. 4:3 aspect ratio, pixel resolution ~128x96, then upscaled without smoothing. Cozy, playful mood.",    });

    final data = (res.data as Map).cast<String, dynamic>();
    final String b64 = data['imageBase64'] as String;
    final String mime = (data['mimeType'] as String?) ?? 'image/png';

    final outBytes = base64Decode(b64);

    setState(() {
      _generatedImageBytes = outBytes;
      _statusText = 'アートが完成しました！（$mime）';
    });
  } on FirebaseFunctionsException catch (e) {
    setState(() {
      _statusText = 'Functionsエラー: ${e.code} ${e.message ?? ""}'.trim();
    });
  } catch (e) {
    setState(() {
      _statusText = '想定外のエラー: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

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
        onPressed: _isLoading ? null : _generateImageViaFunctions, // 処理中はボタンを押せないようにする
        tooltip: 'Generate Image',
        child: const Icon(Icons.auto_awesome), // アイコンを変更
      ),
    );
  }
}