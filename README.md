# Brown and Sullivan Office (iOS)

Native SwiftUI iOS port of the [Office Dashboard](https://github.com/) Next.js web app. Mirrors every screen from the source: Login, Office (Home, Dialer, Email, Calendar, Drive, Chat, Analytics, Settings) and Admin.

- **Platform:** iOS 17.0+ (iPhone & iPad)
- **Language:** Swift 5.9 / SwiftUI
- **Architecture:** Single `AppState` `ObservableObject` store + per-screen `@StateObject` view models where useful
- **Dependencies:** None (stdlib + SwiftUI only)

## Project structure

```
BrownandSullivanOffice/
├── project.yml                      # XcodeGen spec (source of truth for the .xcodeproj)
└── BrownandSullivanOffice/
    ├── BrownandSullivanOfficeApp.swift   App entry
    ├── ContentView.swift                  Root: Login vs Office vs Admin
    ├── Info.plist
    ├── Theme/Theme.swift                  Colors, gradients, spacing tokens
    ├── Models/Models.swift                Email, Meeting, Note, ChatContact, etc.
    ├── Models/AppState.swift              Global ObservableObject
    ├── Auth/LoginView.swift               Login screen
    ├── Office/OfficeRootView.swift        Tab container
    ├── Office/HomeView.swift              Dashboard
    ├── Office/DialerView.swift            Phone keypad + enrollment
    ├── Office/EmailView.swift             Mailbox
    ├── Office/CalendarView.swift          Month + events
    ├── Office/DriveView.swift             Files browser
    ├── Office/ChatView.swift              Contacts + conversation
    ├── Office/AnalyticsView.swift         Stats + sales table
    ├── Office/SettingsView.swift          Profile, notifications
    ├── Admin/AdminView.swift              System status, metrics, users, activity
    ├── Components/                        DashboardCard, IOSAppIcon, StatCard, …
    └── Resources/Assets.xcassets          AppIcon, AccentColor
```

## Build instructions (macOS)

You need a Mac with **Xcode 15+** to build and run. (You can edit on Windows; you cannot compile.)

### 1. Generate the Xcode project with XcodeGen

```bash
brew install xcodegen
cd BrownandSullivanOffice
xcodegen generate
open BrownandSullivanOffice.xcodeproj
```

### 2. Or open without XcodeGen

If you prefer not to install XcodeGen, on the Mac:

1. Open Xcode → **File → New → Project → iOS App**
2. Name it `BrownandSullivanOffice`, organisation identifier `com.brownandsullivan`, interface **SwiftUI**, language **Swift**, deployment target iOS **17.0**
3. Delete the generated `ContentView.swift` and `BrownandSullivanOfficeApp.swift`
4. Drag the entire `BrownandSullivanOffice/BrownandSullivanOffice/` folder from this repo into the Xcode project navigator (choose "Create groups", target = the new app)
5. Build & run on a simulator or device.

## Login

Like the web version: any non-empty email + password lets you in. Tap the avatar in the top-right of the Office tab and choose **Switch to Admin** to see the admin dashboard, or **Sign Out** to return to login.

## Mapping from web to iOS

| Web (Next.js)                          | iOS (SwiftUI)                          |
| -------------------------------------- | -------------------------------------- |
| `app/page.js` (login)                  | `Auth/LoginView.swift`                 |
| `app/office/page.js` tabs              | `Office/OfficeRootView.swift` + tab views |
| `app/office/email/page.js`             | `Office/EmailView.swift`               |
| `app/admin/page.js`                    | `Admin/AdminView.swift`                |
| Bootstrap `Card`                       | `DashboardCard` component              |
| `react-icons/fa`                       | SF Symbols                             |
| `useRouter`                            | `AppState.activeRoot` enum             |

## Notes

- All data is **mocked in-memory** — same as the web app's seeded fixtures (emails, meetings, notes, etc.). There is no backend wired up; that's left as an exercise (see `AppState` for natural injection points).
- Designed for iPhone primarily; iPad uses the same layout with broader columns.
- Dark mode supported (driven by system).
