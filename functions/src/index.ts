/* eslint-disable max-len */
/* eslint-disable require-jsdoc */

import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

// 動的 import 用のユーティリティ（CJSでもOK）
let _genai: Promise<any> | null = null;
async function getGenAI() {
  if (!_genai) _genai = import("@google/genai");
  return _genai;
}

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

type InlineData = {data?: string; mimeType?: string};
type Part = {inlineData?: InlineData; text?: string};
type InlineImage = {data: string; mimeType: string};

function pickImageInlineData(parts: Part[]): InlineImage | null {
  for (const p of parts) {
    const d = p.inlineData;
    if (d && d.data) return {data: d.data, mimeType: d.mimeType ?? "image/png"};
  }
  return null;
}

export const editImage = onCall(
  {
    region: "asia-northeast1",
    secrets: [GEMINI_API_KEY],
    memory: "2GiB",
    timeoutSeconds: 540,
  },
  async (request) => {
    try {
      const input = (request.data ?? {}) as {
        imageBase64?: string; prompt?: string; mimeType?: string;
      };
      if (!input.imageBase64 || typeof input.imageBase64 !== "string") {
        throw new HttpsError("invalid-argument", "imageBase64 (base64 string) is required.");
      }

      const {GoogleGenAI, Modality} = await getGenAI();
      const ai = new GoogleGenAI({apiKey: GEMINI_API_KEY.value()});

      const userPrompt = input.prompt ?? [
        "Bust-up pixel art portrait of a cute, fashionable character. From chest up, with detailed clothing faithfully matching the provided reference. Chibi/anime-inspired proportions, large expressive eyes, and a gentle smile. Drawn in authentic retro 16-bit style with visible large pixels, clean 1-pixel outlines, flat 2D cel shading, and no gradients or smooth blending. Color palette limited to soft pastel and bright vibrant colors, 20–30 colors max. High contrast between character and transparent background. 4:3 aspect ratio, pixel resolution ~128x96, then upscaled without smoothing. Cozy, playful mood.",
        // "Pixel art bust-up portrait of a cute, fashionable character — detailed clothing from chest up, soft pastel and bright vibrant colors, chibi/anime-inspired proportions, clean 1px outlines, flat 2D cell shading, minimal anti-aliasing, high contrast between character and background, transparent background, cozy and playful mood, 4:3 aspect ratio",
        // "avoid full body",
        // "顔だけの画像を出して下さい",
        // "Everskiesのピクセルアートスタイルを勉強して、添付された写真の人物を、ゲームキャラクター風の胸上のドット絵イラストにしてください。服装、髪型、アクセサリー、顔の表情を忠実に再現し写っているものの特徴や色を真似してください。背景は透明でお願いね。可愛らしく、洗練された仕上がりを期待しています。",
        // "全身ではなく胸上のドット絵イラストを生成してください。",
        // "3;4の比率で画像を生成して下さい",
        // "イラストは画像中央に配置して下さい",
        // // "Convert the attached image into a chest-up pixel art portrait in the style of Everskies game characters. Keep the person's unique facial features, hairstyle, accessories, and clothing exactly as in the image. Preserve accurate colors and proportions. Ensure the character is cute and polished, but still clearly recognizable as the person in the photo. Background: transparent. Output as PNG.",
        // "Edit the attached image into pixel-art (Everskies-like),",
        // "full body, keep outfit/hairstyle/accessories/colors.",
        // "Background: transparent. Output as PNG.",
      ].join(" ");

      const response = await ai.models.generateContent({
        model: "gemini-2.0-flash-preview-image-generation",
        contents: [{
          role: "user",
          parts: [
            {inlineData: {mimeType: input.mimeType ?? "image/jpeg", data: input.imageBase64}},
            {text: userPrompt},
          ],
        }],
        config: {responseModalities: [Modality.TEXT, Modality.IMAGE]},
      });

      const parts: Part[] = (response.candidates?.[0]?.content?.parts as Part[]) ?? [];
      const image = pickImageInlineData(parts);
      if (!image) {
        const textFallback = parts.map((p)=>p.text).filter(Boolean).join("\n");
        console.error("[editImage] No image in response. Text:", textFallback);
        throw new HttpsError("failed-precondition", `No image in response. ${textFallback || ""}`.trim());
      }

      return {imageBase64: image.data, mimeType: image.mimeType};
    } catch (e) {
      console.error("[editImage] Error:", e);
      if (e instanceof HttpsError) throw e;
      const msg = (e as Error)?.message ?? String(e);
      throw new HttpsError("internal", msg);
    }
  }
);
