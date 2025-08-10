// receive_page.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helloworld/providers/received_images_provider.dart';

class ReceivePage extends ConsumerStatefulWidget {
  final String? imageName;
  const ReceivePage({super.key, this.imageName});

  @override
  ConsumerState<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends ConsumerState<ReceivePage> {
  late Future<String> _urlFuture;
  String? _imageName; // ← final外す（更新するため）

  @override
  void initState() {
    super.initState();
    _imageName = widget.imageName ?? Uri.base.queryParameters['imagename'];
    _urlFuture = _fetchDownloadUrl(_imageName);
  }

  // ★ ルートだけ差し替わって同一Widgetが再利用されたときに呼ばれる
  @override
  void didUpdateWidget(covariant ReceivePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newImageName =
        widget.imageName ?? Uri.base.queryParameters['imagename'];
    if (newImageName != _imageName) {
      _imageName = newImageName;
      // 新しい Future をセットして FutureBuilder を更新
      _urlFuture = _fetchDownloadUrl(_imageName);
      setState(() {});
    }
  }

  Future<String> _fetchDownloadUrl(String? imageName) async {
    if (imageName == null || imageName.isEmpty) {
      throw '画像名(imagename)が見つかりませんでした。';
    }
    final refFs = FirebaseStorage.instance.ref('cards/$imageName');
    debugPrint('[ReceivePage] Fetch: ${refFs.fullPath}');
    final url = await refFs.getDownloadURL();
    debugPrint('[ReceivePage] DownloadURL: $url');

    // 「もらった」タブに反映
    ref.read(receivedImagesProvider.notifier).upsert(imageName, url);
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width * 0.95;
    final maxHeight = size.height * 0.70;

    return Scaffold(
      appBar: AppBar(title: const Text('受け取り')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<String>(
            future: _urlFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snap.hasError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '画像を取得できませんでした\n${snap.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _urlFuture = _fetchDownloadUrl(_imageName);
                        });
                      },
                      child: const Text('リトライ'),
                    ),
                  ],
                );
              }

              final url = snap.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        key: ValueKey(url), // ★ URL変化で必ず再構築
                        fit: BoxFit.contain,
                        gaplessPlayback: true, // ★ 切替時のチラつき軽減（任意）
                        loadingBuilder: (c, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (_, __, ___) =>
                            const Text('画像の読み込みに失敗しました'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/'),
                    child: const Text('トップへ'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
