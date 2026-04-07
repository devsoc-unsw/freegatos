## Stage / scope

- [ ] **1** — Networking (`ios/Networking`)
- [ ] **2** — Cats UI stack (`ios/Cats`)
- [ ] **3** — Favourites
- [ ] **4** — Offline seed / `LiveCatLoader`
- [ ] **5** — Quality / polish
- [ ] **6** — VISOR refactors
- [ ] **App** — `ios/Freegatos` wiring only
- [ ] **Repo** — docs, CI, config (no product code)

## Checklist

**Architecture**

- [ ] **View → ViewModel → Loader** — no skipping layers; ViewModels get loaders/stores only through **`init`** (no hidden `URLSession` / store construction inside the VM).
- [ ] Loaders follow **`Result<Success, Error>`** where this repo expects it; errors surface to the UI in a controlled way (not silent failures).
- [ ] **Unit tests** added or updated for behavior you changed (loaders, ViewModels, stores — match the README for your stage).
- [ ] Commits use **conventional** style (`feat:`, `fix:`, `test:`, …) and stay **one feature per commit** when practical.

## Notes (optional)

Anything else for reviewers (trade-offs, freerooms-mobile files you mirrored, follow-up work).
