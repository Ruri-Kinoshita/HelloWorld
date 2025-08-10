import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/constant/app_color.dart';
import 'package:helloworld/providers/role_providers.dart';

class SelectRolePage extends ConsumerWidget {
  const SelectRolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面幅から左右余白を計算
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    final ButtonStyle baseButtonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 53),
      backgroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
    );

    void choose(UserRole role) {
      ref.read(selectedRoleProvider.notifier).state = role;
      // ロール選択後に入力画面へ
      context.push('/create');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.0),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '当てはまるものを選んでください',
              style: TextStyle(color: Color(0xFF333333), fontSize: 13),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => choose(UserRole.engineer),
              style: baseButtonStyle,
              child: Text(
                'エンジニア',
                style: TextStyle(color: AppColor.ui.engineer, fontSize: 18),
              ),
            ),
            const SizedBox(height: 7),
            ElevatedButton(
              onPressed: () => choose(UserRole.designer),
              style: baseButtonStyle,
              child: Text(
                'デザイナー',
                style: TextStyle(color: AppColor.ui.designer, fontSize: 18),
              ),
            ),
            const SizedBox(height: 7),
            ElevatedButton(
              onPressed: () => choose(UserRole.pm),
              style: baseButtonStyle,
              child: Text(
                'PM',
                style: TextStyle(color: AppColor.ui.pm, fontSize: 18),
              ),
            ),
            const SizedBox(height: 7),
            ElevatedButton(
              onPressed: () => choose(UserRole.beginner),
              style: baseButtonStyle,
              child: Text(
                'ビギナー（初心者）',
                style: TextStyle(color: AppColor.ui.beginner, fontSize: 18),
              ),
            ),
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}
