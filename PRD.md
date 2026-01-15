# PRODUCT REQUIREMENTS DOCUMENT: BABCIA

Version: 1.0 (V1 Shipping Spec)
Product name: BABCIA
Target: UK 16+ (ADHD / Executive Dysfunction)
Tagline: Reverse Tamagotchi cleaning game — the app “feeds” you resources when you clean.

## 0) One-paragraph summary (the real hook)

BABCIA is a gamified cleaning companion designed for executive dysfunction. Users create Areas (real spaces like “Desk”, “Kitchen counter”), then start a short cleaning session by taking a photo scan. The system generates (1) a Dream Image for that Area (the motivational “wow” header) and (2) up to 5 AI tasks for a bounded cleaning session. Users tick tasks off to gain points immediately into a Pot. When all tasks are completed, the app celebrates with a “pierogis fall into the bowl” moment (the “bowl” is primarily the completion/reward beat). Optional strict Verification (no retries, no failure reasons) uses an after-photo to award large bonus points (Blue or Golden) using fixed multipliers. Points unlock Filters in the Sklep (Shop); filters stylise the Dream Image generated from scans. The filtered Dream Image becomes the full-bleed header for that Area Detail page and is saved into the Gallery as a core artifact of progress.

## 0.1) Current build notes (dev)

- 2026-01-14 21:13 GMT: Area Detail scan is camera-only, shows scan preview + Dream status feedback, and surfaces scan/Dream errors via alerts.
- 2026-01-14 22:02 GMT: Area Detail now shows only the Dream header + sparkly Babcia card + floating camera button; bowl UI and extra cards removed.
- 2026-01-14 22:28 GMT: Floating camera button now uses existing DS button style (no custom component). Dream error popup shows the raw engine error text for debugging.
- 2026-01-14 22:29 GMT: Babcia card head icon scaled up to DS iconXL for comfortable fit.
- 2026-01-14 22:39 GMT: Floating camera button now directly reuses the existing DS CTA button label style (matches “Add Your First Area”).
- 2026-01-14 23:05 GMT: Added BabciaScanPipeline module (Dream + Gemini tasks) and wired Area scans to use it with LocalDreamPrompts.json as the prompt source.
- 2026-01-14 23:24 GMT: Area Detail now shows a task list card (Weather forecast layout) with five slots; tasks are tickable with haptic feedback.
- 2026-01-14 23:26 GMT: Fixed task list icon styling to use ShapeStyle correctly (build fix).
- 2026-01-14 23:28 GMT: Device build succeeded; install/launch failed due to CoreDeviceService not locating the device (identifier mismatch).
- 2026-01-14 23:56 GMT: Dream prompts now support editable base + geometry + output sections via LocalDreamPrompts.json; pipeline passes a full prompt override to DreamRoomEngine. Prompt loader now searches bundle overrides and optional Documents override.
- 2026-01-15 00:31 GMT: Added a temporary Buttons Lab page accessible from Settings to preview button styles.
- 2026-01-15 00:34 GMT: Fixed Buttons Lab system glass button to disambiguate SwiftUI.GlassButtonStyle (build fix).
- 2026-01-15 00:36 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10758). Awaiting user verification of Buttons Lab and button styles.
- 2026-01-15 00:38 GMT: Buttons Lab now includes five card style samples for comparison.
- 2026-01-15 00:40 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10835). Awaiting user verification of card samples.
- 2026-01-15 00:46 GMT: Buttons Lab expanded into a Liquid Glass Lab showcasing glass variants, shapes, containers, morphing, unions, transitions, background effects, and glass button styles.
- 2026-01-15 00:47 GMT: Fixed Liquid Glass Lab build error by adding iOS 26 availability to Glass helpers.
- 2026-01-15 00:50 GMT: Fixed Liquid Glass Lab build errors by removing unsupported glassBackgroundEffect and replacing containerConcentric with DS radius; added iOS 26 guards for glass sheet buttons.
- 2026-01-15 00:52 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10873). Awaiting user verification of Liquid Glass Lab.
- 2026-01-15 00:59 GMT: Liquid Glass Lab updated with clear-glass cards, clearer button-on-card sections, and a more translucent sheet.
- 2026-01-15 01:02 GMT: Clean build + device build succeeded; app installed and launched on device (PID 10896). Awaiting user verification of translucency changes.

