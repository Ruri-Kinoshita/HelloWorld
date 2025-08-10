import 'package:flutter_riverpod/flutter_riverpod.dart';

// プロフィールデータモデル
class ProfileData {
  final String name;
  final String university;
  final String department;
  final String email;
  final String grade;
  final List<String> tools;
  final List<String> lifestyle;
  final List<String> hackathonThought;

  ProfileData({
    required this.name,
    required this.university,
    required this.department,
    required this.email,
    required this.grade,
    required this.tools,
    required this.lifestyle,
    required this.hackathonThought,
  });

  // 空のプロフィールデータを作成
  ProfileData.empty()
      : name = '',
        university = '',
        department = '',
        email = '',
        grade = '',
        tools = [],
        lifestyle = [],
        hackathonThought = [];

  // コピーメソッド
  ProfileData copyWith({
    String? name,
    String? university,
    String? department,
    String? email,
    String? grade,
    List<String>? tools,
    List<String>? lifestyle,
    List<String>? hackathonThought,
  }) {
    return ProfileData(
      name: name ?? this.name,
      university: university ?? this.university,
      department: department ?? this.department,
      email: email ?? this.email,
      grade: grade ?? this.grade,
      tools: tools ?? this.tools,
      lifestyle: lifestyle ?? this.lifestyle,
      hackathonThought: hackathonThought ?? this.hackathonThought,
    );
  }

  // Mapに変換
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'university': university,
      'department': department,
      'email': email,
      'grade': grade,
      'tools': tools,
      'lifestyle': lifestyle,
      'hackathonThought': hackathonThought,
    };
  }
}

// プロフィール状態管理クラス
class ProfileNotifier extends StateNotifier<ProfileData> {
  ProfileNotifier() : super(ProfileData.empty());

  // プロフィール全体を更新
  void updateProfile(ProfileData profile) {
    state = profile;
  }

  // 名前を更新
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  // 大学を更新
  void updateUniversity(String university) {
    state = state.copyWith(university: university);
  }

  // 学部を更新
  void updateDepartment(String department) {
    state = state.copyWith(department: department);
  }

  // メールを更新
  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  // 学年を更新
  void updateGrade(String grade) {
    state = state.copyWith(grade: grade);
  }

  // ツールを更新
  void updateTools(List<String> tools) {
    state = state.copyWith(tools: tools);
  }

  // ライフスタイルを更新
  void updateLifestyle(List<String> lifestyle) {
    state = state.copyWith(lifestyle: lifestyle);
  }

  // ハッカソンへの思いを更新
  void updateHackathonThought(List<String> hackathonThought) {
    state = state.copyWith(hackathonThought: hackathonThought);
  }

  // プロフィールをリセット
  void reset() {
    state = ProfileData.empty();
  }
}

// グローバルプロバイダー
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileData>((ref) {
  return ProfileNotifier();
});
