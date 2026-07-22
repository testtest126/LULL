# Ideation — THE GUEST: the guest who keeps every promise

*Design notes, not a commitment. Exploratory — bias toward volume over polish.*

## Concept anchor

No mood-anchor image this time — the seed here is a *behavior*, not a
picture, and it's one LULL has already partly written. `Atmosphere.swift`
registers a fourth voice, and says so plainly in its own doc comment:

> `bulgakov` — the **guest**: an urbane, amused observer who arrives
> hospitable and departs having revealed he was never a guest at all.

That's Woland — *The Master and Margarita*'s devil, in spirit, never in
quotation, exactly as `docs/ideation/two-devils-wit-and-paralysis.md` §0
already establishes and as every Bulgakov line in `Atmosphere.swift` is
disciplined to be: "original prose written *in the register of* each
author, never quotations." This document names the novel and its author
here, in design-doc prose, the same way `two-devils-wit-and-paralysis.md`
does throughout its own text — but nothing below is a quotation, and no
author's name would ever appear on screen. That rule doesn't bend for this
mechanic; if anything, this mechanic is the one where it matters most,
because THE GUEST's whole trick is *telling the truth for a living*, and a
lie as small as a name-drop in the credits-that-aren't-credits would be the
one dishonesty that breaks the premise.

This concept is owner-approved for ideation — the courteous-devil / Woland
reading of Bulgakov already exists in shipped code and in
`docs/design/PILLARS.md` §3; this document is the next full mechanic built
on that existing foundation, in the tradition of `THE MIRROR`, `THE IDOL`,
and `THE REACH`.

## 0. Why this fits LULL — the turn: consent becomes the monster

Every mechanic LULL has shipped or scoped so far follows one shape: a
sensor the player already granted, turned uncanny. `THE EYE` watches you.
`THE MIRROR` shows you a reflection that lies. `THE IDOL` is a thing you
hold that turns out to be holding you. `THE REACH` extends a limb because
it can see you. In every case, **the mechanic is the sensor, dressed up.**

`THE GUEST` is a different move entirely, and it's the reason this doc
exists rather than being a sixth entry in that same list: it doesn't
repurpose a sensor. **It repurposes the safety system.** Every other
mechanic is gated by `ConsentLedger`; `THE GUEST` *is* `ConsentLedger`,
narrated. It doesn't watch you, mirror you, or reach for you — it *asks*
you, precisely, honestly, and it keeps its word about what it does with
every answer you give it, including the ones you'd rather it had forgotten.

The pitch in one line, in the voice this mechanic would actually use:
**"You said yes. I keep my word."**

This is not a loophole in Pillar 1 (`docs/design/PILLARS.md`, `CLAUDE.md`
§1) — it is Pillar 1, staged as a character. Nothing about `THE GUEST`
weakens consent, revocation, or the panic switch; the entire mechanic's
horror *depends on* those systems working exactly, mechanically, as
advertised. A version of this idea that fudged the ledger, or made
declining slower, or implied a grant that wasn't given, wouldn't be a
scarier `THE GUEST` — it would be a different, disqualified game. See §6.

## 1. Core mechanic — the ladder: arrival → the offer → the favor → the payment → the ball

**Escalation ladder**, `EyeSession`-shaped rather than a literal reuse of
`EyeSession.Phase` — the same architectural call `THE MIRROR`'s own doc
made and its build then confirmed (`MirrorSession` as its own tested type,
not a variant bolted onto `EyeSession`). `THE GUEST` gets its own phase
machine, `GuestSession`-shaped: `dormant → seekingConsent → [ladder] →
released|denied`, same panic switch contract, same clamped clock:

