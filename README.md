# Founder's World

Founder's World is a Roblox experience scaffolded for long-term maintainability, clean team collaboration, and safe gameplay iteration.

This repository now contains the Phase 2 playable graybox expansion for Founder's World. The project keeps the original runtime-generation architecture, but the world has been upgraded into a more distinct, room-driven playable layout with venue-specific graybox detail.

## Current Scope

- High-level product and engineering documentation
- Rojo-compatible Roblox source tree
- Server, shared, client, UI, world, and audio boundaries
- Config-driven graybox world generation
- Teleport, spawn, and door interaction systems
- Venue room, prop, sign, and media panel generation
- VIP and founder display seed configuration
- Player session tracking and role sync
- Remote-driven client notification and venue navigation shell

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

## Phase 2 Graybox Features

- Stromblad Estate
- Girls Hangout
- Founder Lounge
- ContentForge Studio
- BO6 Gaming Lounge
- Hub-and-spoke teleport navigation
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

## Next Step

Use `ROADMAP.md` as the implementation sequence and `ARCHITECTURE.md` as the engineering reference as this graybox world evolves into persistent systems, authored art, and full gameplay loops.
