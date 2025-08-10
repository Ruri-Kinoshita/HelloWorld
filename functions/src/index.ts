/* eslint-disable max-len */
/* eslint-disable require-jsdoc */
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";

// Node 22 なら fetch / FormData / Blob が標準で使えます
if (!admin.apps.length) admin.initializeApp();

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const editImageOpenAI = onCall(
  {
    region: "asia-northeast1",
    secrets: [OPENAI_API_KEY],
    memory: "2GiB",
    timeoutSeconds: 540,
  },
  async (request) => {
    try {
      const data = (request.data ?? {}) as {
        // 元写真（必須）
        imageBase64?: string;
        // 例: "image/jpeg"
        mimeType?: string;
        // 上書きしたい場合
        prompt?: string;
        // "1024x1024" など（任意）
        size?: string;
        background?: "transparent" | "white";
      };

      if (!data.imageBase64) {
        throw new HttpsError("invalid-argument", "imageBase64 is required.");
      }

      const prompt =
        data.prompt ??
        [
          "Convert the input photo into a chest-up Everskies-like pixel art portrait.",
          "Keep facial features, hairstyle, accessories, clothing, and colors exactly as in the photo.",
          "Composition: chest-up, centered, facing forward.",
          "Authentic 8/16-bit look, visible large pixels, 1px clean outlines, flat cel shading, no gradients.",
          "Background: transparent.",
        ].join(" ");

      // 画像ファイル化（multipart用）
      const bytes = Buffer.from(data.imageBase64, "base64");
      const blob = new Blob([bytes], {type: data.mimeType ?? "image/jpeg"});

      const form = new FormData();
      form.append("model", "gpt-image-1");
      form.append("prompt", prompt);
      form.append("image", blob, "input.jpg");
      // 透明背景を要求（gpt-image-1 は edits で background 指定可）
      form.append("background", data.background ?? "transparent");
      // 出力サイズ（必要なら）
      if (data.size) form.append("size", data.size); // 例 "1024x1024"

      const resp = await fetch("https://api.openai.com/v1/images/edits", {
        method: "POST",
        headers: {Authorization: `Bearer ${OPENAI_API_KEY.value()}`},
        body: form,
      });

      if (!resp.ok) {
        const t = await resp.text();
        throw new HttpsError(
          "failed-precondition",
          `OpenAI error: ${resp.status} ${resp.statusText} ${t}`
        );
      }

      const json = (await resp.json()) as {
        data:Array<{b64_json:string}>;
      };

      const b64 = json?.data?.[0]?.b64_json;
      if (!b64) {
        throw new HttpsError("failed-precondition", "No image returned from OpenAI.");
      }

      // 透明はPNG想定
      return {imageBase64: b64, mimeType: "image/png"};
    } catch (e) {
      console.error("[editImageOpenAI] Error:", e);
      if (e instanceof HttpsError) throw e;
      throw new HttpsError("internal", (e as Error)?.message ?? String(e));
    }
  }
);
