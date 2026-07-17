# Ideation — two devils: wit and paralysis

*Design notes, not a commitment. Exploratory — bias toward volume over polish.*

## Mood anchor

A second image, distinct from every other mood anchor in this family: the
1491 Petrus de Plasiis woodcut illustrating the close of Dante's *Inferno* —
Lucifer frozen to the waist in the ice of Cocytus, three mouths chewing
mechanically, forever, on what they hold. He does not speak. He does not
notice the pilgrim looking at him. Ultimate power, reduced to a mute,
repetitive, powerless machine.

This image is a tonal reference only — not something LULL builds toward
literally or reproduces. It is used here for one thing only: it is the exact
inverse of the devil LULL already has on stage.

## 0. Why this fits LULL — the devil LULL already wrote

`Atmosphere.swift` already has a devil in it, and says so plainly in its own
doc comment:

> `bulgakov` — the **guest**: an urbane, amused observer who arrives
> hospitable and departs having revealed he was never a guest at all.

That's Woland — *The Master and Margarita*'s devil, in spirit, never in
quotation (`Atmosphere.swift`'s header is explicit that every line is
"original prose written *in the register of* each author, never
quotations"). Woland's whole mode is **mobility and delight**: he arrives at
your door amused, settles in enjoying your quiet, and by `awake` is
"curdl[ing]" into open triumph — *"manuscripts, they say, don't burn. neither,
it turns out, do i."* He has agency. He is having a wonderful time. He is
never stuck.

Dante's Lucifer is the opposite devil: **ultimate power with zero mobility.**
Trapped in the exact center of everything, unable to speak, unable to notice
the one creature in all of hell who's actually looking straight at him.
Where Woland performs *for* you, Dante's Lucifer can't perform at all —
he's the case where being watched forever has nothing left to do with the
person watching.

This is worth writing down because `docs/design/PILLARS.md`'s Pillar 3
already frames LULL's persistence motif as "one thesis about persistence,
expressed three ways" (the mirror's corrupted text, the idol's accumulating
gold, the reach's un-extinguishing ember). This doc proposes there are also
**two poles of devil**, and LULL has, so far, only built one of them.

## 1. Two poles of dread

**Dread-as-wit** (Woland/Bulgakov, shipped). The fear of being *toyed with*
by something that has more agency than you, is enjoying itself, and is
always one step ahead. It escalates by *gaining* presence — more familiar,
more revealing, more triumphant — until it openly admits what it always was.
This is a very sociable kind of dread: you are never alone with it, and
that's the problem.

**Dread-as-paralysis** (Dante's Lucifer, proposed, unbuilt). The fear of
*proximity* to something that cannot stop, cannot notice you, and cannot be
reached — a mechanism that has already arrived at its worst state and is
simply, mutely, continuing. It escalates by *losing* range: fewer words, the
same words, less give. This is a lonelier kind of dread — not "it's coming
for you," but "it's not going to react to you at all, and that is somehow
worse than if it did."

Both are devils. Neither is gore. Both stay inside "uncanny, not
traumatizing" — Woland by being funny about it, Dante's Lucifer by being
still about it. They are opposite *strategies* for the same one rule.

## 2. The real hook already sitting in the code

Here's the useful part: LULL doesn't need new architecture to try
dread-as-paralysis, because the mechanism is already built and already
tested. `Atmosphere.narration(for:beat:)` wraps a lingering phase's lines on
a modulo:

```swift
let i = ((beat % lines.count) + lines.count) % lines.count   // wrap, incl. negatives
```

`AtmosphereTests.testBeatsWrapDeterministically` pins exactly this: a player
who stays in one phase past its last written line doesn't get silence or a
crash — they get the *same handful of lines again*, forever, one every
`Atmosphere.beatSeconds` (9 seconds). Today that's an implementation detail,
quietly making sure a long `watching` doesn't run out of Beckett. Nobody has
written copy that treats the repetition itself as the point.

Three mouths, chewing, mechanically, without end, is a description of a
`beat % lines.count` loop that has stopped pretending to be going anywhere.
LULL already has the mechanism for eternal repetition without progress. It
just hasn't used it as dread yet — that's the whole pitch of this doc.

## 3. Mapping onto `EyeSession.Phase`

The two poles don't need to be two separate voices competing for space —
the cleanest version of this idea is that **Bulgakov's own arc forks at the
ceiling**, the same way his existing arc already has a hospitable face and a
curdled one:

| `EyeSession.Phase` | pole | what's already shipped / what's proposed |
|---|---|---|
| `seekingConsent` | wit | shipped — Bulgakov hospitable: *"do come in. we've been expecting you..."* |
| `watching` | wit | shipped — Bulgakov settling in: *"such a well-kept quiet. i've admired worse rooms..."* |
| `noticing` | wit | shipped — the pleasantries thinning: *"you're beginning to wonder whether i was ever really a guest."* |
| `awake` | **the fork** | shipped: wit's full arrival (*"manuscripts... don't burn. neither, it turns out, do i."*) — **proposed**: an alternate resolution where the same phase, if the player lingers, doesn't gain triumph, it loses motion |

Concretely: `awake` already carries two Bulgakov lines today, and the beat
wraps between them once the player has heard both. The proposal is a third
(or replacement) pairing for `awake` that reads as *stuck* rather than
*arrived* — written so that the wrap itself, the same two lines returning
every 18 seconds, is legible as the entity's own paralysis, not an authoring
gap. This needs no new `Voice` case, no new phase, no new sensor — it's a
content change to `Atmosphere.script(for: .awake)`, same shape as every line
already there.

**The direction matters.** The brief asks whether wit-then-paralysis or
paralysis-then-wit reads better. Wit-then-paralysis (Bulgakov charming
through the threshold and the lull, then going mute and mechanical at the
ceiling) is the stronger read: it's a real escalation, in the sense that
losing the ability to perform *after* fully arriving is a worse, colder
ending than triumph — the guest who talked his way all the way in and then
simply stops being able to leave either. Paralysis-then-wit would mean
opening on something stuck and ending on something delighted, which reads as
*de*-escalation — the dread gets more sociable, not less, which undercuts
`awake`'s job as the ceiling.

## 4. What each pole does to the player's dread

- **Wit** says: *something is paying close attention to you, and it's
  enjoying this.* The dread is in being an audience for something that has
  more agency than you do. It's dread with a face turned toward you.
- **Paralysis** says: *something has arrived at the worst version of
  itself, and your presence doesn't change anything about that.* The dread
  is in realizing the thing has stopped needing an audience at all — you
  are not special to it, you are just *there*, the way the pilgrim is just
  there at the center of Cocytus. It's dread with a face turned away, or a
  face that can't turn at all.

Put together, they cover more ground than either alone: wit dread resolves
in the fear of being *seen too well*; paralysis dread resolves in the fear
of being *unseen entirely, right next to something that can't stop*. `THE
EYE`'s whole premise — a camera that starts as attentive and ends "open all
the way" — has room for both closings, and they don't cancel each other:
Poe's existing `awake` lines (*"it knows your face now," "put the phone
down, it will keep your face"*) already carry the *seen-too-well* half.
Adding a paralysis-coded Bulgakov pairing alongside them gives `awake` both
halves of the ceiling at once, from two different registers, without either
one repeating the other's job.

## 5. Concrete copy examples (original prose, both poles)

Matching `Atmosphere`'s existing discipline — lowercase, two-breath lines,
never a shout, never a quotation of Woland or Dante:

**Wit (shipped, for contrast):**
> "manuscripts, they say, don't burn.\nneither, it turns out, do i."

**Paralysis (proposed, new):**
> "i have already said everything\ni am going to say."
>
> "ask again. i'll give you\nthe same answer. i only have the one."
>
> "there is nowhere further in.\nthis is what waiting all the way through looks like."
>
> "you can leave.\ni find i no longer remember how."

The last line is the important one — it's the moment the "amused observer"
framing of Bulgakov's own doc comment breaks, on purpose: an entity that
spent three phases being mobile, curious, and delighted, arriving somewhere
it can't get back out of either. That's the whole thesis of "two devils"
made into four lines: the same character, both poles, in sequence.

## 6. Restraint — staying inside `CLAUDE.md` §1 / `AGENTS.md`

- **No gore, if anything this pole is gentler.** Paralysis-as-dread is
  stillness, repetition, and withheld motion — closer to Beckett's register
  than Poe's. It's arguably the *safest* escalation LULL could write for a
  ceiling: nothing lunges, nothing grows teeth, nothing gets louder. The
  horror is entirely in what stops happening.
- **Uncanny, not traumatizing — same standard as every sibling doc.** No
  new visual content is implied here at all; this is copy only, and copy
  that describes an entity's own limits, not the player's.
- **Never actually deceives.** The fiction (something devil-shaped, stuck)
  stays legibly fiction; nothing here implies real data, a real recording,
  or a real presence outside the game.
- **Zero new consent surface, because zero new architecture.** This is a
  proposal to change `Line` entries inside `Atmosphere.script(for: .awake)`
  — no new `Sensor`, no new `Voice` case is required, no change to
  `EyeSession`, `CameraGate`, or `ConsentLedger` at all. If this ships, it's
  the lowest-risk kind of change this project can make: content, not
  mechanism.
- **No author's name on screen**, same rule as every register today —
  neither "Bulgakov" nor "Dante" would ever appear; the devil stays
  unnamed, exactly as Woland already does.

## 7. A fourth face for "I AM STILL HERE"

`docs/design/PILLARS.md` already tracks three expressions of LULL's
persistence motif: the mirror's corrupted copy, the idol's accumulating
gold, the reach's ember that won't fully extinguish. All three are about
something that *keeps* — it adds up, it stays lit, it survives being wiped.

Paralysis-dread is a different shape of "still here": not accumulation, just
**endurance without progress.** The beat-wrap (§2) doesn't add anything
across its repeats — it's the same two lines, over and over, world without
end. If the persistence family ever gets a name for each of its four
members, this one is the odd sibling out: it doesn't grow. It just doesn't
stop.

## Open questions for later (not blocking, not answered here)

- Does the paralysis pairing **replace** `awake`'s current triumphant
  Bulgakov lines, or sit **alongside** them as a second possible resolution
  the beat can land on? If both exist, what picks between them — random
  per-session, or driven by something legible to the player (e.g. how long
  they lingered before reaching `awake`, so a player who rushed gets wit and
  a player who waited gets paralysis)? Leaning: alongside, gated on
  dwell-time — it turns "how long you stayed" into the thing that decides
  which devil you meet, which is a nice, quiet, testable idea in its own
  right.
- Is this scoped to Bulgakov specifically, or could Poe's own `awake` lines
  get a paralysis-coded alternate too, given Poe's own bibliography (live
  burial, being trapped and aware) already has room for stillness dread
  alongside the tell-tale-heart escalation currently shipped? Worth a
  separate look — conflating the two registers' alternates in one pass
  risks blurring Poe and Bulgakov's separate jobs, which
  `docs/ideation/the-idol-and-kintsugi.md` and its siblings are consistently
  careful never to do.
- Should "two devils" ever become explicit in-fiction (a player who reaches
  `awake` twice, once fast and once slow, notices two different devils) or
  should it stay a single hidden authorial choice, never surfaced as a
  system the player is aware of? Leaning toward hidden — LULL's existing
  registers are never named on screen, and naming the *mechanism* ("there
  are two devils and you got the slow one") would explain the trick instead
  of just being it.
- Worth a copy pass to confirm none of §5's proposed lines drift close to
  any specific published English translation of the *Inferno*'s closing
  canto — the imagery (frozen, three mouths, mute) is centuries-old public
  domain, but a translator's *phrasing* of it might not be, and this doc's
  lines should stay demonstrably original the same way the existing
  Bulgakov lines stay demonstrably clear of any *Master and Margarita*
  translation.
