# Circuit Solver — Frontend (desktop-first)

This directory contains a minimal Flutter scaffold for the Circuit Solver frontend.

Notes
- Targets desktop first. Web clients should call a backend solver service (set `SOLVER_BACKEND_URL`).
- This repository is part of a larger monorepo; the native solver code lives in the mono repo's `native_lib/` and is not copied here.

Setup
1. Install Flutter and ensure desktop support is enabled.
2. Run `flutter pub get`.
3. Generate code: see `tool/README.md`.

Development
- The editor UI and storage are stubbed. This scaffold provides a starting point for implementing canvas interactions, snapping, solver FFI, and persistence.
