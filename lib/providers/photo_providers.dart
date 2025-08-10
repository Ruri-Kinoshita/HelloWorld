import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

// 撮った写真（XFile）を保持する。なければ null。
final capturedPhotoProvider = StateProvider<XFile?>((ref) => null);

/// 生成されたドット絵（PNGバイト）
final generatedIconProvider = StateProvider<Uint8List?>((ref) => null);

/// 生成中フラグ
final isGeneratingProvider = StateProvider<bool>((ref) => false);

/// ステータス文言
final genStatusProvider = StateProvider<String>((ref) => '');