## 1) Product principles (non-negotiables)

### 1.1 Reverse Tamagotchi principle

The app should feel like it feeds the user, not the other way around. Cleaning produces immediate rewards: points, approval, and the Dream header transformation.

### 1.2 Bounded sessions (anti-overwhelm)

A session never shows more than 5 tasks. No backlog. No “infinite list of shame”.

### 1.3 Progress over perfection

Language and interaction must avoid punishment. Missing a day does not cause scolding. Verification is strict, but failure is handled gently.

### 1.4 Dream Image is the backbone

The Dream Image is not decoration. It explains why the app exists:

- It is the “wow” motivational loop.
- It is what filters are for.
- It is what the gallery is for.
- It is why points matter (points buy better Dream transformations).

If the Dream pipeline is degraded, the entire product’s emotional payoff collapses.

## 2) Goals and non-goals

### 2.1 Goals (V1)

- Make starting cleaning fast: Area → Scan → Tasks.
- Keep sessions bounded: ≤5 tasks.
- Provide immediate reward: points per task tick and a Dream header transformation.
- Make verification feel earned and valuable: strict, final verdict, no retries.
- Keep economy simple: one currency (points), straightforward shop unlocks.
- Keep UI coherent: everything uses the design system (no Frankenstein UI).

### 2.2 Non-goals (V1)

- No backlog/queue of tasks from a scan.
- No random loot drops.
- No dynamic persona switching or adaptive coaching logic.
- No streaming camera / Home Assistant / monitoring.
- No separate ingredient inventory (ingredients may be purely visual theme).

## 3) Key terms (use consistently)

### 3.1 Area

A user-defined place: “Desk”, “Bedroom corner”, “Kitchen counter”.

### 3.2 Scan (Before photo)

The act of taking a photo to start a session. This is the streak trigger (first scan of the day).

### 3.3 Dream Image (Dream Vision output)

An AI-generated, stylised image created from the scan. This image is the Area’s header after filtering is applied.

### 3.4 Filter

A stylisation preset applied to the Dream Image (not primarily to after photos). Filters are unlocked in the Shop via points. A chosen filter becomes part of the area’s “look”.

### 3.5 Task

A discrete cleaning action suggested by AI. Up to 5.

### 3.6 Session

One cleaning run created from one scan photo. A session generates: Dream Image + Tasks. (Internal model names may use Bowl; UX should not over-emphasize “bowl” except in the completion moment.)

### 3.7 Bowl moment

The celebration moment that happens when all tasks are completed: pierogis fall into the bowl. This is the emotional “completion” beat.

### 3.8 Verification

Optional strict after-photo check. No retries. No detailed failure reasons.

### 3.9 Pot

The user’s points balance (single currency).

### 3.10 Gallery

A collection of saved Dream Images (filtered) and potentially related artifacts per Area/session. (Exact contents defined below.)

## 4) Personas (tone-only)

### 4.1 Persona menu (“Emotional Menu”)

- Classic Babcia — warm, lovingly judgmental: “My dear… come, we tidy.”
- The Baroness — aristocratic perfectionist: “This is beneath us.”
- Warrior Babcia — hype/enemy mode: “DEFEAT THE CLUTTER.”
- Wellness-X — calm companion: “Restore harmony.”
- Tough Life Coach — blunt: “Do it anyway.”

### 4.2 Persona rules

- Global default persona is set in Settings.
- Each Area has a pinned persona chosen when Area is created (cannot be changed in V1 unless you later decide otherwise).
- Persona affects tone only:
  - task count: unchanged
  - scoring multipliers: unchanged
  - golden eligibility rules: unchanged
  - verification strictness: unchanged

## 5) Navigation and information architecture (tabs)

V1 shipping tabs (your structure):

1. Home (dashboard cards)
2. Areas (areas overview stack)
3. Camera (scan entry point)
4. Gallery
5. Settings

