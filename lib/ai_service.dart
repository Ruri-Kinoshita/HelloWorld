import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image/image.dart' as img;

/// 送信前に少し縮小して転送量を抑える（※必要なら）
Uint8List downscaleJpeg(Uint8List input, {int maxSide = 1024, int quality = 85}) {
  final original = img.decodeImage(input);
  if (original == null) return input;
  final w = original.width, h = original.height;
  if (w <= maxSide && h <= maxSide) {
    return Uint8List.fromList(img.encodeJpg(original, quality: quality));
  }
  final scale = (w > h) ? maxSide / w : maxSide / h;
  final resized = img.copyResize(
    original,
    width: (w * scale).round(),
    height: (h * scale).round(),
  );
  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}

/// Cloud Functions (asia-northeast1) の editImageOpenAI を叩いて PNG を返す
Future<Uint8List> generatePixelIcon({
  required Uint8List jpegBytes,
  String? promptOverride,
}) async {
  final base64Input = base64Encode(jpegBytes);

  final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
      .httpsCallable('editImageOpenAI');

  final res = await callable.call(<String, dynamic>{
    'imageBase64': base64Input,
    'mimeType': 'image/jpeg',
    'size': '1024x1024',
    'background': 'transparent',
    'prompt': promptOverride ??
        "Bust-up pixel art portrait of a cute, fashionable character. From chest up, with detailed clothing faithfully matching the provided reference. Chibi/anime-inspired proportions, large expressive eyes, and a gentle smile. Drawn in authentic retro 16-bit style with visible large pixels, clean 1-pixel outlines, flat 2D cel shading, and no gradients or smooth blending. Color palette limited to soft pastel and bright vibrant colors, 20–30 colors max. Transparent background. 4:3 aspect ratio, pixel resolution ~128x96, then upscaled without smoothing. Cozy, playful mood.",
  });

  final data = (res.data as Map).cast<String, dynamic>();
  final String b64 = data['imageBase64'] as String;
  return base64Decode(b64);
}
