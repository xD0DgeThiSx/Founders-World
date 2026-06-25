# Founder's World Architecture

## Overview

Founder's World uses a layered Roblox architecture designed for safe multiplayer behavior and gradual feature expansion.

The repository is organized around Roblox service boundaries so the codebase mirrors the runtime environment:

- `ServerScriptService` owns authoritative game orchestration.
- `ReplicatedStorage` owns shared contracts, configuration, and replicated interfaces.
- `StarterGui` owns client-facing presentation shells.
- `StarterPlayer` owns local runtime startup and character-local behavior.
- `Workspace` owns world content containers.
- `SoundService` owns audio categorization and playback organization.

## Architectural Layers

### 1. Bootstrap Layer

Bootstrap scripts are the only files that should directly coordinate startup order. They load registries, initialize infrastructure, and hand control to services or client controllers.

### 2. Service Layer

Services represent durable, cross-feature capabilities. Examples for later phases may include player sessions, data, matchmaking, economy, or telemetry. Services should have stable APIs and minimal knowledge of presentation details.

Phase 5 keeps server-owned player state split by responsibility:

- `PlayerSessionService` owns per-player lifecycle, role resolution, and session lookups.
- `PlayerProfileService` owns in-memory profile defaults, permission helpers, entitlements, and player stats.
- `RemoteRegistryService` owns runtime remote creation from config.
- `TeleportService` owns safe travel rules and cooldowns.
- `InteractionService` owns prompt validation and interaction routing.

### 3. System Layer

Systems represent feature runtime behavior. Systems can depend on services and shared contracts, but they should avoid owning broad platform concerns.

### 4. Shared Layer

Shared code contains contracts, enums, utility modules, schema definitions, and configuration that both client and server can safely consume. Shared code should remain conservative because any unnecessary replication becomes long-term cost.

In Phase 2, `WorldConfig.lua` becomes the main authoring surface for venue layouts. Rooms, props, media panels, signs, and VIP seed data all live in shared config so the runtime builder can stay generic.

Phase 5 adds `ProfileConfig.lua` as the source of truth for default player profile shape, role permissions, and entitlement defaults. Persistence is intentionally deferred behind the profile service boundary.

### 5. Presentation Layer

Client app and UI controllers should translate replicated state into visuals and local input behavior. They should not decide authoritative outcomes.

The first UI shell is still lightweight, but it now renders role state, notifications, venue navigation, and can consume profile state from authoritative server remotes.

### 6. Content Layer

World assets and audio structures should be organized so designers can expand content safely without scattering unrelated assets across top-level service trees.

Phase 4 promotes macro layout data into shared config. Plaza layout, zone footprints, roads, expansion markers, and destination metadata are now first-class authored data instead of ad hoc world placement.

## Folder Responsibilities

### `src/ServerScriptService`

- `Bootstrap.server.lua`: server startup entry point
- `Services/`: long-lived server capabilities
- `Systems/`: feature-level runtime systems
- `Services/InteractionService.lua`: central prompt routing and validation
- `Services/PlayerProfileService.lua`: in-memory profile, entitlement, permission, and stats boundary
- `Services/PlayerSessionService.lua`: role-aware per-player lifecycle state
- `Services/RemoteRegistryService.lua`: config-driven remote initialization
- `Services/TeleportService.lua`: safe teleport and arrival logic
- `Services/WorldBuilderService.lua`: macro and micro world generation for plaza, zones, roads, venues, and placeholder districts

### `src/ReplicatedStorage`

- `Shared/`: contracts, utilities, enums, types
- `Remotes/`: remote event/function containers and definitions
- `Config/`: tunable data and non-secret constants
- `Packages/`: external packages or vendored dependencies when adopted
- `Shared/Config/ProfileConfig.lua`: source of truth for default profile shape and role permissions
- `Shared/Config/WorldConfig.lua`: source of truth for generated venue layouts
- `Shared/Config/RemoteConfig.lua`: source of truth for runtime remotes
- `Shared/Config/WorldConfig.lua`: now also defines zones, roads, hub signage positions, and future expansion metadata

### `src/StarterGui`

- `App/`: top-level client UI shell and screen organization
- `App/AppShell.lua`: lightweight HUD and navigation builder
- `App/NotificationController.lua`: toast notification presentation

### `src/StarterPlayer`

- `StarterPlayerScripts/`: local boot and client controllers
- `StarterCharacterScripts/`: character-local runtime behaviors only

### `src/Workspace`

- `Map/`: static or semi-static world composition roots
- `Interactives/`: runtime-relevant placeables and tagged interactive content

The current world is still generated at runtime, but it is now structured as a configurable graybox map rather than a single shell per venue.

### `src/SoundService`

- `Music/`: background and ambient music grouping
- `SFX/`: moment-to-moment sound effect grouping

## Dependency Rules

- Server modules may depend on shared modules.
- Client modules may depend on shared modules.
- Shared modules must not depend on server or client modules.
- Systems may depend on services, but cross-system coupling should be minimized.
- UI code must not directly own economy, combat, persistence, or entitlement decisions.
- World generation code should consume config data, not embed venue-specific authoring decisions inline.
- Macro layout data should stay declarative so zone spacing, roads, and future districts can evolve without rewriting service logic.
- Player persistence should enter through `PlayerProfileService` or a future data adapter, not directly through feature systems.

## Remote Communication Rules

- All remotes should be declared intentionally under `ReplicatedStorage/Remotes`.
- Remote naming should express domain and intent.
- Validation must happen on the server even when clients pre-validate locally.
- Avoid generic catch-all remotes.
- Client menu actions should route through remote functions or events instead of directly mutating world state.
- Replicated player profile payloads must be safe for clients and exclude server-only data.

## Naming Conventions

- Use clear singular or plural folder names based on responsibility.
- Name modules by role, not by implementation detail.
- Keep bootstrap files obvious with `.server.lua` and `.client.lua` suffixes where appropriate.

## Future Evolution

As gameplay begins, this architecture can safely absorb:

- domain-specific services
- replicated state containers
- UI controllers and view models
- interaction systems
- persistence adapters
- analytics hooks
- entitlement checks backed by the VIP seed config

The goal is to let features grow without flattening the codebase into a single shared dependency web.
