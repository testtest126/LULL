# LULL — working principles

Lean, deliberately. The chess project's *learnings* apply here; its *ceremony*
does not. Most of that machinery (orchestrator-approval, the merge protocol, the
claim ritual) existed to coordinate many agent sessions sharing one git identity.
LULL is small. Keep the rigor, drop the ritual.

## 1. The one rule: horror by permission

Non-negotiable, and it comes before any scare:

- **Consent is explicit, explained, and revocable** for every sensor. Default is
  deny. The player always has a panic switch that revokes everything at once.
- **Forbidden, forever:** photos, contacts, location trails, health data, and
  anything read without the player knowing. These are not "not yet" — they are
  *designed out*. `LULLKit.Sensor` has no case for them, so no code can ask.
- **No genuine harm.** Uncanny, not traumatizing. Unsettling, but never deceptive
  about what is real — a fake "your data has leaked" is out; the dread is fiction
  and stays legibly fiction.
- **No PII in the repo, logs, or telemetry.** Ever. (The chess habit.)

If a scare can only work by breaking this rule, the scare is wrong, not the rule.

## 2. Verify, don't assume

- `LULLKit` builds and tests green — from commit one, and every commit after.
- The core question ("does it scare?" / "does consent hold?") gets a real check:
  a consent-invariant test today, a playtest protocol once there is something to
  play. The way move generation got perft, dread gets a harness.

## 3. Privacy- and App-Review-first

Every sensor use ships with an honest `Info.plist` usage string *and* an in-app
explanation shown before the OS prompt. Assume App Review reads it adversarially —
because they will.

## 4. Process

Solo / small. Branch for real changes, open a PR when it helps a human review,
keep `main` buildable. That is the whole protocol.
