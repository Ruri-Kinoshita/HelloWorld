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
        "Edit the attached image into pixel-art (Everskies-like),",
        "full body, keep outfit/hairstyle/accessories/colors.",
        "Background: transparent. Output as PNG.",
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
