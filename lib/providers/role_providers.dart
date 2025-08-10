import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helloworld/constant/app_color.dart';

enum UserRole { engineer, designer, pm, beginner }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.engineer => 'エンジニア',
        UserRole.designer => 'デザイナー',
        UserRole.pm => 'PM',
        UserRole.beginner => 'ビギナー（初心者）',
      };

  Color get color => switch (this) {
        UserRole.engineer => AppColor.ui.engineer,
        UserRole.designer => AppColor.ui.designer,
        UserRole.pm => AppColor.ui.pm,
        UserRole.beginner => AppColor.ui.beginner,
      };
}

// 最初は未選択(null)。直接Createを開いたときのフォールバックもCreate側で用意します。
final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

final toolOptionsProvider = Provider<List<String>>((ref) {
  final role = ref.watch(selectedRoleProvider);
  switch (role) {
    case UserRole.engineer:
      return ['Python', 'Flutter', 'Java', 'React', 'Unity'];
    case UserRole.designer:
      return [
        'Figma',
        'Adobe XD',
        'Canva',
        'Miro',
        'Photoshop',
        'Illustrator',
        'Sketch',
        'InVision',
      ];
    case UserRole.pm:
      return ['Miro', 'Notion', 'Slack', 'Discord', 'Zoom'];
    case UserRole.beginner:
      return ['プログラミング', 'デザイナー', 'PM'];
    case null:
      // 直接Createを開いた等のフォールバック（デザイナーを既定に）
      return [
        'Figma',
        'Adobe XD',
        'Canva',
        'Miro',
        'Photoshop',
        'Illustrator',
        'Sketch',
        'InVision',
      ];
  }
});
