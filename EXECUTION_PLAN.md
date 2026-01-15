# Execution Plan (Non-binding Implementation Guidance)

Deprecated: This plan now lives in `PRD.md` (Section 21). Keep this file only as a reference snapshot.

This plan supports PRD.md. It does not change product requirements.
Design system usage is mandatory. No Frankenstein fixes.

## Milestone 1 - Dream pipeline as reusable module (required)

Interfaces
- DreamRoomEngine (core, UI-free) from TempDreamStuff/DreamRoomEngine.zip
  - Input: beforePhotoData + DreamRoomContext (characterPrompt) + DreamRoomConfig (apiKey, endpoint, timeout)
  - Output: DreamRoomResult (heroImageData 1200x1600, rawImageData, metadata)
- DreamOutputStore (app boundary)
  - Save and load Dream output by Area and Session
  - Provide latest Dream image for Area header
  - Provide list for Gallery
- FilterApplier (app boundary)
  - Apply FilterPreset to Dream output (not after photos)
- DreamPipelineCoordinator (app service boundary)
  - Orchestrates scan -> DreamRoomEngine -> filter -> persistence -> header update

Wiring points
- Camera/Scan flow calls DreamPipelineCoordinator on scan completion
- Area Detail header reads latest Dream output from DreamOutputStore
- Gallery reads Dream outputs grouped by Area/date
- Shop/Filters selection provides FilterPreset to DreamPipelineCoordinator

Acceptance criteria
- Every scan yields a hero image at 1200x1600 and retains raw output
- Area header updates to the new Dream output
- Gallery shows the stored Dream outputs
- Filters visibly change Dream outputs
- DreamRoomEngine remains UI-free and unchanged unless explicitly tasked
- If Dream generation fails, use Babcia illustration fallback, never the raw scan

## Milestone 2 - Session and bounded task generation

Interfaces
- Session model ties scan, Dream output, tasks (0 to 5), and base points
- TaskGenerator returns up to 5 tasks, no backlog

Wiring points
- Scan creates a Session and task list for Area Detail
- Task completion updates points immediately

Acceptance criteria
- No more than 5 tasks per session
- If 0 tasks, prompt rescan and do not create an empty session

## Milestone 3 - Verification flow and scoring

Interfaces
- VerificationState with off/blue/golden and paused reveal state
- Scoring service applies fixed multipliers

Wiring points
- Pre-scan verification toggle
- Post-completion prompt and paused reveal screen
- After-photo capture for verification
- Scoring updates pot totals

Acceptance criteria
- Blue totals: pass 4x base, fail 2.5x base
- Golden totals: pass 10x base, fail 5.5x base
- Strict and final, no retries, no detailed reasons

## Milestone 4 - Home hub and Gallery UX

Interfaces
- Home dashboard data: pot, streak, daily target, shop link, stats link, latest Dream preview
- Gallery index grouped by Area/date, Dream images are primary artifact

Wiring points
- Replace Weather tab usage with Home hub cards
- Gallery shows Dream outputs as trophies

Acceptance criteria
- Home communicates scan -> Dream -> points -> filters -> Gallery
- Gallery is Dream-first and grouped by Area/date

## Milestone 5 - Burnout protection and streak rules

Interfaces
- Daily target settings (default 1)
- Streak counter (first scan per day only)

Wiring points
- Kitchen Closed state blocks additional scans after target
- Streak increments only on first scan of the day

Acceptance criteria
- Kitchen Closed UI is visible and gentle
- Streak ignores verification photos and task ticks

## Out of scope (V1 non-goals)
- Persona switching logic
- Streaming cameras / Home Assistant monitoring
- Ingredient inventory beyond visual theming
