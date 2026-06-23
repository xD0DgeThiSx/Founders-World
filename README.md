# Founder's World

Founder's World is a Roblox experience scaffolded for long-term maintainability, clean team collaboration, and safe gameplay iteration.

This repository now contains the Phase 1 playable prototype world structure for Founder's World. The focus is still on architectural quality and expandable systems, but the map is now explorable with placeholder geometry and foundational interaction loops.

## Current Scope

- High-level product and engineering documentation
- Rojo-compatible Roblox source tree
- Server, shared, client, UI, world, and audio boundaries
- Playable prototype world generation
- Teleport, spawn, and door interaction systems
- Media showcase frameworks for future content integrations

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

## Phase 1 Prototype Features

- Stromblad Estate
- Girls Hangout
- Founder Lounge
- ContentForge Studio
- BO6 Gaming Lounge
- Hub-and-spoke teleport navigation
- Interactive doors
- Photo slideshow placeholders
- Spotify station placeholders
- Twitch wall placeholders
- YouTube showcase placeholders
- Spawn pads and venue signage

## Next Step

Use `ROADMAP.md` as the implementation sequence and `ARCHITECTURE.md` as the engineering reference as this placeholder prototype evolves into full gameplay systems.
