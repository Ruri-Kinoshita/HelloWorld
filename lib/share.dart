// share.dart
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/constant/app_color.dart';
import 'package:helloworld/providers/profile_provider.dart';
import 'package:helloworld/providers/role_providers.dart';

class Sharepage extends ConsumerStatefulWidget {
  const Sharepage({super.key});

  @override
  ConsumerState<Sharepage> createState() => _SharepageState();
}

class _SharepageState extends ConsumerState<Sharepage> {
  // カードキャプチャ用のキー
  final GlobalKey _cardKey = GlobalKey();

  // 多重実行防止
  bool _autoStarted = false;

  // アップロード結果（UI表示＆コピー用）
  String? _lastDownloadUrl; // 直接のStorage URL（必要なら使う）
  String? _lastCustomUrl; // helloWorld://user/receive?imagename=... を表示

  @override
  void initState() {
    super.initState();
    // 初回フレーム後に自動アップロード
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _autoStarted) return;
      _autoStarted = true;
      await Future.delayed(const Duration(milliseconds: 100)); // レイアウト安定待ち
      await _captureAndUpload(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Riverpodからプロフィールデータを取得
    final profileData = ref.watch(profileProvider);

    // ロール情報 → カラー/ラベル
    final selectedRole = ref.watch(selectedRoleProvider);
    final Color accentColor =
        selectedRole?.color ?? AppColor.ui.designer; // デフォはデザイナー色
    final String roleLabel = selectedRole?.label ?? 'デザイナー';

    // ビギナーなら「なりたい職種」、それ以外は「よく使うツール」
    final bool isBeginner = selectedRole == UserRole.beginner;
    final String toolSectionTitle = isBeginner ? 'なりたい職種' : 'よく使うツール';

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // メインコンテンツ
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 40,
                          bottom: 120,
                        ),
                        // ここを画像化する
                        child: RepaintBoundary(
                          key: _cardKey,
                          child: Container(
                            width: screenWidth * 0.9,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // AIコメント
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  constraints:
                                      const BoxConstraints(minHeight: 70),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'コメント生成中...',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: AppColor.text.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // アイコン + 名前
                                Row(
                                  children: [
                                    Container(
                                      width: screenWidth * 0.24,
                                      height: screenWidth * 0.24 * (4.0 / 3.0),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'アイコン\n生成中...',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.032,
                                            color: AppColor.text.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$roleLabelの',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                          Text(
                                            profileData.name.isNotEmpty
                                                ? profileData.name
                                                : 'なまえ',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.08,
                                              fontWeight: FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // 基本情報
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profileData.university.isNotEmpty
                                          ? profileData.university
                                          : '大学名',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          profileData.department.isNotEmpty
                                              ? profileData.department
                                              : '学部名',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          profileData.grade.isNotEmpty
                                              ? profileData.grade
                                              : '学年',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.email,
                                            color: accentColor, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          profileData.email.isNotEmpty
                                              ? profileData.email
                                              : 'メールアドレス',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // よく使うツール / なりたい職種
                                _buildSection(
                                  toolSectionTitle,
                                  profileData.tools,
                                  accentColor,
                                ),
                                const SizedBox(height: 16),

                                // 生活
                                _buildSection(
                                  '生活',
                                  profileData.lifestyle,
                                  accentColor,
                                ),
                                const SizedBox(height: 16),

                                // ハッカソンに対する思い
                                _buildSection(
                                  'ハッカソンに対する思い',
                                  profileData.hackathonThought,
                                  accentColor,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 下部アクション
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.grey[100],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // カスタムURL表示 & コピー
                          Expanded(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.link,
                                      color: Colors.grey[600], size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _lastCustomUrl ?? 'アップロード後にURLをコピーします',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _lastCustomUrl != null
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_lastCustomUrl != null)
                                    IconButton(
                                      tooltip: 'URLをコピー',
                                      icon: const Icon(Icons.copy, size: 16),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: _lastCustomUrl!),
                                        );
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('URLをコピーしました')),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 手動アップロード
                          GestureDetector(
                            onTap: () async {
                              await _captureAndUpload(context);
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: accentColor,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload,
                                      color: accentColor, size: 16),
                                  const SizedBox(height: 2),
                                  Text(
                                    '保存/送信',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF333333),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              '終了する',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// カードを画像としてキャプチャし、Firebase Storage にアップロード。
  Future<void> _captureAndUpload(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // レイアウト完了を確実に待つ
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カードを取得できませんでした')),
        );
        return;
      }

      final deviceRatio = MediaQuery.of(context).devicePixelRatio;
      final ui.Image image =
          await boundary.toImage(pixelRatio: deviceRatio * 2);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // ファイル名
      final filename = 'card_${DateTime.now().millisecondsSinceEpoch}.png';
      final storageRef =
          FirebaseStorage.instance.ref().child('cards/$filename');

      // デバッグ出力（ファイル名とパス）
      debugPrint('[Storage] Start upload: $filename');
      debugPrint('[Storage] Full path: ${storageRef.fullPath}');

      // アップロード
      final task = await storageRef.putData(
        pngBytes,
        SettableMetadata(contentType: 'image/png'),
      );
      final downloadUrl = await task.ref.getDownloadURL();

      // カスタムURL作成
      final customUrl = 'helloWorld://user/receive?imagename=$filename';

      // UI更新
      if (mounted) {
        setState(() {
          _lastDownloadUrl = downloadUrl;
          _lastCustomUrl = customUrl;
        });
      }

      // クリップボードにはカスタムURLをコピー
      await Clipboard.setData(ClipboardData(text: customUrl));

      // デバッグ出力
      debugPrint('[Storage] Uploaded file name: ${task.ref.name}');
      debugPrint('[Storage] Uploaded full path: ${task.ref.fullPath}');
      debugPrint('[Storage] Download URL: $downloadUrl');
      debugPrint('[CustomURL] $customUrl');

      if (mounted) {
        Navigator.of(context).pop(); // ダイアログ閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('アップロード完了！URLをコピーしました。\n$customUrl'),
          ),
        );
      }
    } catch (e, st) {
      if (mounted) Navigator.of(context).pop();
      debugPrint('Upload error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('アップロードに失敗しました: $e')),
        );
      }
    }
  }

  Widget _buildSection(String title, List<dynamic> items, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map<Widget>((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor,
                  width: 1,
                ),
              ),
              child: Text(
                item.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
