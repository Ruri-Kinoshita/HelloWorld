import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/constant/app_color.dart';

class photoPage extends StatefulWidget {
  const photoPage({Key? key}) : super(key: key);

  @override
  State<photoPage> createState() => _photoPage();
}

class _photoPage extends State<photoPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // 内カメラ（フロント）を探す
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first, // 見つからなければ最初のカメラ
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      // 撮影後の処理
      debugPrint('保存先: ${image.path}'); //TODO:あとでリバーポッド導入
      if (mounted) {
        context.push('/role'); // GoRouterで遷移
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.brand.primary,
      body: _isCameraInitialized
          ? Stack(
              children: [
                Align(
                  alignment: Alignment(0, -0.2), // yを-1.0に近づけるほど上に寄る
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 350,
                      height: 467,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),

                // 上部テキスト
                Positioned(
                  top: 100,
                  left: 20,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "アイコンを生成するため写真を撮ります",
                        style: TextStyle(
                          color: AppColor.text.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        "丸枠に顔を収めてください",
                        style: TextStyle(
                          color: AppColor.text.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment(0, -0.3), // -1.0に近いほど上
                  child: Container(
                    width: 180,
                    height: 234,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 6,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(200, 300),
                      ),
                    ),
                  ),
                ),

                // 撮影ボタン
                Positioned(
                  bottom: 55,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        padding: const EdgeInsets.all(4), // グレー枠の太さ
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300, // 外側リングの色
                        ),
                        child: Container(
                          width: 70, // 内側ボタンのサイズ
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white, // 内側ボタンの色
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