Important: No Weather tab in shipping product. Weather screen may remain in codebase as a design system reference, but it is not part of product navigation.

## 6) Home tab (dashboard hub)

Home is the “control room” / overview. It is not a list of areas.

### 6.1 Home layout concept (card-driven)

Home contains a small set of high-value cards. At minimum (as you stated):

- A card that goes to Sklep (Shop / buy filters)
- A card that goes to Stats Progress overview

Plus recommended core cards (consistent with your points/streak system):

- Pot card (current points)
- Daily progress card (daily target progress + Kitchen Closed state)
- Streak card (counts first scan only)
- Optional “Latest Dream” card preview (links to Gallery or last Area)

### 6.2 Home must communicate (no confusion)

Home must make these truths obvious:

- “Scan creates Dream header + tasks”
- “Points unlock filters”
- “Filters change your Area’s Dream header”
- “Gallery is where your Dream images live”

### 6.3 Stats Progress overview

The stats dashboard shows personal data only (no global leaderboard for V1). Displays:
- Total Pierogis earned (lifetime)
- Current Streak
- Trends and history
- Golden vs Blue verification counts

## 7) Areas tab (overview stack)

### 7.1 Areas displayed as stacked cards

Wallet-like stack presentation. Tap → Area Detail.

### 7.2 Areas empty state

“Empty Pot” (no areas yet). Copy should be encouraging.

### 7.3 Area creation

Create Area requires:

- name
- (mandatory) pinned filter for the Area’s Dream style (tied to the chosen Babcia)

## 8) Area Detail (Room page) — the Dream header page (core screen)

This is where the “hook” must be unmistakable.

### 8.1 Full-bleed Dream header

- Uses the current Area’s Dream Image (filtered) as a full-bleed hero/header.
- The header should support a “pull down / grow” feel (if implemented).
- As you scroll, header visually collapses (details below in UI/interaction requirements).

### 8.2 What appears on Area Detail

Must show:

- Area name
- pinned persona indicator
- primary action: Scan / Take Photo
- verification toggle before scan (for next session only)
- tasks list for current session (up to 5)
- progress + points earned
- after completion: bowl moment + next action prompt

### 8.3 Dream header update rule (critical)

When user starts a session by scanning:

1. Capture scan image.
2. Generate Dream Image.
3. Apply active filter selection (if any).
4. Save filtered Dream Image as the Area’s current header.
5. Persist linkage: Dream Image is tied to the Area and the session that generated it.

This prevents drift. Shop, gallery, points all depend on this.

## 9) Camera tab (scan entry point)

Camera exists because “start cleaning” must be instant.

### 9.1 Entry flow options (TBD)

Two valid patterns, but which you ship is a product choice:

- Camera-first: scan immediately → then assign to Area (or create new Area)
- Area-first: pick Area → scan

You have not specified which. Do not invent.

### 9.2 What Camera must do in V1

- Capture a scan image
- Attach it to an Area (before or after capture depending on flow)
- Trigger Dream Image generation
- Trigger Task generation (up to 5)
- Record that this was a “scan action” for streak logic (first scan of day only)

## 10) Task engine (AI) rules

### 10.1 Input

- Scan photo
- Area context (name, maybe prior tasks history — optional)
- Safety constraints (no risky tasks)

### 10.2 Output rules

- Up to 5 tasks.
- Fewer allowed (no padding).
- If 0 tasks: prompt user to retake scan.

### 10.3 When >5 tasks are visible in the photo

Select best 5:

- quick wins
- visible impact
- safe / low-risk
- low friction

### 10.4 No backlog rule

Extra tasks are discarded. No hidden queue.

## 11) Points, Pot, and scoring (fixed math)

### 11.1 Base points

Each task tick immediately awards base points into the pot. Default: 1 point per task (tunable later). Let base = sum(task_points) for that session.

### 11.2 Completion moment (“bowl”)

When all tasks are ticked:

- play celebration (pierogis fall in)
- then show completion prompt:
  - “Are you full?” ends session
  - “One more bowl?” requires new scan (new session)

Important: bowl is mainly shown here. It is not a permanent “bowl management UI”.

