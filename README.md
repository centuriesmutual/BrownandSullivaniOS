# Brown and Sullivan — iOS workspace

Native **SwiftUI** iOS app combining **Office** (agent workspace), **Admin** (operations console), and **PressBox** (Campaign / marketing hub). Ported from the original Next.js products; primary flows are native (no WebView).

- **Platform:** iOS 17.0+ (iPhone & iPad)
- **Language:** Swift 5.9 / SwiftUI
- **Architecture:** Single `AppState` `ObservableObject` + `AppRoot` routing from a shared workspace hub
- **Dependencies:** None (stdlib + SwiftUI only)

## First launch

The app opens the **workspace hub**. Pick one of three sign-in paths:

| Entry        | Login screen            | After sign-in        |
| ------------ | ----------------------- | -------------------- |
| **Office**   | `Auth/LoginView`        | Tabbed office shell  |
| **Admin**    | `Auth/AdminLoginView`   | Admin console        |
| **PressBox** | `Campaign/CampaignLoginView` | Marketing Hub tabs |

Use any **non-empty email and password** (demo behavior, same idea as the web apps). **Sign out** returns to the hub.

**From Office:** the profile menu still includes **Switch to Admin**, which opens the admin console without a second login (same session).

## Products

### Office

Tabs: **Home** (app grid, meetings, calls, email preview, AI assistant, activity), **Dialer** (VoIP-style line + keypad + recents + enrollment sheet), **Email**, **Calendar**, **Drive** (cloud-style shelves, sync strip, list/grid), **Chat**, **Analytics**, **Settings**, **Documents**, **Enrollment** (wizard).

UI leans **Google / Apple workspace** chrome: neutral grouped background, suite search on Home, RingCentral-inspired phone surfaces, Dropbox-style Drive cues (`Theme.Suite`, `SuiteControls`).

### Admin

System overview, users, system health, activity — `Admin/AdminView.swift`. Reach it from the **Admin** card on the hub or **Switch to Admin** from Office.

### PressBox (Campaign)

Tabs: **Dashboard** (tasks, calendar, events), **Messaging**, **Submissions**, **Intelligence** (article analytics). Overflow screens (toolbar / menu): **Account balance**, **Create ad**, **Performance**, **Chat & meetings**, **Advanced BI**.

**Popular workspace:** if the campaign email matches certain patterns (e.g. `editor.*`, `lead.*`, `+popular` in the address, `@partners.pressbox.marketing`, etc.), the user gets trending highlights, lands on **Intelligence** first, and sees Popular chrome. See `AppState.campaignTier(forEmail:)` and the login footnote on `CampaignLoginView`.

## Project structure

```
BrownandSullivanOffice/
├── project.yml                      # XcodeGen spec
└── BrownandSullivanOffice/
    ├── BrownandSullivanOfficeApp.swift   App entry
    ├── ContentView.swift                  Hub → login routes → shells
    ├── Info.plist
    ├── Auth/
    │   ├── HubView.swift                  Office | Admin | PressBox
    │   ├── LoginView.swift                Office sign-in
    │   └── AdminLoginView.swift           Admin sign-in
    ├── Campaign/                          PressBox (Marketing Hub)
    ├── Theme/Theme.swift                  Design tokens + suite chrome modifiers
    ├── Models/Models.swift                Domain models + `OfficeTab`, etc.
    ├── Models/AppState.swift              Global state, seeds, auth helpers
    ├── Office/                            Tab views, Documents, Enrollment
    ├── Admin/AdminView.swift
    ├── Components/                        DashboardCard, SuiteControls, …
    └── Resources/Assets.xcassets
```

## Build (macOS)

Use a Mac with **Xcode 15+**.

### With XcodeGen

```bash
brew install xcodegen
cd BrownandSullivanOffice
xcodegen generate
open BrownandSullivanOffice.xcodeproj
```

### Without XcodeGen

Create a new iOS App in Xcode (SwiftUI, iOS 17), then add the `BrownandSullivanOffice/BrownandSullivanOffice/` sources to the target as described in earlier repo docs, or drag the folder in as a group.

## Routing reference

`AppState.activeRoot` (`AppRoot`):

- `hub` — workspace picker  
- `officeLogin` / `office` — Office login → `OfficeRootView`  
- `adminLogin` / `officeAdmin` — Admin login → `AdminView`  
- `campaignLogin` / `campaign` — Campaign login → `CampaignRootView`  

## Web → iOS mapping (sample)

| Web (Next.js)              | iOS (SwiftUI)                    |
| -------------------------- | -------------------------------- |
| Landing / product pick     | `Auth/HubView.swift`             |
| Office login               | `Auth/LoginView.swift`           |
| Admin login (dedicated)    | `Auth/AdminLoginView.swift`      |
| Campaign login             | `Campaign/CampaignLoginView.swift` |
| Office tabs                | `Office/OfficeRootView.swift` + tab views |
| Admin                      | `Admin/AdminView.swift`          |
| Campaign dashboard & routes| `Campaign/*.swift`               |

## Notes

- Data is **in-memory / seeded** in `AppState` — no backend. Good starting points for API wiring are the same `AppState` publishers and `func` actions.
- **Dark mode** follows the system where standard SwiftUI components are used.
- You can develop the repo on Windows; **building** requires Xcode on a Mac.
