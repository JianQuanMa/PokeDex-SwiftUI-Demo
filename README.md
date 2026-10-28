# PokeDex

A small iOS app for browsing Pokémon, built as a portfolio piece to demo architecture,
concurrency, and testing practices in an interview setting — not a production app.

Data comes from the free, no-auth [PokeAPI](https://pokeapi.co).

## Stack

- **SwiftUI** for the UI, **Swift Concurrency** (`async`/`await`, `actor`) for everything
  asynchronous — no completion handlers, no Combine.
- **MVVM**: `@Observable` (the Observation framework, not `ObservableObject`) view models,
  one per screen, holding zero UIKit/SwiftUI imports' worth of business logic.
- **Protocol-oriented dependency injection**: every cross-layer dependency is a protocol
  (`APIClientProtocol`, `PokemonRepositoryProtocol`, `FavoritesStoring`), injected through
  initializers from one composition root (`AppContainer`). No DI framework — the object
  graph is small enough that it doesn't need one.
- **SwiftData** for local persistence (favorites), behind a `FavoritesStoring` protocol so
  view models can be tested against an in-memory fake instead of a real store.
- **Swift Testing** (`import Testing`, `@Test`, `#expect`) instead of XCTest, for the unit
  test suite.

## Architecture

```
View (SwiftUI)
   ↓ observes
ViewModel (@MainActor @Observable)
   ↓ calls async throws
Repository (actor, protocol-backed)
   ↓ calls async throws
APIClient (protocol-backed)  →  PokeAPI
   ↓
FavoritesStore (SwiftData, protocol-backed)
```

Each arrow is a protocol boundary. The view model never imports `Foundation`'s networking
types or SwiftData — it only knows about `PokemonRepositoryProtocol` and `FavoritesStoring`.
That's what makes `PokemonListViewModelTests` able to test pagination, search debouncing,
and error states without a network connection or a real database.

### Layers

- `Core/Networking` — `Endpoint` (builds URLs), `APIClientProtocol` /
  `URLSessionAPIClient` (fetch + decode), `NetworkError`.
- `Models` — `*DTO` types mirror PokeAPI's JSON exactly; `PokemonSummary` /
  `PokemonDetail` are the domain models the rest of the app actually uses. The mapping
  between them lives in `init(dto:)` extensions, so a PokeAPI schema change only touches
  one file per model.
- `Data/PokemonRepository` — an `actor` (not a `class`) because its in-memory caches are
  mutated from `async` call sites; actor isolation gives data-race safety without a manual
  lock. Fetches the full Pokémon name list once (it's small) so the list screen can page
  and search entirely client-side, and derives sprite URLs from each Pokémon's numeric ID
  instead of making one network call per row.
- `Persistence` — `FavoritePokemon` (`@Model`) + `FavoritesStore` (SwiftData-backed,
  behind `FavoritesStoring`).
- `Features/PokemonList`, `Features/PokemonDetail` — view + view model per screen.
- `Core/DI/AppContainer` — composition root; the only place concrete types get
  instantiated.

## Running it

1. Open `PokeDex.xcodeproj` in Xcode (generated from `project.yml` via
   [XcodeGen](https://github.com/yonaskolb/XcodeGen) — if you ever change `project.yml`,
   re-run `xcodegen generate`).
2. Build & run on any iOS 17+ simulator. No API key, no config needed.

To run tests: `Cmd+U` in Xcode, or:

```sh
xcodebuild -project PokeDex.xcodeproj -scheme PokeDex \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Interview walkthrough (~35 min)

A suggested script for a 30-40 minute "walk me through a project" segment.

1. **Pitch & live demo (3 min)** — Run the app. Show the list, scroll to trigger
   pagination, search for a name, open a detail screen, toggle a favorite, kill and
   relaunch the app to show the favorite persisted.

2. **Architecture overview (5 min)** — Draw (or describe) the layer diagram above. Lead
   with *why*: "every layer only depends on a protocol from the layer below it, so I can
   swap or mock any one of them without touching the others." Point at `AppContainer` as
   the one place that wires concrete types together.

3. **Networking layer (6-7 min)** — Open `Endpoint.swift` → `APIClient.swift`. Walk
   through a request: URL building, `URLSession.data(from:)` with `async`/`await`,
   `NetworkError` mapping HTTP status codes. Talking point: no completion-handler pyramid,
   errors are typed and localized.

4. **Repository + actor (5 min)** — Open `PokemonRepository.swift`. Explain why it's an
   `actor`: the detail cache dictionary is mutated from concurrent `async` call sites (two
   screens could request the same Pokémon at once), and actor isolation gives thread
   safety without `NSLock`. Mention the client-side pagination/search design decision and
   the sprite-URL-from-ID trick that avoids an N+1 network problem.

5. **MVVM + view model (6-7 min)** — Open `PokemonListViewModel.swift`. Highlight:
   `@Observable` + `@MainActor`, the `ViewState` enum driving the view's switch statement
   (loading/loaded/error, no boolean flag soup), and `scheduleSearch()` — cancelling and
   re-awaiting a `Task` with `Task.sleep` as a debounce, instead of reaching for Combine.
   This is a good spot to talk about structured concurrency and task cancellation.

6. **Persistence & testability (4-5 min)** — Open `FavoritesStore.swift` and
   `FavoritesStoring`. Explain the protocol seam: the real store talks to SwiftData, the
   test fake is a plain in-memory class. Mention `AppContainer` injecting the same
   instance into both screens so the star icon stays in sync.

7. **Tests (5 min)** — Run `Cmd+U` live. Open `PokemonListViewModelTests.swift`: show a
   mock repository returning canned data, and the search-debounce test actually awaiting
   real time to prove cancellation works. Open `FavoritesStoreTests.swift` and point out
   it uses a *real* in-memory `ModelContainer` rather than a mock — cheap enough to test
   directly, so there's no hand-written fake of SwiftData's behavior to keep in sync.

8. **Wrap-up / what's next (2-3 min)** — Be upfront about scope: this is a portfolio demo,
   not production. Things you'd add for production: Swift 6 strict concurrency mode
   (currently Swift 5 language mode with selective `async`/`await`), a disk cache for
   images beyond `AsyncImage`'s in-memory one, UI tests, and splitting `Core`/`Models`/
   `Data` into a local Swift package so they can be versioned and reused independently of
   the app target.

## Anticipated questions

- **"Why an actor for the repository instead of a class?"** — Caches are mutated from
  concurrent async call sites; an actor gives compiler-enforced exclusive access instead
  of a manual lock, and it's the Swift-native answer to "how do you prevent data races."
- **"Why not Combine for search debouncing?"** — Combine and `async`/`await` solve the
  same problem differently; cancelling a `Task` after `Task.sleep` is fewer concepts for
  what's a one-off debounce, and it's consistent with using structured concurrency
  everywhere else in the app.
- **"Why SwiftData instead of Core Data or UserDefaults?"** — UserDefaults doesn't scale
  past trivial key-value state; Core Data's older API is more boilerplate than this app's
  needs justify. SwiftData gives a typed `@Model` and queryable storage with a fraction of
  the setup.
- **"How would you scale this to more screens?"** — The protocol-seam pattern
  (`XProtocol` + concrete + mock) repeats per feature; `AppContainer` would grow `make*`
  factory methods accordingly. Past a certain size I'd split it into a Swift package per
  layer (networking, persistence, features) so build times and ownership boundaries scale
  with the team.