## 12) Verification flow (optional, strict, paused)

### 12.1 Verification toggle timing (must be before starting)

Verification is off by default. User may enable it before scan for that session.

### 12.2 Verification trigger flow

1. When all tasks (up to 5) are ticked off, the app asks: "Do you want to verify? (Yes / No)"
2. If the user chooses "Yes," the system immediately decides and reveals the reward tier for this session (Blue or Golden).

### 12.3 Verification screen behavior (The Psychological Trap)

The screen enters a "paused" state once the tier is revealed:
- The app communicates: “The reward is waiting. You can tidy more before you submit the final photo.”
- This acts as a psychological trap/incentive to ensure the user actually made an effort if they were lying about the tasks.
- No auto-close, no timer. The app waits (even hours) until the user is ready to face the camera and snap the verification photo.

### 12.4 Verification options

- "I changed my mind / Forget it" (Finish without verifying, keep base points only)
- "Complete & Snap" (Activates camera to take the final proof-of-work photo)

### 12.5 Verification strictness promises

- strict and not guaranteed
- verdict final
- no detailed reasons
- no retries

## 13) Verification multipliers (exact totals)

### 13.1 No verify

- Keep base points already earned
- No bonus

### 13.2 Blue verify

After photo submitted:

- Pass: total becomes 4x base (bonus = +3x base)
- Fail: award half the Blue bonus (half bonus = +1.5x base)
- Fail total = 2.5x base
- If fail: session remains unverified; no retry

### 13.3 Golden verify (conditional)

After photo submitted:

- Pass: total becomes 10x base (bonus = +9x base)
- Fail: award half the Golden bonus (half bonus = +4.5x base)
- Fail total = 5.5x base
- If fail: session remains unverified; no retry

## 14) Golden eligibility (deterministic, not random)

Golden appears when the system detects the user:

- hasn’t verified recently and/or
- is behind their self-set daily goal

Exact thresholds can be defined in implementation, but the principle is: no loot randomness. Golden must feel deserved and purposeful.

(If you already have exact rules in code, those rules are the truth; this document describes the intent.)

## 15) Filters and Shop (Sklep) — what they actually do

### 15.1 Filters are for Dream Images (your rule)

Filters apply to the Dream Image generated from scans. The filtered Dream Image becomes:

- the Area Detail full-bleed header
- a saved artifact in Gallery

Filters are not primarily “photo effects for after pics”. (If after photos also get stylised later, that’s optional; not the backbone.)

### 15.2 Filter ownership model (V1)

- Filter choice is tied directly to the Babcia selection for that Area.
- The Babcia persona decides the tone, the filter style, and the "Dream" assets.
- Filter only applies to the specific scans and Dream images for that Area.

### 15.3 Sklep (Shop) requirements

- Displays locked/unlocked filters
- Each filter has a point price
- Purchase is one transaction: spend points → unlock filter
- Clear feedback on successful unlock
- No ingredient inventory (ingredient icons are visual theme only)

### 15.4 Pot rules

- Single currency
- Pot updates immediately on task ticks
- Verification bonuses apply when verification resolves

## 16) Gallery — why it exists (and what it contains)

Gallery exists to hold the product’s “trophies”: Dream images.

### 16.1 Gallery contents (V1)

Must include:

- saved Dream Images (filtered)
- grouped by Area and/or date
- supports viewing full-screen
- supports sharing (nice-to-have if not required)

Optional (only if already built / cheap):

- show the original scan thumbnail alongside the Dream image

But the Dream image is the hero.

### 16.2 Gallery role in motivation

Gallery is proof of progress. It reinforces:

- “I did something”
- “my room looks transformed”
- “filters matter”
- “points were used for a visible upgrade”

## 17) Burnout protection

### 17.1 Daily target (user-set)

User selects daily target (default 1).

When target is hit: Kitchen Closed

- UI dims / closes
- Babcia refuses additional scans for the day
- No punishment language

### 17.2 Streak rule (very specific)

Streak = number of days the user takes a scan photo.

- increments once per day on the first scan action
- verification photos do not count
- task completion does not count
- no punishment for missed days

