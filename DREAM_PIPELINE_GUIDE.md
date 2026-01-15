# Dream Pipeline Guide (Dev System)

Purpose
- Keep the Dream pipeline consistent, editable, and non-Frankenstein.
- Make prompt edits safe and fast without touching code.

Quick start
1) Set the DreamRoom API key
   - App Settings -> Dream Engine -> paste key -> Save
   - Stored in Keychain (local only)
   - Optional fallback: add DREAMROOM_API_KEY to Secrets.plist for local dev

2) Edit Dream prompts (single source of truth)
   - File: BabciaTobiasz/Resources/LocalDreamPrompts.json
   - This file is gitignored and local-only

Prompt edit rules (do not break these)
- Keep all required persona keys: classic, baroness, warrior, wellness, coach
- Each prompt must be a single-line string
- Leave a prompt blank to intentionally disable Dream generation for that persona
- Avoid quotes or special characters that need escaping

Fallback art (what it is)
- If Dream generation cannot run (missing API key, missing prompt, or API failure),
  the app shows a persona reference image instead of a Dream output.
- This prevents raw scan photos from ever being used as the Dream header.

Fallback asset mapping
- classic: R1_Classic_Reference_NormalizedFull
- baroness: R2_Baroness_Reference_NormalizedFull
- warrior: R3_Warrior_Reference_NormalizedFull
- wellness: R4_Wellness_Reference_NormalizedFull
- coach: R5_ToughLifecoach_Reference_NormalizedFull

Data flow (system overview)
- Scan photo -> DreamRoomEngine -> optional filter -> store on AreaBowl
- Area header reads latest Dream output from the bowl
- Filters apply to Dream outputs, not after photos

Do not change without explicit reason
- DreamRoomEngine output size (hero image 1200x1600)
- Dream pipeline is UI-free
- Prompts are not hardcoded in code
