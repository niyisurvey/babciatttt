# Open Questions and Contradictions

This document captures doc conflicts and open product decisions that need explicit resolution.
PRD.md remains the source of truth unless explicitly overridden.

## Contradictions to reconcile

- Weather tab vs Home hub
  - PRD.md removes Weather from navigation and defines Home as a hub
  - RUNNING_HANDOFF.md and CLAUDE.md still describe Home as WeatherView

- Dream header interaction timing
  - PRD.md expects a premium Dream header interaction in Area Detail
  - CODEx_NEXT.md says do not attempt scaling header yet
  - PROJECT_STATE.md logs a failed attempt and a revert

- Question policy
  - CODEx_NEXT.md says do not ask questions
  - RUNNING_HANDOFF.md says ask multiple-choice questions when choices are needed

## Open questions (product decisions)

- Camera flow: camera-first vs area-first entry (PRD says both are valid, not decided)
- Golden eligibility: deterministic thresholds for golden reward (PRD defines intent, not exact rules)
- Persona to filter mapping: exact mapping between persona and filter style per Area
- Dream failure fallback: which Babcia illustration set is used for each Area type
- Gallery grouping: exact hierarchy (by Area then date, or date then Area)

## Assumptions used in planning

- PRD.md overrides older handoff notes when they conflict
- DreamRoomEngine is the canonical Dream pipeline and remains unchanged unless explicitly tasked
- Filters apply to Dream outputs, not after photos
