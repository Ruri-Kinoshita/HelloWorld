"use strict";
/* eslint-disable max-len */
/* eslint-disable require-jsdoc */
Object.defineProperty(exports, "__esModule", { value: true });
exports.editImage = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
// 動的 import 用のユーティリティ（CJSでもOK）
let _genai = null;
async function getGenAI() {
    if (!_genai)
        _genai = import("@google/genai");
    return _genai;
}
const GEMINI_API_KEY = (0, params_1.defineSecret)("GEMINI_API_KEY");
function pickImageInlineData(parts) {
    var _a;
    for (const p of parts) {
        const d = p.inlineData;
        if (d && d.data)
            return { data: d.data, mimeType: (_a = d.mimeType) !== null && _a !== void 0 ? _a : "image/png" };
    }
    return null;
}
exports.editImage = (0, https_1.onCall)({
    region: "asia-northeast1",
    secrets: [GEMINI_API_KEY],
    memory: "2GiB",
    timeoutSeconds: 540,
}, async (request) => {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    try {
        const input = ((_a = request.data) !== null && _a !== void 0 ? _a : {});
        if (!input.imageBase64 || typeof input.imageBase64 !== "string") {
            throw new https_1.HttpsError("invalid-argument", "imageBase64 (base64 string) is required.");
        }
        const { GoogleGenAI, Modality } = await getGenAI();
        const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY.value() });
        const userPrompt = (_b = input.prompt) !== null && _b !== void 0 ? _b : [
            "Edit the attached image into pixel-art (Everskies-like),",
            "full body, keep outfit/hairstyle/accessories/colors.",
            "Background: transparent. Output as PNG.",
        ].join(" ");
        const response = await ai.models.generateContent({
            model: "gemini-2.0-flash-preview-image-generation",
            contents: [{
                    role: "user",
                    parts: [
                        { inlineData: { mimeType: (_c = input.mimeType) !== null && _c !== void 0 ? _c : "image/jpeg", data: input.imageBase64 } },
                        { text: userPrompt },
                    ],
                }],
            config: { responseModalities: [Modality.TEXT, Modality.IMAGE] },
        });
        const parts = (_g = (_f = (_e = (_d = response.candidates) === null || _d === void 0 ? void 0 : _d[0]) === null || _e === void 0 ? void 0 : _e.content) === null || _f === void 0 ? void 0 : _f.parts) !== null && _g !== void 0 ? _g : [];
        const image = pickImageInlineData(parts);
        if (!image) {
            const textFallback = parts.map((p) => p.text).filter(Boolean).join("\n");
            console.error("[editImage] No image in response. Text:", textFallback);
            throw new https_1.HttpsError("failed-precondition", `No image in response. ${textFallback || ""}`.trim());
        }
        return { imageBase64: image.data, mimeType: image.mimeType };
    }
    catch (e) {
        console.error("[editImage] Error:", e);
        if (e instanceof https_1.HttpsError)
            throw e;
        const msg = (_h = e === null || e === void 0 ? void 0 : e.message) !== null && _h !== void 0 ? _h : String(e);
        throw new https_1.HttpsError("internal", msg);
    }
});
//# sourceMappingURL=index.js.map