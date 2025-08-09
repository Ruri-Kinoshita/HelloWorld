import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/constant/app_color.dart';
import 'package:helloworld/constant/app_size.dart';

class Createpage extends StatefulWidget {
  const Createpage({super.key});

  @override
  State<Createpage> createState() => _CreatepageState();
}

class _CreatepageState extends State<Createpage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGrade;
  String? _selectedTool;
  String? _selectedLifestyle;
  String? _selectedHackathonThought;

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // 画面サイズに応じたレスポンシブサイズ
    final containerHeight = screenHeight * 0.06; // より小さく調整
    final iconSize = screenWidth * 0.2; // より小さく調整
    final paddingSize = screenWidth * 0.04; // 画面幅に応じたパディング

    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColor.ui.background, // グレー背景
        body: SafeArea(
          child: Column(
            children: [
              // 上部エリア（グレー背景）
              Container(
                color: AppColor.ui.background,
                padding: EdgeInsets.all(paddingSize),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 上部のボタンエリア
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _handleSubmit();
                            context.push('/share');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.text.gray,
                            foregroundColor: AppColor.text.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: paddingSize,
                              vertical: paddingSize * 0.5,
                            ),
                          ),
                          child: Text(
                            '入力完了',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035, // 画面幅に応じたフォントサイズ
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
                    SizedBox(height: screenHeight * 0.005), // タイトル間のスペーシングを縮小
                    Text(
                      'アイコンとコメントは完成後に生成されます。',
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: AppColor.text.gray,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005), // より小さく調整
                  ],
                ),
              ),

              // 下部エリア（白背景）- スクロール可能
              Expanded(
                child: Container(
                  color: AppColor.brand.primary,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(paddingSize),
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
                                color: AppColor.text.gray,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015), // より小さく調整

                        // アイコンとプロフィール入力エリア
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // アイコン生成中エリア
                            Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    UiSize.minimumGridCircular),
                              ),
                              child: Center(
                                child: Text(
                                  'アイコン\n生成中...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.028,
                                    color: AppColor.text.gray,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: paddingSize),

                            // プロフィール入力エリア
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'デザイナーの',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7638FA),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.008),
                                  TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText: 'ひらがななまえ',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: paddingSize,
                                        vertical: screenHeight * 0.012,
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
                        SizedBox(height: screenHeight * 0.02),

                        // 大学名入力
                        _buildTextField(
                          controller: _universityController,
                          hintText: '大学名入力',
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        // 学部名と学年
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _departmentController,
                                hintText: '学部名入力',
                              ),
                            ),
                            SizedBox(width: paddingSize),
                            Expanded(
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
                                onChanged: (value) =>
                                    setState(() => _selectedGrade = value),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),

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
                        SizedBox(height: screenHeight * 0.025),

                        // よく使うツール
                        _buildSectionTitle('よく使うツール'),
                        _buildDropdown(
                          value: _selectedTool,
                          hintText: '選ぶ',
                          items: [
                            'Figma',
                            'Adobe XD',
                            'Sketch',
                            'InVision',
                            'その他'
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedTool = value),
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        // 生活
                        _buildSectionTitle('生活'),
                        _buildDropdown(
                          value: _selectedLifestyle,
                          hintText: '選ぶ',
                          items: ['一人暮らし', '実家暮らし', 'シェアハウス', 'その他'],
                          onChanged: (value) =>
                              setState(() => _selectedLifestyle = value),
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        // ハッカソンに対する思い
                        _buildSectionTitle('ハッカソンに対する思い'),
                        _buildDropdown(
                          value: _selectedHackathonThought,
                          hintText: '選ぶ',
                          items: [
                            '積極的に参加したい',
                            '機会があれば参加したい',
                            'あまり興味がない',
                            'わからない'
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedHackathonThought = value),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(bottom: screenSize.height * 0.008),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenSize.width * 0.035,
          fontWeight: FontWeight.bold,
          color: AppColor.text.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final paddingSize = screenSize.width * 0.04;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingSize,
          vertical: screenSize.height * 0.012,
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
    final paddingSize = screenSize.width * 0.04;

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingSize,
          vertical: screenSize.height * 0.012,
        ),
        fillColor: AppColor.ui.white,
        filled: true,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
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
    final tool = _selectedTool;
    final lifestyle = _selectedLifestyle;
    final hackathonThought = _selectedHackathonThought;

    debugPrint('名前: $name');
    debugPrint('大学名: $university');
    debugPrint('学部名: $department');
    debugPrint('学年: $grade');
    debugPrint('メールアドレス: $email');
    debugPrint('よく使うツール: $tool');
    debugPrint('生活: $lifestyle');
    debugPrint('ハッカソンに対する思い: $hackathonThought');
  }
}
