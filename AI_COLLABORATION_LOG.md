# AI Collaboration Log

**Tool used:** Claude (claude.ai)
**Project:** Dynamic Form Builder — Eulerity iOS Take-Home

---

## How I worked with Claude

I treated Claude like a senior developer I could bounce ideas off. I came with questions, evaluated what it gave me, pushed back when something felt off, and iterated. Not every suggestion made it in — a few caused bugs I had to debug myself.

---

## Researching the Company

**Me:**
> search eulerity company what they do

**Claude:** Explained they're an AI marketing automation platform for multi-location businesses. Clients manage campaigns across Google, Meta, TikTok, YouTube. Core product is campaign management — ad networks, daily budgets, campaign goals.

**How I used it:** Instead of building a generic demo form I redesigned the JSON around their actual domain — campaign goals, six real ad networks, landing page URL with regex, creative notes. Field IDs like `net_google` and `goal_foottraffic` mirror how a real marketing platform structures data. The form looks like something their clients actually use.

---

## Architecture Decision

**Me:**
> iOS take-home has polymorphic JSON — TEXT, DROPDOWN, TOGGLE, CHECKBOX, unknown types. what's the cleanest Codable approach?

**Claude:** Gave three options — protocol-based, enum with associated values, flat struct with optionals.

**Where I pushed back:** Claude initially leaned toward protocol-based saying it's "more scalable." I disagreed — at this scope that's over-engineering. I went with flat struct. Optionals are honest about what each field type uses and the code stays readable. I also asked Claude to make `FieldType` fall back to `.unknown` instead of throwing — Claude's first version would have crashed the app on any unknown field type.

---

## Iteration — form.json

**Me:**
> create a json payload that feels like a real ad campaign setup form

**Claude:** Generated a basic form — campaign name, ad networks, budget, toggle, checkbox. Fine but generic.

**Me:**
> change the json so it looks better different awesome

**Claude:** Generated a darker theme and more fields.

**What I shaped:** Pushed further — six ad networks with two pre-selected defaults, five campaign goal options, URI subtype with regex, multiline creative notes, two toggles that reflect actual Eulerity features (retargeting, AI budget optimisation), two clickable legal links. Dark theme `#0F0F13` so it stands out. This took two or three rounds of back and forth before it felt right.

---

## Debugging — Things Claude Got Wrong

**Number field accepting pasted letters**
Claude added `.keyboardType(.decimalPad)` — restricts the keyboard but not paste. I caught it when testing, Claude hadn't accounted for it. Fixed it myself in the binding setter:
```swift
filtered = newValue.filter { $0.isNumber || $0 == "." }
```

**Dropdown crash on missing options**
Claude force-unwrapped `field.options!`. Crashed immediately when I tested with a DROPDOWN field missing the options array. Changed to `field.options ?? []` everywhere. Claude should have been defensive here — the spec literally says to handle missing arrays.

**AttributedString link not opening Safari**
Claude's CheckboxView had a wrapping Button around the whole row. Tapping "Terms of Service" did nothing. I debugged it — the Button was consuming the tap before Text could handle the link attribute. Fixed by removing the outer Button and giving the checkbox box its own `.onTapGesture` separately, leaving Text to handle links via `environment(\.openURL)`.

**ViewModel validating same field twice**
Claude's first validate loop could write to `errors[field.id]` twice in one pass. I rewrote it — clear all errors first, then loop once cleanly.

---

## Product Features — My Ideas, Iterated with Claude

**Budget insight**

**Me:**
> below daily budget field show weekly and monthly estimate live as they type

**Claude:** Suggested the approach.

**My reasoning behind asking:** Eulerity's clients think in monthly spend. `~$7,500 / month` is more meaningful than `$250/day`. It's a feature their actual dashboard shows — I knew this from the research step. Used `30.4` not `30` for accurate monthly average, `.formatted()` for comma separators. Small details.

---

**AI Quick Fill**

**Me:**
> i want ai features in the app but no api — something simple pre-built options mock version

**Claude:** Suggested preset cards in a sheet.

**Me:**
> yes but something simple i dont want long lines of code short code just simple

**Claude:** Simplified it.

**What I designed:** Three presets — Restaurant Chain, Fashion Brand, Fitness Studio — domain-accurate field values for each. The UX pattern mirrors what a real AI recommendation feature would look like. In production this would call Eulerity's own engine.

---

**Scroll to First Error**

**Me:**
> after hitting save with errors automatically scroll to the first broken field

**Claude:** Wrote it with a `DispatchQueue.main.asyncAfter` delay.

**What I understood and kept:** The 100ms delay is intentional — SwiftUI needs one render pass to lay out the error labels before `scrollTo` fires. Without it you land in the wrong position. I kept it because I understood why it was there.

---

## Unit Tests — Debugging

**Me:**
> walk me through what each test is doing and why

**Claude:** Broke down `XCTAssert` usage — each test feeds input, asserts expected output, Xcode reports pass or fail.

**Me:**
> sigbarts comes instantly when i start testing

**Claude:** Diagnosed `@MainActor` isolation error — `import SwiftUI` in `EulerityModels.swift` was tainting the whole module, making `FormPayload` main-actor isolated so it couldn't be decoded in a test context.

**Fix I applied:** Moved `Color+Hex` to its own file, changed `EulerityModels.swift` to `import Foundation`. Claude explained the why, I understood it and made the change.

**Second crash — malloc error on `testViewModelInitialisesDefaultValues`**
`form.json` wasn't included in the test target bundle. Claude suggested adding it to target membership — that fixed it. Then I went a step further and rewrote the test with inline JSON so it has zero bundle dependency and works on any machine.

---

## Overall Reflection

**Where iterating with Claude paid off:** Architecture options, SwiftUI patterns like `@FocusState` shared across fields, the preset sheet structure.

**Where I had to step in:** Force-unwrap crash, paste input bug, AttributedString tap issue, double validation loop — none of these were flagged by Claude. I caught them through testing and fixed them myself.

**What I'd do differently:** Ask Claude to write defensive code by default and explicitly test edge cases before accepting any generated component.

