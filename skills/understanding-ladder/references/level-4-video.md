# Rung 4: explainer video (3Blue1Brown style)

## When

The core of the content is a **process that unfolds over time**: a step-by-step derivation, one shape turning into another, a point moving across a surface, an agent's run step by step. A page lets the reader explore; a video walks them along a planned path with narration.

Karpathy is most bullish on this rung: "Create a 3b1b style video explainer on X. Use my ElevenLabs API key for audio narration … or ask your LLM to find you decent free alternatives that use your local compute. This is actually starting to work!" So when the content suits it and the toolchain is present, **render the video**; do not stop at a plan.

## Toolchain

| Need | Tool | Check |
|---|---|---|
| Animation | [Manim Community](https://www.manim.community/) | `manim --version` (install: `uv tool install manim --python 3.12`; macOS first needs `brew install pkgconf pango cairo`; the llm-skills-manager menu item "video toolchain" does all of it on macOS and Windows) |
| Narration | `scripts/tts.sh <zh\|en> "<text>" <out.m4a>` in this skill | ElevenLabs first: key in `ELEVENLABS_API_KEY` or `~/.config/elevenlabs/.env` (`ELEVENLABS_VOICE_ID`, `ELEVENLABS_MODEL` optional; defaults: model `eleven_v4`, Chinese Anna Su — Taiwan Mandarin, the library's most-used Chinese voice — falling back to premade Sarah on the free plan, which cannot use library voices via the API; English George). If it is unset or fails (free quota used up, network, bad key), the script falls back to a local voice: macOS `say` (Meijia for Taiwan Mandarin, Samantha for English), Windows SAPI via Git Bash (Hanhan zh-TW, Zira en-US), else `espeak-ng`; override the voice with `TTS_VOICE`. [Kokoro](https://github.com/hexgrad/kokoro) is a better free local voice if installed |
| Mux | [ffmpeg](https://ffmpeg.org/) | `ffmpeg -version` |
| Chinese text in Manim | a CJK font | `Text(..., font="PingFang TC")` on macOS; `Noto Sans CJK TC` on Linux |

If a tool is missing, tell the user the one install command, and deliver the storyboard (Step 2) plus the fallback at the end.

## Step 1: draft first

Write the full rung-1 draft and have it checked. An error in a video is more convincing than the same error in text, so review happens before rendering.

## Step 2: storyboard

A table, one row per shot:

| Shot | Visual | Narration |
|---|---|---|
| 1 | Title card + a bowl-shaped curve | Gradient descent looks for the lowest point of the loss function. |
| 2 | A ball on the slope, an arrow up the steepest slope | The gradient points up the steepest slope, so step the other way. |
| 3 | The ball steps down to the bottom | Repeat the step, and the ball rolls to the bottom of the bowl. |

Rules:

1. One shot, one idea. Narration follows rung-1 rules (English ≤25 words per sentence; Chinese ≤25 characters).
2. The visual appears before or with the narration, never after it.
3. Open with a title card that says what is coming; close with a recap.
4. Plan 60–120 seconds (~150 English words or ~200 Chinese characters per minute).
5. When a formula appears, color its symbols to match the objects on screen.

## Step 3: render

Work in a fresh directory. The narration sets the timing, so record it first.

1. **Narration per shot**: `tts.sh zh "<shot N narration>" shotN.m4a` for every shot.
2. **Durations**: read each length with `ffprobe -v error -show_entries format=duration -of csv=p=0 shotN.m4a` and save the list as `durations.json`.
3. **Scene**: write `scene.py` with one `Scene` class. For shot N, play its animations and pad with `self.wait(...)` so the shot lasts exactly `durations[N]` seconds.
4. **Render**: `manim -qm --disable_caching -o video.mp4 scene.py <SceneClass>` (`-ql` for a quick draft, `-qh` for the final).
5. **Mux**: list the shots in `list.txt` (`file 'shot1.m4a'` per line), then
   `ffmpeg -f concat -safe 0 -i list.txt -c copy narration.m4a` and
   `ffmpeg -i media/videos/scene/<quality>/video.mp4 -i narration.m4a -c:v copy -c:a aac -shortest explainer.mp4`.
6. **Verify**: `ffprobe explainer.mp4` shows one video and one audio stream and the expected length; grab one frame (`ffmpeg -ss <t> -i explainer.mp4 -frames:v 1 frame.png`) and look at it to confirm the text renders (no tofu boxes for Chinese).

## Step 4: deliver

1. The `explainer.mp4` path; open it if the environment allows. The video is a discardable artifact: re-render rather than patch.
2. The storyboard, so the user can ask for changes shot by shot.
3. "What to check": which visuals are illustrative rather than real data; formulas and numbers to verify.

## Fallback: toolchain missing

Turn the storyboard into a rung-3 HTML page, one card per shot, with a "next" button that plays a CSS/SVG animation and shows the narration as captions. Add the install command for the missing tool so the next run can render the real video. [showtime](https://github.com/FavioVazquez/showtime) (v0.4.0+) can also take the storyboard table directly: `showtime new <template> <dir> --from-storyboard storyboard.md`.
