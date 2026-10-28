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
