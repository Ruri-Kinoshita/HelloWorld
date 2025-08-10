// create.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helloworld/providers/photo_providers.dart';

class CreatePage extends ConsumerWidget {
  // ← ここを変更
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(capturedPhotoProvider); // XFile? が来る

    return Scaffold(
      // MaterialApp は重複になるので基本ここは Scaffold でOK
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'プロフィール作成画面',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 撮った写真のプレビュー
            if (photo != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(photo.path),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                photo.path,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else ...[
              const Text('まだ写真がありません'),
            ],

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                context.push('/share'); // 既存の遷移はそのまま
                debugPrint('ボタンが押されました');
              },
              child: const Text('押してね'),
            ),
          ],
        ),
      ),
    );
  }
}
