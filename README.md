# Eulerity Dynamic Form Builder

A single-screen iOS app that renders a fully dynamic form from a local JSON payload. Built for the Eulerity iOS take-home assignment.

---

## Demo



https://github.com/user-attachments/assets/demo.mp4

---

## Approach & Architecture

The core challenge is polymorphic JSON — one `fields` array containing TEXT, DROPDOWN, TOGGLE, CHECKBOX, and potentially unknown types. I evaluated three parsing approaches and landed on a **flat `FormField` struct with optionals**. A protocol hierarchy adds abstraction without adding clarity at this scale. Optionals are honest about what each field type actually uses.

`FieldType` uses a custom `init(from:)` that falls back to `.unknown` instead of throwing — so any unknown field type like `DATE_PICKER` is silently ignored rather than crashing the app.

State is managed in a single `FormViewModel` with three dictionaries:
- `values: [String: String]` — text fields
- `multiValues: [String: [String]]` — dropdowns
- `toggleValues: [String: Bool]` — toggles and checkboxes

This keeps field state flat, easy to read, and simple to serialize on submit.

---

## Features

**Required**
- All field types — TEXT (PLAIN, MULTILINE, NUMBER, URI, SECURE), DROPDOWN, TOGGLE, CHECKBOX
- Single and multi-select dropdowns
- Character counter + max length enforcement (keyboard and paste)
- Regex validation on TEXT fields
- Clickable metadata links in CHECKBOX via AttributedString
- Global theming from JSON hex codes
- Fields sorted by `order` integer, not array index
- Graceful handling of unknown field types
- Validation UX with per-field error messages

**Beyond the spec**
- **AI Quick Fill** — wand icon in nav bar opens a sheet with three domain-accurate campaign presets. One tap fills the entire form
- **Budget Insight** — daily budget field shows live weekly and monthly estimates (`~$7,500 / month`)
- **Scroll to first error** — after a failed Save the form automatically scrolls to the first broken field
- **Live summary card** — populates below the form as the user types, resolves dropdown labels from IDs
- **Success screen** — full screen confirmation after valid submit, shows all field values with resolved labels. Dismissing resets the form

---

## Product Decisions

**1. Validation timing**
Errors show on Save only, not on blur. Showing errors while the user is still typing is aggressive — they haven't finished yet. Once Save is tapped, errors clear field-by-field as the user fixes them so feedback is immediate without being intrusive.

**2. Toggle default state**
All toggles and checkboxes default to `false` regardless of field position. A retargeting toggle or legal checkbox defaulting to `true` would silently opt users into something they didn't actively choose. Opt-in should always be explicit.

**3. Missing options array on DROPDOWN**
Renders an empty menu rather than crashing. The spec says to handle missing arrays defensively — `field.options ?? []` everywhere. Same applied to `defaultValues`, `metadata`, and any other optional array.

**4. Invalid regex pattern**
If `regex_pattern` in the JSON is itself malformed, validation passes rather than blocking the user. The bug is in the JSON, not the user's input.

**5. Dropdown display vs state**
The UI shows option labels (`Meta Platforms`) but state tracks IDs (`net_meta`). This is consistent throughout — the success screen, summary card, and console output all resolve labels from IDs before displaying.

---

## What I'd Improve With More Time

- **Date picker field type** — the architecture already handles unknown types gracefully, adding `DATE_PICKER` would be straightforward
- **Accessibility** — VoiceOver labels, dynamic type support, minimum tap target sizes
- **Haptic feedback** — light impact on field errors, success notification on valid submit
- **Animated field transitions** — fields could animate in sequentially on load rather than appearing all at once
- **Persist draft state** — save form progress to UserDefaults so the user doesn't lose input if they background the app

---

## Requirements

- iOS 16.0+
- Xcode 15+
- No external dependencies — pure SwiftUI, no SPM packages

## Running the Project

1. Clone the repo
2. Open `EulerityApp.xcodeproj`
3. Select a simulator or device
4. Cmd+R

`form.json` is bundled inside the app target. No setup needed.