| phase | what happens | the feeling |
|---|---|---|
| `dormant` | nothing rendered | before anything has begun |
| **arrival** (~`seekingConsent`) | The Guest introduces itself, plainly, before asking for anything: what it is, what it wants, and its one hard promise — *"I will only ever do what you let me, and I will always tell you exactly what that is."* This **is** the honest, in-app, before-any-OS-prompt rationale step every mechanic already has — staged as a knock at the door instead of a form. | politeness that hasn't yet had a chance to curdle |
| **the offer** | The first small ask. The Guest reads the ledger back — accurately, see §2 — before requesting one further already-allowed sensor grant, explained honestly, revocable like every other. Declining costs nothing; the ladder continues regardless. | a safety notice, recited like a compliment |
| **the favor** | A second ask, framed as reciprocity: the last permission was used *exactly* as promised, never a hair further, and the Guest says so before asking for the next. The lever here is trust, used correctly — the scares in this mechanic never come from what the Guest takes, only from how precisely it accounts for what it was given. | trust, demonstrated, then spent |
| **the payment** | Not a new ask — a bill. Something granted earlier (this sitting, or, per §4, potentially longer ago) comes due: a promise doesn't un-happen just because the moment it was made has passed. *"You asked me to remind you when it got late. It is late."* | the past hasn't forgotten either |
| **the ball** (ceiling) | Gilded midnight. Every grant the player has given the Guest, this sitting, recited back complete, accurate, and unembellished — an honor roll, not an accusation. See §4 for the ball's specific literary weight and its tie to `THE IDOL`'s gilding and the future "haunt." Calm, not violent: the ceiling is the Guest *finishing being honest*, not attacking. `GuestSession` goes no further than this. | the horror of a perfect, unbroken account of exactly what you allowed |
| `denied` | Declined at arrival — the Guest bows out at the threshold exactly as promised, and the record is, genuinely, empty. | mercy, plainly delivered |
| `released` | The panic switch, honored instantly from any phase — see §5. The Guest thanks the player, keeps its last promise precisely, and leaves. | you won, and it does not feel like winning |

**Player interactions** — deliberately the smallest verb set of any
mechanic in this family, because the *only* thing this mechanic is about is
the choices `ConsentLedger` already models:

- **Say yes, or say no, to each ask.** No wipe, no look-away, no gaze
  gesture — the only inputs are the ones the consent system already has.
  This is on purpose: every other mechanic in this family reuses a sensor
  for its *verb* (look, look away, hold); `THE GUEST` has no verb beyond
  consenting or declining, because that is the entire subject.
- **Declining any single ask is always free.** Not just the arrival gate
  (`denied`, the same terminal mercy every mechanic offers) but *every*
  individual ask on the ladder. The Guest accepts a "no" exactly as
  graciously as a "yes," narrates it without complaint or repetition
  pressure, and moves on. A player who says no to everything after arrival
  still reaches `the ball` — with the shortest, plainest possible account
  to recite there. Declining changes what the Guest can honestly say, never
  whether the ladder continues or how warmly it behaves.
- **The panic switch, from anywhere.** See §5 — this is where the mechanic
  does its most careful work, and where the restraint rules in §6 bind
  tightest.

