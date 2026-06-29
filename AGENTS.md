# Dice Days App – Development Guide

## Stack
- **Flutter/Dart** (iOS, Android, Web)
- **Supabase** (Postgres, Auth, Realtime)
- **BoardGameGeek XML API** for game metadata

## Commands
- `flutter run -d chrome` – run web dev server
- `flutter test` – run all tests
- `flutter analyze` – static analysis
- `flutter build web` – production web build

## Project Structure
- `lib/` – all Dart source code
  - `models/` – data models
  - `services/` – Supabase client, BGG API, etc.
  - `screens/` – full-page screens
  - `widgets/` – reusable components
  - `constants/` – colors, theme, config
- `SPEC.md` – full product specification (authoritative)

## Key Design Decisions
- Accent color: Tan-Gold #B8A082
- No account required – event code + nickname
- Sweet Spot indicator: progress ring, flame icon above 100%
- Swipe-based inbox triage with "train car" pattern
- See SPEC.md for full details
