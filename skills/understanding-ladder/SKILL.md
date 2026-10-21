---
name: understanding-ladder
description: Pick the output format that makes an explanation easiest to understand, following Karpathy's understanding ladder — (1) plain controlled text, (2) diagram, (3) interactive HTML page, (4) 3Blue1Brown-style explainer video. Classify the content (definition/steps, process/causality, parameter→outcome, unfolding derivation), then climb: produce the highest rung the content can use and the environment can deliver, rendering real videos when the toolchain is present. Works in English and Chinese. Use when the user says "explain this clearly", "help me understand", "draw a diagram", "make it interactive", "make an explainer video", "what's the best way to explain X", "understanding ladder", "Karpathy ladder", or 「講清楚」「幫我理解」「畫個圖」「做個互動頁」「做個講解影片」「用哪種方式講最好懂」「理解階梯」; also when explaining a non-trivial concept, mechanism, algorithm, or an AI agent's output.
---

# Understanding ladder

This skill decides **which format** to explain in. Writing quality inside every format is handled by level 1 rules (below).

Source: Andrej Karpathy, 2026-10-02 <https://x.com/karpathy/status/2105819303471976479>. LLM output is nearly free; human understanding is the bottleneck. So ask for formats that are easier to understand. He ranked four, each "even better" than the last — and each more expensive.

**Language:** reply in the user's language. These instructions are in English; the output is not.

## The four rungs

| Rung | Format | Why it is easier | Cost |
|---|---|---|---|
| 1 | Plain controlled text | One idea per sentence, one meaning per term; read once, no misreading | lowest |
| 2 | Diagram | Text is linear; a diagram lays the structure out at once | low |
| 3 | Interactive HTML page | The reader moves a parameter and sees the result change | medium |
| 4 | Explainer video (3b1b style) | Animation shows the process while narration explains it | high |

## Step 1: classify the content, pick a rung

| Content type | Signals | Rung |
|---|---|---|
| Definition, fact, comparison, procedure | "what is X", "how do I install", "A vs B" | 1 |
| Process, causal chain, hierarchy, state changes, component relations | "how does X work", "how does data flow", "who calls whom" | 2 |
| A parameter changes an outcome; trade-offs; distributions | "what happens if utilization rises", "how does learning rate affect convergence" | 3 |
| A derivation or geometric intuition that unfolds over time | "why do sine waves add up to a square wave", "how does gradient descent move on a surface" | 4 |

Rules:

1. **If the user names a format, use it.** "Draw a diagram" means rung 2.
2. **Climb when the goal is understanding.** This applies when the user wants to understand something: "explain", "help me understand", what an agent or a piece of code did. Ordinary answers and coding replies stay short and in text. Karpathy ranks each rung as "even better" than the one before and asks for large, custom, discardable artifacts that would never have made sense to build before: "push the boundaries here". The table above gives the *minimum* rung. Produce the highest rung the content can use and the environment can deliver (rung 3 needs a place to open HTML; rung 4 needs the toolchain in references/level-4-video.md). Stay at rung 1 only for a direct lookup: a value, a flag, a yes/no.
3. **Mixed content: pick by the core difficulty.** If the hard part is "how a parameter changes the result", pick rung 3 even if there is a definition inside.
4. **Then offer the next rung up.** End with one line, e.g. "Want this as a narrated rung-4 video?"

Open with one line that states the choice, then produce it. Do not ask "which rung do you want?" unless the user asked for a recommendation:

> Rung 3 (interactive page): the core question is how utilization changes latency — dragging a slider shows this faster than text.

## Step 2: produce the rung

**Every rung starts from a rung-1 draft.** Write the plain text first, then turn it into a diagram, page, or video. The draft is what you check for correctness before spending effort on richer formats.

### Rung 1: plain controlled text

Pick the rules by output language:

