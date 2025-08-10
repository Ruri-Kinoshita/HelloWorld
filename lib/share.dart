import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/constant/app_color.dart';
import 'package:helloworld/providers/profile_provider.dart';
import 'package:helloworld/providers/role_providers.dart';

class Sharepage extends ConsumerWidget {
  const Sharepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpodからプロフィールデータを取得
    final profileData = ref.watch(profileProvider);

    // ★ ロール情報を取得してカラーと文言を設定
    final selectedRole = ref.watch(selectedRoleProvider);
    final Color accentColor =
        selectedRole?.color ?? AppColor.ui.designer; // デフォルトはデザイナー色
    final String roleLabel = selectedRole?.label ?? 'デザイナー';

    // ★ ビギナーなら「なりたい職種」、それ以外は「よく使うツール」
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
                  // メインコンテンツ（上に移動）
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 40, // 上部余白を40に増加（適度な位置に配置）
                          bottom: 120, // 下部のボタンエリア分の余白を確保
                        ),
                        child: Container(
                          width: screenWidth * 0.9,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // AIコメント部分（一番上）
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(18),
                                constraints: BoxConstraints(
                                  minHeight: 70, // 2行程度に適したサイズに調整
                                ),
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

                              SizedBox(height: 20),

                              // アイコンと名前部分（横並び）
                              Row(
                                children: [
                                  // アイコン部分
                                  Container(
                                    width: screenWidth *
                                        0.24, // 0.28から0.24に調整（適度なサイズ）
                                    height: screenWidth *
                                        0.24 *
                                        (4.0 / 3.0), // 比例して高さも調整
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'アイコン\n生成中...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize:
                                              screenWidth * 0.032, // フォントサイズも調整
                                          color: AppColor.text.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // 名前部分
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${roleLabel}の',
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth * 0.045, // 画面幅の4.5%
                                            fontWeight: FontWeight.bold,
                                            color: accentColor,
                                          ),
                                        ),
                                        Text(
                                          profileData.name.isNotEmpty
                                              ? profileData.name
                                              : 'なまえ',
                                          style: TextStyle(
                                            fontSize: screenWidth *
                                                0.08, // 画面幅の8%（さらに大きく）
                                            fontWeight: FontWeight.bold,
                                            color: accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              // 基本情報部分
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 大学名
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
                                  SizedBox(height: 4), // 8から4に短縮

                                  // 学部　学年
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
                                      SizedBox(width: 16),
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
                                  SizedBox(height: 4), // 8から4に短縮

                                  // Mail
                                  Row(
                                    children: [
                                      Icon(Icons.email,
                                          color: accentColor, size: 16),
                                      SizedBox(width: 8),
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

                              SizedBox(height: 20),

                              // よく使うツール / なりたい職種
                              _buildSection(
                                toolSectionTitle,
                                profileData.tools,
                                accentColor,
                              ),

                              SizedBox(height: 16),

                              // 生活
                              _buildSection(
                                '生活',
                                profileData.lifestyle,
                                accentColor,
                              ),

                              SizedBox(height: 16),

                              // ハッカソンに対する思い
                              _buildSection(
                                'ハッカソンに対する思い',
                                profileData.hackathonThought,
                                accentColor,
                              ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ], // Column の children を閉じる
              ), // Column を閉じる

              // 下部のアクションボタンエリア（絶対位置）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.grey[100], // 背景と同じ色
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      // 上段：URLテキストボックスと画像保存ボタン
                      Row(
                        children: [
                          // URLテキストボックス
                          Expanded(
                            child: Container(
                              height: 48, // 画像保存ボタンと同じ高さに固定
                              padding: EdgeInsets.symmetric(
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
                                  Icon(
                                    Icons.link,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'https://example.com/profile/share',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // コピー機能の実装
                                      debugPrint('URLをコピーしました');
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      color: accentColor,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // 画像保存ボタン（アイコンとテキストを内部配置）
                          GestureDetector(
                            onTap: () {
                              debugPrint('画像保存ボタンが押されました');
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              padding: EdgeInsets.symmetric(vertical: 4),
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
                                  Icon(
                                    Icons.download,
                                    color: accentColor,
                                    size: 16, // アイコンサイズを小さく
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '画像保存',
                                    style: TextStyle(
                                      fontSize: 6, // 非常に小さいフォントサイズ
                                      color: accentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // 下段：終了ボタン
                      Center(
                        child: SizedBox(
                          width: 160, // 横幅を固定値に変更
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF333333),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
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
            ], // Stack の children を閉じる
          ), // Stack を閉じる
        ), // SafeArea を閉じる
      ),
    );
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
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map<Widget>((item) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
