#!/usr/bin/env bash
# Narration audio for rung-4 videos. Engine order follows Karpathy's tip: ElevenLabs when a key is
# set, otherwise a free voice on local compute.
# usage: tts.sh <zh|en> "<text>" <out.m4a>    env: ELEVENLABS_API_KEY, ELEVENLABS_VOICE_ID, TTS_VOICE
set -euo pipefail
lang=$1 text=$2 out=$3
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [ -n "${ELEVENLABS_API_KEY:-}" ]; then
  body=$(python3 -c 'import json, sys; print(json.dumps({"text": sys.argv[1], "model_id": "eleven_multilingual_v2"}))' "$text")
  curl -fsS "https://api.elevenlabs.io/v1/text-to-speech/${ELEVENLABS_VOICE_ID:-21m00Tcm4TlvDq8ikWAM}" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" -H 'Content-Type: application/json' -d "$body" -o "$tmp/a.mp3"
  src="$tmp/a.mp3"
elif command -v say >/dev/null 2>&1; then  # macOS: Meijia is a Taiwan Mandarin voice
  voice=${TTS_VOICE:-$([ "$lang" = zh ] && echo Meijia || echo Samantha)}
  say -v "$voice" -o "$tmp/a.aiff" "$text"
  src="$tmp/a.aiff"
elif command -v espeak-ng >/dev/null 2>&1; then
  espeak-ng -v "$([ "$lang" = zh ] && echo cmn || echo en-us)" -w "$tmp/a.wav" "$text"
  src="$tmp/a.wav"
else
  echo "tts.sh: no TTS engine (set ELEVENLABS_API_KEY, or install espeak-ng / Kokoro)" >&2
  exit 1
fi
ffmpeg -loglevel error -y -i "$src" -c:a aac -b:a 160k "$out"
