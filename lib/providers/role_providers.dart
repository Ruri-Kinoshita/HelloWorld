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