- **English** → this is Karpathy's own tip: explain "in ASD-STE100", softened to "about 80% of the way". Use the `simplified-technical-english` skill (real STE: rules, approved word list, checker) in its normal, not strict, strength when it is installed; otherwise follow the rules below.
- **Chinese** → if the `ste` skill (ste-zh) is active in this session (the user typed `/ste`), its rules win. Otherwise use the `plain-chinese` skill (as a plugin it may be named `understanding-ladder:plain-chinese`). Chinese has no "ASD-STE100" to invoke, so that skill spells the rules out.
- **English fallback rules** ("about 80% of the way to ASD-STE100"):
  - One idea per sentence. Aim for ≤20 words in instructions, ≤25 in descriptions.
  - One term per meaning. Define a term the first time; never rotate synonyms.
  - Active voice; name who does what. Simple tenses.
  - Steps as a numbered list, imperative verb first.
  - Conditions before actions ("If X, do Y").
  - No filler ("It's worth noting", "Great question", "In summary…").
  - **Nothing cut.** Keep every fact, number, condition, and hedge ("usually", "may"). Simple language, not less content — the rewrite may be longer.
  - Do not touch code, commands, paths, quoted errors, or proper names.
- **Other languages** → apply the English rules in that language.

### Rung 2: diagram

See [references/level-2-diagram.md](references/level-2-diagram.md). In short:

- Choose the diagram type first: flowchart, sequence, state, hierarchy, causal graph, comparison table.
- If the environment has a diagram or chart tool (an artifact or diagramming skill, a dataviz skill), build the diagram with it. Otherwise default to Mermaid (renders in most chat UIs and on GitHub). Use a single-file SVG/HTML when layout matters.
- ≤8 words (or ≤8 Chinese characters) per box. Below the diagram, 2–4 sentences on how to read it.

### Rung 3: interactive HTML page

See [references/level-3-html.md](references/level-3-html.md). In short:

- One self-contained HTML file. No build step; double-click to open.
- One job: let the reader move the **1–3 parameters that matter** and see the result update live.
- Layout: one-line takeaway → interactive area → rung-1 text → "try this" prompts → limits and what to check.
- If the environment can publish or preview pages (an artifact tool), use it. Otherwise save it in the working directory, tell the user the path, open it if the environment allows.

### Rung 4: explainer video

See [references/level-4-video.md](references/level-4-video.md). Karpathy is most bullish on this rung ("this is actually starting to work!"), so **render the video** when the toolchain is present: Manim for animation, `scripts/tts.sh` for narration (ElevenLabs when `ELEVENLABS_API_KEY` is set, otherwise a free local voice), ffmpeg to mux. Deliver the `.mp4` path and open it. Only when a tool is missing, fall back to:

- A storyboard: per shot — visual, narration (rung-1 rules), duration.
- Tool links, e.g. [showtime](https://github.com/FavioVazquez/showtime) (open source, early; v0.4.0+ reads the storyboard table directly), [Manim](https://www.manim.community/), local TTS [Kokoro](https://github.com/thewh1teagle/kokoro-onnx).
- A ready-to-paste prompt for those tools. With showtime ≥ 0.4.0, the storyboard table goes in as-is: `showtime new <template> <dir> --from-storyboard storyboard.md`.

## Demo mode: same content, every rung

When the user says "show all rungs", "walk this from rung 1 to 4", 「逐級演示」:

1. Rung 0: the usual default prose, as a baseline.
2. Rung 1: plain text.
3. Rung 2: diagram.
4. Rung 3: interactive page (can hold rungs 0–2 as tabs in the same HTML file).
5. Rung 4: rendered video (storyboard only if the toolchain is missing).

This is the best way to feel how much the format itself changes understanding.

## Always append "What to check"

End every output with 1–3 things the reader should verify: key numbers, formulas, assumptions, anything that disagrees with a source.

Why: the ladder lowers the cost of **understanding**, not the cost of **verification**. The clearer and prettier the artifact, the more it lowers the reader's guard. An error in an animation is more convincing than the same error in text.

## Do not

- Add a rung that repeats the same text in a new wrapper. Each rung must make the content easier to see: structure laid out, a parameter to move, a process animated.
- Add facts in the diagram, page, or video that are not in the rung-1 draft. New facts go into the draft first.
- Invent data to make a page look real. Label sample data as sample data.
