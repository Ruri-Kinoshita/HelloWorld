// create.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/ai_service.dart';
import 'package:helloworld/constant/app_color.dart';
import 'package:helloworld/constant/app_size.dart';

import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:helloworld/providers/photo_providers.dart';

class CreatePage extends ConsumerStatefulWidget {
  const CreatePage({super.key});

  @override
  ConsumerState<CreatePage> createState() => _CreatepageState();
}

class _CreatepageState extends ConsumerState<CreatePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGrade;
  Set<String> _selectedTools = {}; // 複数選択用に変更
  Set<String> _selectedLifestyle = {}; // 複数選択用に変更
  Set<String> _selectedHackathonThought = {}; // 複数選択用に変更
  bool _showToolSelector = false; // ツール選択画面の表示状態
  bool _showLifestyleSelector = false; // 生活選択画面の表示状態
  bool _showHackathonSelector = false; // ハッカソン選択画面の表示状態
  bool _requestedGenerate = false;
  bool _startedGen = false;

  @override
  void initState() {
    super.initState();
    // テキストフィールドの変更を監視
    _nameController.addListener(() => setState(() {}));
    _universityController.addListener(() => setState(() {}));
    _departmentController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _kickoffGenerationOnce();
    });
  }

  void _kickoffGenerationOnce() {
    if (_startedGen) return;
    _startedGen = true;

    // まだ生成されていなければスタート
    final generated = ref.read(generatedIconProvider);
    final isGen = ref.read(isGeneratingProvider);
    final captured = ref.read(capturedPhotoProvider);

    if (generated == null && !isGen && captured != null) {
      _generateIcon();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 全ての項目が入力されているかチェック
  bool _isAllFieldsCompleted(Uint8List? generated) {
    return _nameController.text.isNotEmpty &&
        _universityController.text.isNotEmpty &&
        _departmentController.text.isNotEmpty &&
        _selectedGrade != null &&
        _emailController.text.isNotEmpty &&
        _selectedTools.isNotEmpty &&
        _selectedLifestyle.isNotEmpty &&
        _selectedHackathonThought.isNotEmpty &&
        generated != null;
  }

  Future<void> _generateIcon() async {
    debugPrint('アイコン生成リクエスト');
    if (ref.read(isGeneratingProvider)) return;
    final captured = ref.watch(capturedPhotoProvider);
    if (captured != null) {
      captured.length().then((len) {
        debugPrint('撮影ファイル: ${captured.path} / ${len} bytes');
      });
    }
    if (captured == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先に写真を撮影してください')),
      );
      return;
    }
    try {
      ref.read(isGeneratingProvider.notifier).state = true;
      ref.read(genStatusProvider.notifier).state = '画像を生成中...';

      final bytes = await captured.readAsBytes();
      final small = downscaleJpeg(bytes); // 転送量削減（元の実装のまま）
      final png = await generatePixelIcon(jpegBytes: small); // Functions呼び出し

      ref.read(generatedIconProvider.notifier).state = png;
      ref.read(genStatusProvider.notifier).state = '生成完了！';
    } catch (e) {
      ref.read(genStatusProvider.notifier).state = '生成に失敗しました: $e';
    } finally {
      ref.read(isGeneratingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // 画面サイズに応じたレスポンシブサイズ
    final containerHeight = screenHeight * 0.06; // より小さく調整
    final iconWidth = screenWidth * 0.24; // アイコンの幅を少し大きく
    final iconHeight = iconWidth * (4.0 / 3.0); // 縦4：横3の比率
    final paddingSize = screenWidth * 0.08; // 画面幅に応じたパディング

    final generated = ref.watch(generatedIconProvider);
    final isGen = ref.watch(isGeneratingProvider);
    final genStatus = ref.watch(genStatusProvider);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColor.ui.background, // グレー背景
        body: SafeArea(
          child: Stack(
            children: [
              // メインコンテンツ
              Column(
                children: [
                  // 上部エリア（グレー背景）
                  Container(
                    color: AppColor.ui.background,
                    padding: EdgeInsets.symmetric(
                        horizontal: paddingSize, vertical: paddingSize * 0.5),
                    // padding: EdgeInsets.all(paddingSize),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 上部のボタンエリア
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _isAllFieldsCompleted(generated)
                                  ? () {
                                      _handleSubmit();
                                      context.push('/share');
                                    }
                                  : null, // 全ての項目が完了していない場合は無効
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isAllFieldsCompleted(generated)
                                        ? Color(0xFF333333) // 完了時は#333333
                                        : AppColor.text.gray, // 未完了時はグレー
                                foregroundColor: AppColor.text.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: paddingSize,
                                  vertical: paddingSize * 0.08,
                                ),
                              ),
                              child: Text(
                                '入力完了',
                                style: TextStyle(
                                  fontSize:
                                      screenWidth * 0.035, // 画面幅に応じたフォントサイズ
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01), // より小さく調整

                        // タイトルテキスト
                        Text(
                          '以下の項目を埋めてください。',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: AppColor.text.primary,
                          ),
                        ),
                        SizedBox(
                            height: screenHeight * 0.005), // タイトル間のスペーシングを縮小
                        Text(
                          'アイコンとコメントは完成後に生成されます。',
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: AppColor.text.primary,
                          ),
                        ),
                        // SizedBox(height: screenHeight * 0.0004), // 余白を小さく調整
                      ],
                    ),
                  ),

                  // 下部エリア（白背景）- スクロール可能
                  Expanded(
                    child: Container(
                      color: AppColor.ui.background, // グレー背景
                      padding: EdgeInsets.fromLTRB(
                          paddingSize * 0.5, // 左右に余白
                          paddingSize * 0.008, // 上余白を小さく（白い部分を上に伸ばす）
                          paddingSize * 0.5,
                          paddingSize * 0.2), // 下余白を小さく（白い部分を下に伸ばす）
                      child: Container(
                        color: AppColor.brand.primary, // 白背景
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: paddingSize,
                            right: paddingSize,
                            top: paddingSize * 0.6, // 上部パディングを少し大きく（中身を調整）
                            bottom: paddingSize * 1.2, // 下部パディングを大きく（中身を調整）
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // コメント生成中エリア
                              Container(
                                width: double.infinity,
                                height: containerHeight,
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                      UiSize.minimumGridCircular),
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
                              SizedBox(height: screenHeight * 0.015), // より小さく調整

                              // アイコンとプロフィール入力エリア
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center, // 中央揃えに変更
                                children: [
                                  // アイコン生成中エリア
                                  Container(
                                    width: iconWidth,
                                    height: iconHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                          UiSize.minimumGridCircular),
                                      border: Border.all(
                                          color:
                                              Colors.purple.withOpacity(0.15)),
                                    ),
                                    child: Center(
                                      child: generated == null
                                          ? (isGen
                                              ? Text('生成中...',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.030,
                                                      color: AppColor
                                                          .text.primary))
                                              : Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: generated == null
                                                          ? Center(
                                                              child: Text(
                                                              isGen
                                                                  ? '生成中...'
                                                                  : '未生成',
                                                            ))
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          UiSize
                                                                              .minimumGridCircular),
                                                              child: Image.memory(
                                                                  generated,
                                                                  fit: BoxFit
                                                                      .contain),
                                                            ),
                                                    ),
                                                    if (isGen)
                                                      const Positioned.fill(
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                      ),
                                                  ],
                                                ))
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(UiSize
                                                      .minimumGridCircular),
                                              child: Image.memory(
                                                generated,
                                                fit: BoxFit.contain,
                                                gaplessPlayback: true,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: paddingSize * 0.8), // 間隔を少し狭く

                                  // プロフィール入力エリア
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center, // 垂直方向中央揃え
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'デザイナーの',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.040,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7638FA),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        TextField(
                                          controller: _nameController,
                                          textAlign:
                                              TextAlign.center, // 中央揃えを追加
                                          inputFormatters: [
                                            // ひらがなのみを許可する正規表現パターン
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[あ-ん゛゜ー]'),
                                            ),
                                          ],
                                          style: TextStyle(
                                            color:
                                                Color(0xFF7638FA), // 入力テキストを紫色に
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.bold, // 入力テキストを太字に
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'ひらがななまえ',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: paddingSize,
                                              vertical:
                                                  screenHeight * 0.008, // 縦幅を調整
                                            ),
                                            fillColor: AppColor.ui.white,
                                            filled: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.012),

                              // 大学名入力
                              _buildTextField(
                                controller: _universityController,
                                hintText: '大学名入力',
                              ),
                              SizedBox(height: screenHeight * 0.005),

                              // 学部名と学年
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1, // 学部名と学年を同じ比率に変更
                                    child: _buildTextField(
                                      controller: _departmentController,
                                      hintText: '学部名入力',
                                    ),
                                  ),
                                  SizedBox(width: paddingSize),
                                  Expanded(
                                    flex: 1, // 学部名と学年を同じ比率に変更
                                    child: _buildDropdown(
                                      value: _selectedGrade,
                                      hintText: '学年',
                                      items: [
                                        'B1',
                                        'B2',
                                        'B3',
                                        'B4',
                                        'M1',
                                        'M2',
                                        'その他'
                                      ],
                                      onChanged: (value) => setState(
                                          () => _selectedGrade = value),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.005),

                              // メールアドレス
                              Row(
                                children: [
                                  Text(
                                    'Mail：',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.text.primary,
                                    ),
                                  ),
                                  SizedBox(width: paddingSize * 0.3),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _emailController,
                                      hintText: 'メールアドレス入力',
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02), // 少し削減

                              // よく使うツール
                              _buildSectionTitleWithEdit(
                                'よく使うツール',
                                () => setState(() => _showToolSelector = true),
                                _selectedTools.isNotEmpty,
                              ),
                              _buildToolButton(),
                              SizedBox(height: screenHeight * 0.010), // 少し削減

                              // 生活
                              _buildSectionTitleWithEdit(
                                '生活',
                                () => setState(
                                    () => _showLifestyleSelector = true),
                                _selectedLifestyle.isNotEmpty,
                              ),
                              _buildLifestyleButton(),
                              SizedBox(height: screenHeight * 0.010), // 少し削減

                              // ハッカソンに対する思い
                              _buildSectionTitleWithEdit(
                                'ハッカソンに対する思い',
                                () => setState(
                                    () => _showHackathonSelector = true),
                                _selectedHackathonThought.isNotEmpty,
                              ),
                              _buildHackathonButton(),
                              SizedBox(
                                  height: screenHeight * 0.006), // 最後の余白を半分に削減
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // オーバーレイ
              if (_showToolSelector) _buildToolSelectorOverlay(),
              if (_showLifestyleSelector) _buildLifestyleSelectorOverlay(),
              if (_showHackathonSelector) _buildHackathonSelectorOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithEdit(
      String title, VoidCallback onEdit, bool hasSelection) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: screenSize.height * 0.004),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenSize.width * 0.035,
              fontWeight: FontWeight.bold,
              color: AppColor.text.primary,
            ),
          ),
          if (hasSelection) ...[
            SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.edit,
                  size: 14,
                  color: Color(0xFF7638FA), // 編集アイコンを紫に
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final paddingSize = screenSize.width * 0.03; // 水平パディングも小さく

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center, // テキストを中央揃えに
      style: TextStyle(
        color: Color(0xFF7638FA), // 入力テキストを紫色に
        fontSize: 14,
        fontWeight: FontWeight.bold, // 入力テキストを太字に
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          textBaseline: TextBaseline.alphabetic,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingSize,
          vertical: screenSize.height * 0.008, // 縦幅を調整
        ),
        fillColor: AppColor.ui.white,
        filled: true,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hintText,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final paddingSize = screenSize.width * 0.03; // 水平パディングも小さく

    return DropdownButtonFormField<String>(
      value: value,
      isDense: true, // より密なレイアウト
      alignment: Alignment.center, // ドロップダウン全体を中央揃えに
      dropdownColor: Colors.white, // プルダウンメニューの背景色を白に設定
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          textBaseline: TextBaseline.alphabetic,
          color: AppColor.text.primary, // ヒントテキストの色を紫に
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingSize * 0.8, // パディングをさらに小さく
          vertical: screenSize.height * 0.008, // 縦幅を調整
        ),
        fillColor: AppColor.ui.white,
        filled: true,
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.grey[600],
      ),
      iconSize: 24,
      selectedItemBuilder: (BuildContext context) {
        // 選択されたアイテムを中央揃えで表示
        return items.map<Widget>((String item) {
          return Center(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7638FA), // 選択済みテキストを紫色に
                fontWeight: FontWeight.bold, // 選択済みテキストを太字に
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList();
      },
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Center(
            // ドロップダウン項目を中央揃えに
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14), // フォントサイズを少し小さく
              textAlign: TextAlign.center, // テキストを中央揃えに
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _handleSubmit() {
    final name = _nameController.text;
    final university = _universityController.text;
    final department = _departmentController.text;
    final grade = _selectedGrade;
    final email = _emailController.text;
    final tools = _selectedTools.toList();
    final lifestyle = _selectedLifestyle.toList();
    final hackathonThought = _selectedHackathonThought.toList();

    debugPrint('名前: $name');
    debugPrint('大学名: $university');
    debugPrint('学部名: $department');
    debugPrint('学年: $grade');
    debugPrint('メールアドレス: $email');
    debugPrint('よく使うツール: $tools');
    debugPrint('生活: $lifestyle');
    debugPrint('ハッカソンに対する思い: $hackathonThought');
  }

  Widget _buildToolButton() {
    if (_selectedTools.isEmpty) {
      // 未選択の場合は「選ぶ」ボタンを表示
      return Container(
        width: double.infinity,
        height: 35, // 高さを40から35に変更
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _showToolSelector = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // 角をもっと丸く
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Text(
            '選ぶ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    } else {
      // 選択済みの場合はカード形式で表示
      return Column(
        children: [
          // カード形式の選択済みツール表示
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTools.map((tool) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white, // 背景を白に
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF7638FA), // 枠線を紫に
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tool,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7638FA), // テキストを紫に
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTools.remove(tool);
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF7638FA), // アイコンを紫に
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildLifestyleButton() {
    if (_selectedLifestyle.isEmpty) {
      // 未選択の場合は「選ぶ」ボタンを表示
      return Container(
        width: double.infinity,
        height: 35, // 高さを40から35に変更
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _showLifestyleSelector = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // 角をもっと丸く
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Text(
            '選ぶ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    } else {
      // 選択済みの場合はカード形式で表示
      return Column(
        children: [
          // カード形式の選択済み生活表示
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedLifestyle.map((lifestyle) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white, // 背景を白に
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF7638FA), // 枠線を紫に
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lifestyle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7638FA), // テキストを紫に
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLifestyle.remove(lifestyle);
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF7638FA), // アイコンを紫に
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildHackathonButton() {
    if (_selectedHackathonThought.isEmpty) {
      // 未選択の場合は「選ぶ」ボタンを表示
      return Container(
        width: double.infinity,
        height: 35, // 高さを40から35に変更
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _showHackathonSelector = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[700],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // 角をもっと丸く
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Text(
            '選ぶ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    } else {
      // 選択済みの場合はカード形式で表示
      return Column(
        children: [
          // カード形式の選択済みハッカソン思い表示
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedHackathonThought.map((thought) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white, // 背景を白に
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFF7638FA), // 枠線を紫に
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        thought,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7638FA), // テキストを紫に
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedHackathonThought.remove(thought);
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF7638FA), // アイコンを紫に
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
  }

  Widget _buildToolSelectorOverlay() {
    final availableTools = [
      'Figma',
      'Adobe XD',
      'Canva',
      'Miro',
      'Photoshop',
      'Illustrator',
      'Sketch',
      'InVision',
      'その他'
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ヘッダー
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'よく使うツール',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showToolSelector = false;
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 選択数の表示
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '最大3つ選んでください',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${_selectedTools.length}/3',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedTools.length >= 3
                          ? Colors.red
                          : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // チップ選択エリア
            Padding(
              padding: EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTools.map((tool) {
                  final isSelected = _selectedTools.contains(tool);
                  return FilterChip(
                    label: Text(
                      tool,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Color(0xFF7638FA),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Color(0xFF7638FA),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white, // 背景を白に
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 角をもっと丸く
                      side: BorderSide(
                        color: Color(0xFF7638FA), // 枠線を紫に
                        width: 1,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedTools.length < 3) {
                            _selectedTools.add(tool);
                          }
                        } else {
                          _selectedTools.remove(tool);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // 完了ボタン
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showToolSelector = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7638FA),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 角をもっと丸く
                    ),
                  ),
                  child: Text(
                    '完了',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleSelectorOverlay() {
    final lifestyleOptions = [
      '朝型',
      '夜型',
      '割と暇',
      '寝坊しがち',
      '朝バイトある',
      '昼バイトある',
      '夜バイトある'
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ヘッダー
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '生活',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showLifestyleSelector = false;
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 選択数の表示
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '最大3つ選んでください',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${_selectedLifestyle.length}/3',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedLifestyle.length >= 3
                          ? Colors.red
                          : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // チップ選択エリア
            Padding(
              padding: EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: lifestyleOptions.map((option) {
                  final isSelected = _selectedLifestyle.contains(option);
                  return FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Color(0xFF7638FA),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Color(0xFF7638FA),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white, // 背景を白に
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 角をもっと丸く
                      side: BorderSide(
                        color: Color(0xFF7638FA), // 枠線を紫に
                        width: 1,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedLifestyle.length < 3) {
                            _selectedLifestyle.add(option);
                          }
                        } else {
                          _selectedLifestyle.remove(option);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // 完了ボタン
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showLifestyleSelector = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7638FA),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 角をもっと丸く
                    ),
                  ),
                  child: Text(
                    '完了',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHackathonSelectorOverlay() {
    final hackathonOptions = [
      '熱意ありあり',
      'やる気はある',
      '実装まかせて',
      'デザイン任せて',
      '寝ても覚めても開発！',
      'つよつよになりたい',
      '楽しみたい',
      'エナドリが友達',
      '寝不足上等'
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ヘッダー
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ハッカソンに対する思い',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showHackathonSelector = false;
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 選択数の表示
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '最大3つ選んでください',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${_selectedHackathonThought.length}/3',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedHackathonThought.length >= 3
                          ? Colors.red
                          : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // チップ選択エリア
            Padding(
              padding: EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: hackathonOptions.map((option) {
                  final isSelected = _selectedHackathonThought.contains(option);
                  return FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Color(0xFF7638FA),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Color(0xFF7638FA),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white, // 背景を白に
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 角をもっと丸く
                      side: BorderSide(
                        color: Color(0xFF7638FA), // 枠線を紫に
                        width: 1,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedHackathonThought.length < 3) {
                            _selectedHackathonThought.add(option);
                          }
                        } else {
                          _selectedHackathonThought.remove(option);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // 完了ボタン
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showHackathonSelector = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7638FA),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 角をもっと丸く
                    ),
                  ),
                  child: Text(
                    '完了',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
