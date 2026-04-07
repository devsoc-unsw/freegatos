# Freegatos

A training project to onboard new contributors to the **freerooms-mobile** codebase. Same architecture, same conventions, same tooling — but instead of university rooms, we're building an app about **cats**.

## What You'll Learn

- Modular Swift Package architecture (local SPM packages)
- The VISOR package (`@Stubbable` protocol mocking)
- Protocol-oriented networking with generic decodable loaders
- Offline-first data loading (bundled JSON → live API)
- SwiftUI views with working Previews
- `@Observable` ViewModels with proper error handling
- Unit testing ViewModels with stubbed dependencies

**Timeline:** 1–2 weeks

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Xcode | 16.0+ | Mac App Store |
| swiftformat | latest | `brew install swiftformat` |
| swiftlint | latest | `brew install swiftlint` |

You will also need a free API key from [The Cat API](https://thecatapi.com/signup).

### Concepts You Should Understand

Before starting, make sure you're comfortable with the following. You don't need to be an expert — but you should know what these are and why they matter. Use the linked resources if any of these are unfamiliar.

| Concept | Why it matters in this project | Resource |
|---------|-------------------------------|----------|
| **Protocols** | Every layer communicates through protocol abstractions (`HTTPClient`, `CatLoader`, etc.) | [Swift docs — Protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/) |
| **Generics** | `NetworkCodableLoader<T>` and `JSONLoader<T>` are generic over any `Codable` type | [Swift docs — Generics](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/) |
| **Dependency Injection** | ViewModels receive their loaders via init — never create them internally. This is what makes testing and previews possible | [Article — DI in Swift](https://www.avanderlee.com/swift/dependency-injection/) |
| **Unit Testing** | Every ViewModel and loader is tested by injecting stubs/mocks for its dependencies | [Apple docs — XCTest](https://developer.apple.com/documentation/xctest) |
| **Swift Concurrency** | `async/await`, `Sendable`, `@MainActor`, `@concurrent` — used throughout the networking and ViewModel layers | [Swift docs — Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) |
| **Result type** | All loaders return `Result<T, Error>` instead of throwing — explicit error handling over implicit | [Swift docs — Result](https://developer.apple.com/documentation/swift/result) |
| **SwiftUI & MVVM** | Views observe ViewModels via `@Observable`. Views are stateless; ViewModels own the state | [Apple tutorial — SwiftUI](https://developer.apple.com/tutorials/swiftui) |
| **Swift Package Manager** | The project is split into local packages. Understanding targets, products, and dependencies is essential | [Apple docs — SPM](https://developer.apple.com/documentation/xcode/swift-packages) |

---

## Getting Started

```bash
# 1. Clone the repo
git clone <repo-url>
cd freegato

# 2. Install git hooks (runs swiftformat + swiftlint on commit/push)
./install-hooks.sh

# 3. Open in Xcode
open FreegatosWorkspace.xcworkspace
```

### API Key Setup

1. Get your free key from https://thecatapi.com/signup
2. In the Xcode project, create a file (e.g. `Secrets.swift`) that is **not committed to git** (add it to `.gitignore`)
3. Store your key there and reference it when constructing API requests:

```swift
enum Secrets {
    static let catAPIKey = "your-api-key-here"
}
```

> Alternatively, you can use an Xcode scheme environment variable or a `.xcconfig` file — just make sure the key never gets committed.

---

## Ground Rules

### AI Usage Policy

- **Do NOT use AI to write code.** The purpose of this project is to learn by doing. Writing the code yourself is how you build real understanding of the architecture, Swift concurrency, and SwiftUI.
- **DO use AI for learning.** Asking AI to explain concepts, clarify documentation, debug error messages, or help you understand *why* something works a certain way is encouraged.

### Git Discipline

- **Commit after every completed feature.** Each meaningful piece of work should be its own commit with a clear, descriptive message.
- Follow conventional commit style, e.g.:
  - `feat: implement HTTPClient protocol and URLSessionHTTPClient`
  - `feat: add Cat model and DecodableCat mapping`
  - `test: add unit tests for NetworkCodableLoader`
  - `fix: handle empty response in APICatLoader`
- Do not bundle multiple unrelated changes into a single commit.
- Push regularly so your progress is visible for code review.

---

## Architecture

Freegato follows the same layered architecture as freerooms-mobile:

```
View → ViewModel → Loader (Service Layer)
                      ├── JSONCatLoader   (offline bundled JSON)
                      └── APICatLoader    (live network call)
```

### Package Structure

```
freegato/
├── freegato.xcodeproj
├── freegato/                  ← App target (entry point, composition root)
│   ├── freegatoApp.swift
│   └── ContentView.swift
├── Networking/                ← Generic HTTP client & codable loader
│   ├── Package.swift
│   ├── Sources/Networking/
│   └── Tests/NetworkingTests/
└── Cats/                      ← Cat models, services, view models, views
    ├── Package.swift
    ├── Sources/
    │   ├── CatModels/
    │   ├── CatServices/
    │   └── CatViews/
    └── Tests/
        └── CatsTests/
```

---

## Stages

### Stage 1 — Networking Package

**Goal:** Build a generic, reusable networking layer identical to freerooms-mobile's.

> **Reference:** Study these files in freerooms-mobile before starting:
> - `ios/Networking/Sources/Networking/HTTPClient.swift`
> - `ios/Networking/Sources/Networking/URLSessionHTTPClient.swift`
> - `ios/Networking/Sources/Networking/NetworkCodableLoader.swift`

#### What to implement

| File | Description |
|------|-------------|
| `HTTPClient.swift` | Protocol defining `func get(from url: URL) async -> Result<(Data, HTTPURLResponse), Error>` |
| `URLSessionHTTPClient.swift` | Concrete `HTTPClient` backed by `URLSession`. Includes `HTTPSession` protocol so `URLSession` can be swapped in tests. |
| `NetworkCodableLoader.swift` | Generic `NetworkCodableLoader<T: Codable>` that takes an `HTTPClient` + `URL`, calls `get`, and decodes the response into `T`. Returns `.failure(.connectivity)` or `.failure(.invalidData)` on error. |

#### Key patterns to learn

- Protocol-based abstraction (`HTTPClient`, `HTTPSession`)
- Generic `Result` types aliased for clarity
- `@concurrent` for off-main-actor work
- `Sendable` conformance for concurrency safety

#### Tests

- `HTTPClientTests` — verify `URLSessionHTTPClient` maps responses correctly
- `NetworkCodableLoaderTests` — use a stub `HTTPClient` to test decoding and error paths

---

### Stage 2 — Cat Models, ViewModel & View

**Goal:** Build the main cat browsing page using [The Cat API](https://thecatapi.com/).

> **Reference:** Study these files in freerooms-mobile before starting:
> - `ios/Rooms/Sources/RoomModels/Room.swift` — domain model pattern
> - `ios/Rooms/Sources/RoomViewModels/RoomViewModel.swift` — ViewModel protocol + `@Observable` class
> - `ios/Rooms/Sources/RoomServices/LiveRoomLoader.swift` — loader protocol with `@Stubbable`

#### Models (`CatModels` target)

```swift
struct Cat: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let breed: String
    let imageURL: URL
    let description: String
    let temperament: String
    let origin: String
    let lifeSpan: String
}
```

Also define a `DecodableCat` struct that maps the raw API JSON (with different key names) to the clean `Cat` domain model — same pattern as `DecodableRoom` → `Room` in freerooms-mobile.

#### Service Layer (`CatServices` target)

In this stage, focus on `CatLoader`, `CatLoaderError`, and `APICatLoader`. The `JSONCatLoader` and `LiveCatLoader` will be built in Stage 4 when you implement the offline-first pattern.

| Component | Description |
|-----------|-------------|
| `CatLoader` protocol | `func fetch() async -> Result<[Cat], CatLoaderError>` — annotated with `@Stubbable` from VISOR |
| `CatLoaderError` | `.connectivity`, `.noDataAvailable`, `.malformedJSON`, `.fileNotFound` |
| `APICatLoader` | Uses `NetworkCodableLoader` to fetch from The Cat API, maps `DecodableCat` → `Cat` |

#### ViewModel (`CatViews` or `CatViewModels` target)

```swift
@Stubbable
@MainActor
protocol CatViewModel {
    var cats: [Cat] { get }
    var isLoading: Bool { get }
    var errorMessage: AlertError? { get set }
    func onAppear() async
    func reload() async
}
```

- `LiveCatViewModel` — `@Observable` class conforming to `CatViewModel`
- Calls `CatLoader.fetch()` on appear
- Manages `isLoading` and `errorMessage` state
- Supports pull-to-refresh via `reload()`

#### View

| View | Description |
|------|-------------|
| `CatListView` | Displays cats in a scrollable `List`. Each row shows the cat image, name, breed, and a short description. |
| `CatCardView` | Alternative layout displaying cats as cards in a `LazyVGrid`. |
| `CatDetailView` | Tapping a cat navigates to a detail page with full info (image, temperament, origin, lifespan, description). |
| Toggle | A control (e.g. `Picker` or toolbar button) to switch between list and card layout. |

#### Previews

Every view **must** have a working SwiftUI Preview using stubbed data. Use VISOR's generated stubs for the ViewModel protocol so previews don't hit the network.

---

### Stage 3 — Favourite Cats

**Goal:** Add a bookmark/favourite feature.

> **Reference:** This stage has no direct equivalent in freerooms-mobile — it's your chance to apply the patterns you've learned independently.

#### What to implement

| Component | Description |
|-----------|-------------|
| `FavouriteCatStore` protocol | `func add(_ cat: Cat)`, `func remove(_ cat: Cat)`, `func fetchAll() -> [Cat]`, `func isFavourite(_ cat: Cat) -> Bool` — annotated with `@Stubbable` |
| `LiveFavouriteCatStore` | Backed by `UserDefaults` or a local JSON file for simplicity (SwiftData is also acceptable). |
| `FavouriteCatsViewModel` | `@Observable` class that exposes `favouriteCats: [Cat]` and `toggleFavourite(_ cat:)` |
| `FavouriteCatsView` | A dedicated tab/page showing only bookmarked cats. Reuses `CatListView` / `CatCardView`. |
| Integration | Add a bookmark button (heart icon) to `CatListView` rows and `CatDetailView`. |

#### Tests

- `FavouriteCatStoreTests` — verify add, remove, fetchAll, isFavourite
- `FavouriteCatsViewModelTests` — verify toggle and state updates with a stubbed store

---

### Stage 4 — Offline JSON Seed & Two-State Loader

**Goal:** Bundle a static `CatsSeed.json` so the app works offline on first launch, then transition to live API data. This mirrors freerooms-mobile's `LiveRoomLoader` pattern.

> **Reference:** Study these files in freerooms-mobile before starting:
> - `ios/Persistence/Sources/Persistence/LiveJSONLoader.swift` — generic `JSONLoader` protocol and implementation
> - `ios/Rooms/Sources/RoomServices/LiveJSONRoomLoader.swift` — how seed JSON is loaded and mapped to domain models
> - `ios/Rooms/Sources/RoomServices/LiveRoomLoader.swift` — the two-state composition pattern (JSON on first launch → live data after)

#### What to implement

| Component | Description |
|-----------|-------------|
| `CatsSeed.json` | Already provided in `Cats/Sources/CatServices/Resources/`. Contains 20 real cat breeds from The Cat API. |
| `JSONCatLoader` | Uses the generic `JSONLoader` (from a shared `Persistence`-style utility or inline) to decode `CatsSeed.json` into `[DecodableCat]`, then maps to `[Cat]`. |
| `LiveCatLoader` | The composition loader. On first launch (no cached data), loads from `JSONCatLoader`. On subsequent launches, loads from the API via `APICatLoader`. Uses a flag (e.g. `UserDefaults`) to track state. Update your ViewModel to use `LiveCatLoader` instead of `APICatLoader` directly. |

#### Two-state loading pattern

```
First launch:
  JSONCatLoader (bundled file) → [Cat] ✓
  Cache flag = true

Subsequent launches:
  APICatLoader (network) → [Cat] ✓
  Fallback to cached/seed data on failure
```

#### Tests

- `JSONCatLoaderTests` — verify loading and decoding from a test JSON fixture
- `LiveCatLoaderTests` — verify it uses JSON loader on first load, API loader on subsequent loads (stub both dependencies)

---

### Stage 5 — Quality & Best Practices

**Goal:** Ensure production-quality code across the project.

#### Error Handling

- Every loader returns `Result<T, SomeError>` — never force-unwraps or crashes on bad data
- ViewModels surface errors via an `AlertError` (or similar) observable property
- Views display user-friendly error states (not raw error messages)
- Network failures show a retry option

#### Previews

- **Every** SwiftUI view must have a `#Preview` that compiles and renders
- Use VISOR-generated stubs (`CatViewModelStub`, etc.) to inject fake data
- Previews must cover: loading state, loaded state, error state, empty state

#### Unit Tests

| What to test | Approach |
|--------------|----------|
| `NetworkCodableLoader` | Stub `HTTPClient`, verify decoding + error mapping |
| `JSONCatLoader` | Use a test fixture JSON file |
| `LiveCatLoader` | Stub both `JSONCatLoader` and `APICatLoader` |
| `LiveCatViewModel` | Stub `CatLoader`, verify state transitions (loading → loaded, loading → error) |
| `FavouriteCatsViewModel` | Stub `FavouriteCatStore`, verify toggle + list updates |

#### Code Style

- Run `swiftformat` and `swiftlint` (enforced by git hooks already set up)
- Follow the same file/folder naming conventions as freerooms-mobile
- Use `swift-tools-version: 6.2`, `platforms: [.iOS(.v17)]`
- Apply the standard `SwiftSetting` defaults:
  ```swift
  .defaultIsolation(MainActor.self)
  .enableUpcomingFeature("NonisolatedNonsendingByDefault")
  .enableUpcomingFeature("InferIsolatedConformances")
  ```

---

### Stage 6 - VISOR

**Goal:** Use the VISOR package to reduce boilerplate code and streamline UI state

#### Refactor
- Where possible, leverage the VISOR package macros to reduce boilerplate
- Use VISOR UI macros to modernize your view models and views 

## API Reference

**The Cat API** — https://thecatapi.com/

| Endpoint | Description |
|----------|-------------|
| `GET /v1/breeds` | Returns a list of cat breeds with images, descriptions, temperaments |
| `GET /v1/images/search?breed_ids={id}` | Returns images for a specific breed |

A free API key can be obtained at https://thecatapi.com/signup. The key is passed via the `x-api-key` header.

---

## Dependencies

| Package | Source | Purpose |
|---------|--------|---------|
| VISOR | `https://github.com/avdn-dev/VISOR.git` (from `8.0.0`) | `@Stubbable` macro for generating protocol stubs used in tests and previews |

---

## Definition of Done (per stage)

- [ ] Code compiles with zero warnings
- [ ] All SwiftUI Previews render correctly
- [ ] Unit tests pass
- [ ] `swiftformat` and `swiftlint` pass (via git hooks)
- [ ] Each feature has its own git commit with a clear message
- [ ] Code reviewed by a team lead

---

## Useful Resources

| Topic | Link |
|-------|------|
| freerooms-mobile repo | Study the `ios/` directory — this project mirrors its architecture |
| VISOR package | [github.com/avdn-dev/VISOR](https://github.com/avdn-dev/VISOR) — `@Stubbable` macro docs |
| The Cat API docs | [docs.thecatapi.com](https://docs.thecatapi.com/) |
| Swift concurrency | [docs.swift.org/swift-book — Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) |
| SwiftUI tutorials | [developer.apple.com/tutorials/swiftui](https://developer.apple.com/tutorials/swiftui) |
| Swift Package Manager | [developer.apple.com/documentation/xcode/swift-packages](https://developer.apple.com/documentation/xcode/swift-packages) |
| `@Observable` macro | [developer.apple.com/documentation/observation](https://developer.apple.com/documentation/observation) |