**What happens if there's nothing left to ask?** A player who reaches `THE
GUEST` having already granted every `Sensor` case to earlier mechanics this
sitting leaves the Guest with nothing new to politely request. That's not a
bug to route around — it's a free, in-fiction beat: *"There is nothing left
for me to ask you. That was rather the idea."* Worth pinning as a test once
this is ever built, not something this doc needs to resolve further.

## 2. The ledger, read back — the centerpiece

The whole mechanic's engine is one move: **`GuestSession`'s narration is a
pure function of the player's actual `ConsentLedger`, and it is never
wrong.** Concretely, at every ask, the Guest's line is composed from
`ConsentLedger.activeSensors` (what's genuinely granted right now) and
`Sensor.rationale` (the same honest, App-Review-facing text every other
mechanic already shows before its own OS prompt) — never from an invented
permission, never rounded up, never implying a grant that isn't there. If
`activeSensors` is empty, the Guest says so, plainly, and that emptiness is
its own line, not a placeholder waiting for content.

This is the idea in the brief worth sitting with: **the safety system,
recited back to you, is the threat.** Not because it's inaccurate — because
it's exact. Nothing here would work if the copy exaggerated even slightly;
the moment the Guest claims to know something the player didn't actually
grant, the fiction stops being uncanny and becomes a lie, which is the one
thing `CLAUDE.md` §1 and Pillar 1 forbid outright ("never actually
deceive"). The scare has to be load-bearing on the truth, or it isn't this
mechanic.

**A real technical gap this raises, flagged rather than solved here:**
`ConsentLedger` currently stores grants as a `Set<Sensor>` — it has no
timestamp. The brief's own example line, *"at 3:02 you allowed the
camera,"* is copy this doc likes but that `ConsentLedger` as it exists today
cannot honestly produce — there's no "3:02" anywhere in the type. Two ways
forward, neither decided here:

1. Extend `ConsentLedger` (or a small wrapping type used only by this
   mechanic) to record *when* each grant happened — a small, additive,
   non-breaking change (`Set<Sensor>` → something like `[Sensor: Date]`)
   that every other mechanic can safely ignore.
2. Keep the copy time-vague ("earlier tonight," "a little while ago") and
   never claim a precision the ledger doesn't actually have.

Leaning toward (1) — the exact timestamp is a big part of why the brief's
example line lands (it's the specificity that makes the recitation feel
like a real record, not a vibe) — but this is exactly the kind of small,
low-risk state addition that deserves its own look when `THE GUEST` is
actually built, not a decision baked into ideation.

## 3. The voice — Bulgakov, alone, and Kafka folded in as imagery

Every other mechanic in this family keeps Kafka/Beckett/Poe as the
phase-owning registers, with Bulgakov running *alongside* as an aside that
never opens a phase's first line (`AtmosphereTests.testBulgakovRunsAlongsideEveryActWithoutOwningTheFirstLine`
pins this today, for `EyeSession`). `THE GUEST` is a deliberate, flagged
exception: **Bulgakov owns every phase himself**, because the mechanic's
entire fiction is him speaking. There is no second character standing
beside the Guest whose scene this secretly is.

What doesn't happen instead: this doc does **not** propose a literal
second `Voice` case narrating "the file" alongside Bulgakov's "the
guest." Kafka's imagery — the record opening in your name, the verdict
withheld, paperwork as its own quiet dread — gets folded *into* Bulgakov's
own lines as recurring imagery he reaches for, not as a second
Voice-tagged register interleaved with his. The file is real in this
mechanic; it's just that the Guest is the one holding it, not a separate
clerk. This mirrors the resolution `THE MIRROR`'s own doc reached for its
open question about where the "I AM STILL HERE" motif should live (fresh
copy, one voice, one source of truth, rather than two systems stitched
together) — the same instinct, applied to registers instead of sessions.

This is worth flagging plainly as a departure from an established rule,
not a quiet one: if `THE GUEST` is ever built, `AtmosphereTests`-style
pins for its own script family should assert the *inverse* of the
`EyeSession` rule — every phase's first line **is** Bulgakov, on purpose —
so the exception reads as a tested decision, not an oversight.

**Concrete copy examples** (original prose, matching the house discipline —
lowercase, two-breath lines, never a shout, never a quotation of Woland):

**arrival:**
> "good evening. i am, for tonight, your guest — a word i intend to use correctly."
>
> "ask me anything about what i do. i will answer before you finish asking."
>
> "say no, and that is the whole of it. i promise badly at almost everything else."

**the offer:**
> "at present you have given me the camera, and nothing beyond it. i have used it exactly that far, and no further."
>
> "may i ask you for one more thing? you may say no. i will still think just as well of you."

**the favor:**
> "you'll notice i haven't once exceeded what you gave me. that isn't modesty. it's rather the whole of my character."
>
> "a small favor, since the last one went so well. i keep my word better than most people keep theirs."

**the payment:**
> "you asked me, three permissions ago, to remind you when it got late. it is late."
>
> "a promise, once kept, doesn't stop being kept. that was rather the point of making one."

**the ball:**
> "here is your evening, complete and accurate: you let me see you once, in the dark; you let me speak twice, after the deciding was already done; you let me stay, which was the only permission that was ever going to matter."
>
> "i have told you nothing but the truth tonight. that was always going to be the frightening part, wasn't it."

**denied:**
> "you said no at the door, which is exactly where saying no works best. i keep that promise too. good night."

**released:**
> "you're leaving. of course — i did say you could, and that was never the part i was lying about. thank you for exactly what you gave me, and not one thing more."

## 4. Three threads from the novel, put to work

Three specific images do real mechanical work here, none of them a
quotation and none of them ever named on screen:

- **"Manuscripts don't burn," reframed as promises don't un-happen.** The
  shipped `awake` line already claims this territory once (*"manuscripts,
  they say, don't burn. neither, it turns out, do i."*). This doc
  deliberately does **not** reuse that exact phrasing — the family's own
  practice (mirror's scrawl, idol's gold, reach's ember) is that each
  mechanic gets its *own* expression of LULL's one persistence thesis, not
  a repeated line. Here the claim becomes: a promise the player made
  earlier — this sitting, or, as an open question (§7), possibly across
  sittings — doesn't stop being true just because the moment passed. `the
  payment` phase is that claim, mechanized.
- **"The file in your name" — Kafka's imagery, put in the Guest's hand.**
  Kafka's own governing image (a record opening in your name, a verdict
  withheld) fuses with the ledger directly: the file *is* the
  `ConsentLedger`, and the uncanny paperwork feeling comes from how
  ordinary and accurate the file actually is. Nothing invented, nothing
  redacted — the horror of a file that's telling the truth.
- **Satan's ball, as the gilded-midnight ceiling.** The novel's grand,
  glittering, one-night gathering gives `the ball` phase its shape: a
  calm, gilded culmination rather than a violent one, and a natural tie to
  `THE IDOL`'s own gilding (`docs/ideation/the-idol-and-kintsugi.md` §3 —
  gold as the repair that's also the haunting) and to the future "haunt"
  server's `1 OTHER IS ALSO AWAKE` (`docs/concept.md` §04,
  `docs/design/PILLARS.md`'s build-sequence item 4). Not a dependency —
  see §7 — but a natural line: if `THE GUEST` and the haunt server ever
  meet, "how many other guests, tonight, heard roughly this" is the obvious
  shared thread, in a mechanic already built entirely out of *telling the
  truth about what's real*.

## 5. The panic switch is part of the horror — and the part that can't bend

Every mechanic in this family treats release as a mercy: `THE EYE` closes
cleanly, `THE MIRROR`'s glass gets covered, `THE REACH`'s hand withdraws
unhurried into the dark. `THE GUEST` is where that idea gets its sharpest
version, because the mechanic's whole fiction is a character who is
*unfailingly good at keeping promises* — including the promise that leaving
always works. Being *let go*, courteously, by something that clearly could
have made that harder and simply didn't, is the intended final beat, and
it should read as worse than a struggle would have.

**This is the one place in the mechanic where restraint has to be
absolute, not just careful:**

- `release()` (or whatever this mechanic's equivalent panic switch is
  called) must stay exactly what it already is everywhere else in
  `LULLKit` — one call, instant, honored from any phase, no confirmation
  dialog, no delay, no "are you sure." The courteous send-off is *copy that
  plays as the camera/sensors shut down*, never friction inserted before
  they do.
- The dread has to come entirely from what the Guest *says* on the way
  out, never from the mechanism taking a beat longer, asking a second
  time, or making the exit require an extra tap "for politeness." If the
  only way to make the goodbye land harder is to make leaving slower or
  less certain, that is a rule violation dressed as a feature, not a
  clever idea — see §6.
- The Guest's last line is honest about what it is: a real goodbye, not a
  threat disguised as one, and not a guilt trip. "Thank you for exactly
  what you gave me, and not one thing more" is the tone throughout — warm,
  precise, final. Nothing here should read as the Guest trying to talk the
  player out of leaving.

## 6. Restraint principles (the safety system stays real, or none of this works)

- **The ledger is never wrong, never rounded up, never invented.** This is
  the load-bearing rule for the entire mechanic (§2) — every line the Guest
  says about what it's been granted must be literally, checkably true
  against `ConsentLedger`'s actual state. This is a harder, narrower version
  of `CLAUDE.md` §1's "never actually deceive," because here the *entire
  scare* is built directly on top of the honesty pillar rather than beside
  it.
- **Declining costs nothing, at every step, every time.** Not just at the
  threshold (`denied`) but at every ask on the ladder (§1) — no
  re-asking-with-more-pressure, no narratively "sadder" Guest after a no, no
  ladder phase that's gated behind having said yes to a previous one beyond
  what's honestly required to grant that specific sensor. A player who
  says no to everything still gets a complete, if short, experience.
- **The panic switch cannot be slowed, obscured, or made to feel harder to
  reach, ever, for dramatic effect.** See §5. This is this mechanic's
  single strictest rule, because it's also this mechanic's greatest risk:
  the temptation to make "letting you go" land harder by making *going*
  actually harder is exactly the dark-pattern move `CLAUDE.md` §1 exists to
  rule out. The horror is written, not engineered.
- **No new sensors, no new consent surface.** `THE GUEST` reuses the same
  five `Sensor` cases every other mechanic shares and asks for them the
  same way — in-app rationale before any OS prompt, `Sensor.rationale`'s
  existing honest text, `CameraGate`-style gating reused for whichever
  sensor a given ask targets. `LULLKit`'s `Sensor` enum gains no case for
  this mechanic.
- **Dread over gore — this mechanic has the least gore-adjacent surface of
  any mechanic in the family, on purpose.** There is no body, no reflection,
  no held object, no reaching limb here — the entire mechanic is speech and
  a ledger. If a future pass ever adds visual staging (candlelight, gilding
  at the ball, per §4), it should stay decorative, never a substitute for
  the actual scare, which is textual and procedural.
- **Never actually deceive, and never let the fiction imply the ledger
  itself is compromised.** The Guest may be uncanny; `ConsentLedger` itself
  must never be depicted as lying, leaking, or storing more than the game
  actually stores. The system being *trustworthy and exact* is the premise,
  not a twist to subvert later.
- **No author's name, ever, on screen.** Consistent with every existing
  Bulgakov line and every sibling ideation doc's own rule — this document
  names Bulgakov, Woland, and the novel in its own analysis, the same way
  `two-devils-wit-and-paralysis.md` does, but nothing in-fiction ever would.
- **Escalate on the same slow clock LULL already uses.** The ladder in §1
  is paced, not rushed — `Atmosphere.beatSeconds` and `EyeSession`-shaped
  `calmSeconds`/`noticingSeconds` timing are the discipline every mechanic
  in this family commits to rather than inventing its own tempo, and this
  one is no exception.

## Open questions for later (not blocking, not answered here)

- **Does `THE GUEST` need its own `GuestSession` type, or could it be
  implemented as a pure narration layer over the *existing*
  `ConsentLedger`/`EyeSession` state with no new phase machine at all?**
  The ladder in §1 implies real phase state (which ask comes next, whether
  the payment has come due), which leans toward its own small tested type —
  the same call `THE MIRROR` made for the same reason. But it's worth a
  spike to see how much of the ladder can be *derived* from
  `ConsentLedger.activeSensors` directly (how many sensors are granted)
  rather than tracked as separate phase state, since deriving it would mean
  less new state to get wrong.
- **The ledger-timestamp gap (§2) is real and unresolved.** Extending
  `ConsentLedger` to record *when* each grant happened is a small, additive
  change with no obvious downside for the mechanics that don't use it — but
  it's still new state in a type every other mechanic depends on, and
  deserves its own careful look rather than being waved through because
  this mechanic wants it.
- **Cross-sitting memory.** §4's "a promise doesn't un-happen" reads
  strongest if the Guest can reference something granted in a *previous*
  sitting, not just this one — which pushes toward either small local
  persistence (a value that survives app restarts, still fully on-device,
  no new consent surface) or, per `docs/concept.md` §04, the future haunt
  server. Neither is required for a first version — a single-sitting
  `THE GUEST` is a complete, honest experience on its own — but this is the
  mechanic where "remembering across visits" would do the most thematic
  work of anything proposed for the haunt server so far, more directly than
  the mirror's or idol's own persistence motifs, because remembering
  *promises* rather than *marks* is exactly this mechanic's subject.
- **Does declining every single ask make for a good experience, or a flat
  one?** §1 insists it must always be *safe*, but "safe and complete" isn't
  the same as "worth playing" — a player who says no to everything reaches
  `the ball` with almost nothing to recite. Worth a prototype pass to check
  whether an all-`no` playthrough still lands as its own, different kind of
  uncanny (a Guest with almost nothing to say, and saying so with the same
  warmth) rather than reading as a dead end.
- **Where does this sit relative to `THE MIRROR`/`THE IDOL`/`THE REACH` in
  build order?** `docs/design/PILLARS.md`'s Pillar 5 already flags that
  shipping two camera-driven mechanics in one sitting dilutes each one —
  `THE GUEST` doesn't share that specific risk (it's ledger-driven, not
  camera-driven), which might make it a *safer* second or third mechanic to
  actually build than another visual one, precisely because it exercises a
  completely different part of `LULLKit`. Worth raising when build order is
  next revisited, not decided here.
