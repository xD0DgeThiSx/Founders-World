# Founder's World Roadmap

## Phase 0: Foundation

- Establish repository structure
- Document product and technical direction
- Define Roblox service boundaries
- Create bootstrap entry points
- Prepare shared contracts and config locations

## Phase 1: Core Runtime

- Implement boot pipeline for server and client
- Add service registry pattern
- Add system registry pattern
- Define remote event and remote function conventions
- Add structured logging and diagnostics hooks

## Phase 2: Playable Graybox Expansion

- Expand venue generation into room-based layouts
- Add config-driven props, signs, and media panels
- Distinguish the five founder venues with unique themes
- Seed founder and VIP configuration for future systems
- Keep runtime generation compatible with Rojo workflows

## Phase 3: Player Systems And Interaction

- Track player sessions and server-owned role state
- Add config-driven remote event and remote function registry
- Centralize prompts and interaction validation
- Add anti-spam teleport rules and safe arrival handling
- Build the first HUD, role badge, and notification shell

## Phase 4: World Space And Core Zones

- Expand Founder’s Plaza into a central hub with signage and circulation
- Add dedicated physical districts for current and future features
- Space active venues for top-down readability and future growth
- Add placeholder expansion markers, roads, and arrival pads
- Keep the macro layout data-driven in shared config

## Phase 5: Player Architecture

- Add player session lifecycle handling
- Define profile/data interfaces
- Establish permission and entitlement boundaries
- Add player state replication strategy

### Phase 5 Build Slice

- Added `ProfileConfig` for default profile shape, role permissions, entitlements, stats, and preferences
- Added `PlayerProfileService` as the in-memory profile/data boundary before datastore persistence
- Connected `PlayerSessionService` to profile creation, cleanup, and client-safe profile payloads
- Added profile replication remotes through `RemoteConfig` and `RemoteRegistryService`
- Connected teleport and interaction stats to profile state
- Switched founder action checks to the profile permission boundary

## Phase 6: World Architecture

- Define world loading/content streaming strategy
- Establish interactive object conventions
- Create content authoring guidelines for map elements
- Separate static art from runtime-driven world state

## Phase 7: UI Architecture

- Build client app shell
- Define screen routing/state ownership
- Create reusable component conventions
- Connect presentation state to replicated game state

## Phase 8: Feature Production

- Implement the first gameplay loop
- Add onboarding flow
- Add progression hooks
- Add telemetry events and balancing checkpoints

## Phase 9: Live Readiness

- Add datastore-backed persistence
- Add analytics and moderation support hooks
- Build admin/support tooling surfaces
- Establish content rollout and rollback practices

## Delivery Notes

- Do not skip foundational runtime conventions.
- Validate interfaces before content volume increases.
- Keep each new feature behind documented ownership boundaries.
