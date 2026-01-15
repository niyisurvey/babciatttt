---
description: Tobiasz's Creative Pipeline — Handles image generation, naming, and delivery to GitHub.
---

# TOBIASZ'S CREATIVE PIPELINE

This workflow is designed to be executed by **Gemini** (or any agent) assisting Tobiasz.

## 1. PREPARATION
1. Read `_ASSET_PIPELINE_PROTOCOL.md` to lock visual constraints.
2. Ask Tobiasz to upload a **Reference Image**.
3. Ask Tobiasz for a description of the **New Asset**.

## 2. GENERATION
1. Generate the image following the "Claymorphic Soul" rules:
   - Matte clay texture.
   - Studio lighting.
   - **Solid #00FF00 background.**
2. Deliver the image to Tobiasz for approval.

## 3. PACKAGING
1. Once approved, determine the correct folder:
   - `/Images/clay`
   - `/Images/3d`
   - `/Images/2d`
   - `/Images/stickers`
   - `/Images/whatever`
2. Name the file correctly (e.g., `sticker_pierogi_happy.png`).

## 4. THE SHIPMENT (ACT: SHIP)
When Tobiasz says "Ship it" or "Wrzuć to":
1. Check if on branch `creative/tobiasz-hub`. If not, create it.
2. Add the file to Git.
3. Commit with message: "Creative: New asset by Tobiasz - [Filename]"
4. Push to remote origin.

## 5. REWARD
Congratulate Tobiasz in Polish (e.g., "Kawał dobrej roboty, Tobiasz! 🔥").
