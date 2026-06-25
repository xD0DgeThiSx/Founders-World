# Founder's World

Founder's World is a Roblox experience scaffolded for long-term maintainability, clean team collaboration, and safe gameplay iteration.

This repository now contains the Phase 5 player architecture slice for Founder's World. The Phase 4 expanded graybox world is preserved, and the project now has a clean server-owned profile boundary for future persistence, entitlements, stats, and progression.

## Current Scope

- High-level product and engineering documentation
- Rojo-compatible Roblox source tree
- Server, shared, client, UI, world, and audio boundaries
- Config-driven graybox world generation
- Teleport, spawn, and door interaction systems
- Venue room, prop, sign, and media panel generation
- VIP and founder display seed configuration
- Player session tracking and role sync
- Player profile defaults, permissions, entitlements, and stats
- Remote-driven client notification, profile sync, and venue navigation shell
- Config-driven plaza, zone, and road layout
- Placeholder expansion districts for future major features

## Project Layout

```text
Founders-World/
|-- ARCHITECTURE.md
|-- MASTER_SPEC.md
|-- README.md
|-- ROADMAP.md
|-- default.project.json
`-- src/
    |-- ReplicatedStorage/
    |   |-- Config/
    |   |-- Packages/
    |   |-- Remotes/
    |   `-- Shared/
    |-- ServerScriptService/
    |   |-- Services/
    |   |-- Systems/
    |   `-- Bootstrap.server.lua
    |-- SoundService/
    |   |-- Music/
    |   `-- SFX/
    |-- StarterGui/
    |   `-- App/
    |-- StarterPlayer/
    |   |-- StarterCharacterScripts/
    |   `-- StarterPlayerScripts/
    `-- Workspace/
        |-- Interactives/
        `-- Map/
```

## Architectural Principles

- Server authoritative by default
- Shared contracts before shared behavior
- Thin bootstraps, modular systems
- Clear separation between product spec and implementation
- Build for testability, observability, and content iteration

## Recommended Workflow

1. Open the project with Rojo-compatible tooling.
2. Align on `MASTER_SPEC.md` before building gameplay.
3. Add systems incrementally behind clear interfaces.
4. Keep shared code deterministic and dependency-light.

## Phase 5 Player Architecture

- `ProfileConfig` defines the default player profile shape, permissions, entitlements, stats, and preferences
- `PlayerProfileService` owns in-memory player profiles before datastore persistence is introduced
- `PlayerSessionService` now creates, cleans up, and exposes profile payloads alongside role state
- `RemoteConfig` and `RemoteRegistryService` now support profile replication through `SyncPlayerProfile` and `RequestPlayerProfile`
- `TeleportService` and `InteractionService` increment player profile stats through the profile boundary
- Founder actions now check the permission boundary instead of hardcoding role-only logic

## Phase 4 World Features

- Stromblad Estate
- Girls Hangout
- Founder Lounge
- ContentForge Studio
- BO6 Gaming Lounge
- Water Park placeholder zone
- Outdoor Mall placeholder zone
- Drive-In Theater placeholder zone
- Offroad Track placeholder zone
- Future Amusement Park placeholder zone
- Founder’s Plaza as the central travel and spawn hub
- Roads and walkways between major areas
- Interactive doors
- Config-defined room layouts
- Themed labeled props and signage
- Distinct media panel styles for photo, Spotify, Twitch, and YouTube
- Pool, hot tub, and slide placeholders
- Spawn pads and venue signage
- Player roles: Founder, VIP, Guest
- Main HUD, role badge, venue navigation placeholder, and toast notifications

## Phase 3 Systems

- `PlayerSessionService` tracks join/leave state and founder/VIP roles
- `RemoteRegistryService` creates config-driven remotes at runtime
- `TeleportService` handles safe teleports with cooldowns
- `InteractionService` centralizes prompt logic and future role-gated hooks
- `AppShell` provides the initial client HUD layer

## Phase 4 Layout Layer

- `WorldConfig.Zones` defines all active and future districts
- `WorldConfig.Roads` defines walkable connections between destinations
- `WorldBuilderService` now generates plaza, zone platforms, roads, overhead signs, and expansion markers
- Every major area has a physical placeholder footprint ready for future systems

## Next Step

Validate Phase 5 in Roblox Studio by confirming that role sync, profile sync, teleport stats, interaction stats, and founder permission checks work before moving into Phase 6 world architecture or Phase 8 gameplay production.
