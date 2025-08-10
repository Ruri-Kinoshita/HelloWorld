import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ReceivedImageItem {
  final String imageName;
  final String downloadUrl;
  final DateTime receivedAt;

  const ReceivedImageItem({
    required this.imageName,
    required this.downloadUrl,
    required this.receivedAt,
  });

  ReceivedImageItem copyWith({
    String? imageName,
    String? downloadUrl,
    DateTime? receivedAt,
  }) {
    return ReceivedImageItem(
      imageName: imageName ?? this.imageName,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

class ReceivedImagesNotifier extends StateNotifier<List<ReceivedImageItem>> {
  ReceivedImagesNotifier() : super(const []);

  /// 既存の imageName があれば上書き、なければ末尾追加。受信日時は常に更新。
  void upsert(String imageName, String url) {
    final now = DateTime.now();
    final idx = state.indexWhere((e) => e.imageName == imageName);
    if (idx >= 0) {
      final updated = state[idx].copyWith(
        downloadUrl: url,
        receivedAt: now,
      );
      final newList = [...state];
      newList[idx] = updated;
      // 新しい順に並べ替え（任意）
      newList.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      state = newList;
    } else {
      final item = ReceivedImageItem(
        imageName: imageName,
        downloadUrl: url,
        receivedAt: now,
      );
      final newList = [...state, item]
        ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      state = newList;
    }
  }

  void removeByName(String imageName) {
    state = state.where((e) => e.imageName != imageName).toList();
  }

  void clear() => state = const [];
}

final receivedImagesProvider =
    StateNotifierProvider<ReceivedImagesNotifier, List<ReceivedImageItem>>(
  (ref) => ReceivedImagesNotifier(),
);