## 18) UI / design system constraints (anti-Frankenstein)

### 18.1 Design system is the source of truth for styling

- Glass cards, spacing, radii, typography, gradients, shadows must come from the design system tokens/components.
- Do not import random third-party UI components if they conflict visually.
- If you copy an interaction pattern (like scaling header), re-implement using design system primitives.

### 18.2 Area Detail header interaction requirement (high-level)

The Dream header should feel premium:

- full-bleed image at top
- collapses/scrolls elegantly into content
- supports pull-down stretch (if feasible)

### 18.3 Typography lockdown

- **LINUX LIBERTINE EVERYWHERE.**
- This font is the absolute source of truth for all text in the app.
- No system-font defaults (San Francisco, Inter, etc.) are allowed to leak through. 
- Must be enforced across headings, body text, buttons, and card content.

## 19) Error states and guardrails (V1)

### 19.1 AI returns 0 tasks

- Prompt: retake scan photo
- Do not create an empty session

### 19.2 AI fails to generate Dream Image

- Fallback: Show a premium Babcia illustration specific to that Area (Kitchen, Lounge, etc.) showing her as the "Dream" they are working towards. 
- **Rule:** Never show the messy raw scan as the "Dream" goal. Babcia stepping in as the voucher is the brand-safe fallback.

### 19.3 Verification uncertainty

- strict, final, no reasons
- avoid blaming the user
- keep copy short and emotionally safe

## 20) “Done” checklist (acceptance criteria)

V1 is done when:

- Tabs are: Home, Areas, Camera, Gallery, Settings
- Home has at least:
  - Shop card → Sklep
  - Stats Progress card → overview
- Areas list shows stacked cards + Empty Pot state
- Area Detail has full-bleed Dream header
- Each scan produces:
  - Dream Image (filtered) that becomes the Area header
  - up to 5 tasks
- Task ticking awards points immediately
- Completion triggers bowl moment (pierogi drop)
- Verification toggle exists pre-scan, default off
- Verification paused screen exists with No / Blue / Golden
- Blue and Golden scoring totals match exactly (4x/2.5x, 10x/5.5x)
- Golden is deterministic, not random
- Daily target + Kitchen Closed works
- Streak increments only on first scan of day
- Shop unlocks filters using points
- Filters apply to Dream Images and thereby change Area headers
- Gallery shows saved Dream Images (filtered)

## 21) Implementation Plan (non-binding)

This section is execution guidance only. It does not change product requirements.

### 21.1 Milestone 1 - Dream pipeline as reusable module (required)

Interfaces (contracts only)
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

### 21.2 Milestone 2 - Session and bounded task generation

Interfaces
- Session model ties scan, Dream output, tasks (0 to 5), and base points
- TaskGenerator returns up to 5 tasks, no backlog

Wiring points
- Scan creates a Session and task list for Area Detail
- Task completion updates points immediately

Acceptance criteria
- No more than 5 tasks per session
- If 0 tasks, prompt rescan and do not create an empty session

### 21.3 Milestone 3 - Verification flow and scoring

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

### 21.4 Milestone 4 - Home hub and Gallery UX

Interfaces
- Home dashboard data: pot, streak, daily target, shop link, stats link, latest Dream preview
- Gallery index grouped by Area/date, Dream images are primary artifact

Wiring points
- Replace Weather tab usage with Home hub cards
- Gallery shows Dream outputs as trophies

Acceptance criteria
- Home communicates scan -> Dream -> points -> filters -> Gallery
- Gallery is Dream-first and grouped by Area/date

### 21.5 Milestone 5 - Burnout protection and streak rules

Interfaces
- Daily target settings (default 1)
- Streak counter (first scan per day only)

Wiring points
- Kitchen Closed state blocks additional scans after target
- Streak increments only on first scan of the day

Acceptance criteria
- Kitchen Closed UI is visible and gentle
- Streak ignores verification photos and task ticks

### 21.6 Out of scope (V1 non-goals)

- Persona switching logic
- Streaming cameras / Home Assistant monitoring
- Ingredient inventory beyond visual theming
