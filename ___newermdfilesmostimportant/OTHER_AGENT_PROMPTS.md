# Other-Agent Prompts (10 additional tasks)

Use these with Claude, Gemini, or any model. Each prompt expects the agent to read the repo docs and respond in plain English.

1) Dream pipeline integration risk audit
"Review DreamRoomEngine (TempDreamStuff/DreamRoomEngine.zip). List integration risks: API key handling, request size/timeouts, failure modes, and fallback behavior. Provide mitigations without writing code."

2) Data model vs PRD gaps
"Compare Area/Bowl/CleaningTask models to PRD requirements. List missing fields or mismatches and propose minimal schema additions (no code)."

3) Verification math consistency check
"Audit scoring/verification rules in the codebase and compare to PRD multipliers and flow. Report any mismatches and consequences."

4) Streak + Kitchen Closed logic review
"Check how streak and daily target are tracked vs PRD. Highlight edge cases (time zones, multiple bowls, verification photos) and propose fixes (no code)."

5) Dream header UX guidance (no scaling header yet)
"Propose a Dream header presentation that feels premium without using a scaling header. Must stay inside the design system. Provide layout/interaction notes only."

6) Shop economy sanity pass
"Evaluate filter costs vs base points. Suggest a simple points economy curve that feels achievable without grind. Keep it aligned to PRD."

7) Accessibility + typography audit
"Scan key screens for accessibility risks (contrast, text size, hit targets). Suggest fixes that respect the design system."

8) Error state + copy audit
"Draft concise, non‑shaming copy for: 0 tasks, Dream generation failure, verification fail, kitchen closed. Keep it PRD‑aligned."

9) Asset pipeline checklist
"List the Babcia illustrations needed for Dream failure fallback by Area type. Identify missing assets and naming conventions."

10) Test plan for Dream pipeline
"Propose unit/integration test coverage for Dream pipeline wiring: normalization, persistence, filter application, header update, and gallery insertion. No code."

11) Dream pipeline UI touchpoints map
"Identify every screen that should display Dream outputs (Area header, Gallery, Home latest Dream card). Provide a wiring checklist without code."

12) Shop UX copy and states
"Write short copy for Shop states: locked, unlocked, applied, not enough points. Keep it warm and clear."

13) Persona tone polish
"Provide short tone guidance per persona (classic, baroness, warrior, wellness, coach) with 2 example lines each for prompts and task list headers."

14) Task list phrasing style guide
"Define a consistent style for task phrasing (verbs, length, tone) that avoids shame and matches PRD."

15) Dream image metadata requirements
"Propose what metadata should be stored alongside Dream output (timestamp, area id, filter id, persona, raw size). No code."

16) Verification UX flowchart
"Summarize the verification flow in a step-by-step list including the paused reveal screen, with decision points."

17) Camera permissions + privacy copy
"Draft friendly copy for camera permission prompt and in‑app privacy explanation."

18) Empty states audit
"List all empty states in Home, Areas, Gallery, Shop. Provide brief copy suggestions aligned to PRD."

19) Streak UI microcopy
"Draft microcopy for streak card and kitchen closed state that avoids punishment."

20) Dream failure fallback UX
"Describe how the fallback Babcia illustration should be presented in Area Detail and Gallery so it doesn’t feel like a failure."
