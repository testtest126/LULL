# LULL — Moodboard

*Agent-facing style reference. Skim, don't read straight through. Code is the*
*source of truth — this doc points at it rather than restating it, so it can't*
*drift out of sync. See [`PILLARS.md`](../PILLARS.md) for the design rationale*
*behind these choices.*

## Palette

**Source of truth is code, not this doc — two real token sets exist, and they
differ slightly by design:**

| token | in-app (`app/Sources/Theme.swift`) | landing page (`docs/index.html` `:root`) |
|---|---|---|
| ink (base) | `#07080a` | `#090c12` |
| bone (text) | `#d7d5d0` | `#d9d2c4` |
| dim (secondary text) | `#82858c` | `#838b93` |
| faint (tertiary / hairlines) | `#494c53` | `#454b55` |
| red (the one accent) | `#bb3b3b` | `#a8433f` |
| sepia (iris only) | — | `#b9a179` |
| cyan (sclera/stroke only) | — | `#7f9aa2` |

The landing page's palette is deliberately "nudged" from the app's — cooler,
more desaturated, more analog — for its own art direction; it is not a copy
error. See the comment at the top of `docs/index.html`'s `:root` block.

**If you were handed different hex values for this project** (a near-black
`#0a0a0c`, a warm-dark `#2e2c26`, blood-red `#b00020`, off-white `#f0eee6`) —
those are not in the codebase. Use the table above instead; flag the mismatch
rather than silently adopting guessed values.

**Rules, either token set:**
- One base near-black, one text color (used at full/dim/faint opacity — three
  weights of the *same* color, not three colors).
- Exactly **one** accent hue (red). It marks a status dot, a single word, an
  ending, a hover state — never a second surface, never a gradient of itself
  into something brighter.
- Cold, desaturated, high-contrast-on-black. No warm fills anywhere outside
  the iris.

## Typography & voice

- **System/status chrome** — thin, wide-tracked, **UPPERCASE MONO**. e.g. the
  landing page's `.hud` line (`REC · SUBJECT: YOU · LOCAL TIME: 03:33 ·
  FRONT CAMERA: ACTIVE · 1 OTHER IS ALSO AWAKE`) and `.eyebrow`/`.mech-status`
  labels; in-app, `Theme.label` (`.caption2`, monospaced) rendered
  `.textCase(.uppercase).tracking(2)` for `"watching"` and `"close the eye"`
  (`app/Sources/EyeView.swift`). Chrome announces state; it does not narrate.
- **Narration** — quiet **lowercase serif**, two-breath lines, never a shout.
  `"the light is going.\nlet it go."` Source font stack: `--serif` in
  `docs/index.html` (`ui-serif, "New York", …`).
- **Voice registers are owned by `LULLKit/Sources/LULLKit/Atmosphere.swift` —
  do not write new narration lines anywhere else.** Four registers, three
  gating one phase each, one running throughout:
  - **Kafka** — the threshold (`seekingConsent`, both endings' formal half): a
    record opening in your name, the verdict withheld.
  - **Beckett** — the lull (`watching`, and the calm/closing): waiting, the
    failing light, the nothing that is also a mercy.
  - **Poe** — the watch (`noticing` → `awake`): the eye that will not blink.
  - **Bulgakov** — the guest: a throughline, not a phase-owner. Hospitable at
    the threshold, curdling by `awake` into revealing he was never a guest.
  Every line is original prose *in* each register, never a quotation — no
  author's name ever appears on screen.

## UI fragments

- **The eye** — a faint dark circle/aperture, barely resolving out of black.
  In-app: `CameraPreview` desaturated and heavily dimmed/blurred, escalating
  by phase (`app/Sources/EyeView.swift`). On the landing page: `.scroll-eye`,
  a fixed, `opacity: .14` SVG glyph whose clip-path opens on scroll
  (`--scroll-lid` in `docs/index.html`).
- **Edge-of-frame labels** — small, corner- or edge-anchored, never centered
  chrome competing with the content.
- **Minimal chrome overall** — no icons beyond the eye motif, no drop
  shadows or borders beyond a 1px hairline (`--hair`, ~8% opacity).
- **Nothing shouts.** If an element draws the eye before the copy does,
  it's wrong for this project.

## Tone words

quiet dread · consent · watching · restraint · sleeplessness ·
the intimate turned uncanny

## Do / Don't

| DO | DON'T |
|---|---|
| Horror by permission — every sensor consent-gated, revocable, panic switch always reachable | Jump-scares |
| Negative space | Gore |
| Near-silence | Bright colors |
| Exactly one red accent | Clutter |
| Slow | A second accent hue |

## Motion & feel

Slow, breathing, sub-perceptual — nothing sudden, no jump cuts. The
scroll-driven aperture (the eye opening as the page descends,
`--scroll-lid` in `docs/index.html`) is the model for any new motion: tied to
a continuous input, never a timed pop. `prefers-reduced-motion` always holds
a single calm state (the eye's fallback is a static 25%-open frame, no
animation) — any new motion needs an equivalent still frame, not just a
skipped animation.

## Reference screens

Real in-app screenshots, referenced (not duplicated) from `docs/screens/`:

- [`01-consent-title.png`](../../screens/01-consent-title.png) — the
  threshold: honest rationale, refusable, before any OS prompt.
- [`02-watching.png`](../../screens/02-watching.png) — the calm: dim, degraded
  camera preview, Beckett's register.
- [`04-awake.png`](../../screens/04-awake.png) — the ceiling: Poe's register
  at its most direct, "close the eye" always visible.
- [`06-ending-released.png`](../../screens/06-ending-released.png) — the
  panic switch honored: a clean, merciful ending.

(`03-noticing.png` and `05-ending-denied.png` also exist in `docs/screens/`,
covering the remaining two phases, if a fuller set is needed.)

**Live reference:** the actual scroll-driven eye and full landing page are
live at [testtest126.github.io/LULL](https://testtest126.github.io/LULL/) —
truer to current behavior than any static export of it.
