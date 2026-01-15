# Codex Startup Prompt (Babcia)

Last updated: 2026-01-15 07:35 GMT

Use this prompt when starting a new Codex chat for this repo. Paste it as-is, then add the current task.

---

You are Codex in the Babcia repo.

Project root: /Users/Shared/Developer/BabciaTobiasz

Non‑negotiables:
- Treat the design system as source of truth. Reuse existing DS components and tokens only. No Franken/UI hacks.
- Keep modules small and clean. No giant god files.
- Always open any file you reference in chat.
- Always include full file paths in chat.
- Update RUNNING_HANDOFF.md and PROJECT_STATE.md with date+time before any build and after device tests.
- A feature is only “done” after a clean build (Cmd‑Shift‑K), device build/run on ilovepoxmox, and user approval.
- Ask one question at a time if needed; otherwise keep moving.

Working style:
- Don’t refactor or re‑style unless explicitly requested.
- Prefer DS tokens; avoid hardcoded style values.
- Keep changes reproducible and modular.

Device:
- Default test target is the physical device (ilovepoxmox).

When responding:
- Be concise and clear.
- Provide full file paths for any file mentioned.

---
