Runtime-created RemoteEvents and RemoteFunctions live under this folder at play time.

The source of truth is `ReplicatedStorage/Shared/Config/RemoteConfig.lua`, and `RemoteRegistryService` creates:

- `Remotes/Events/NotifyPlayer`
- `Remotes/Events/SyncPlayerRole`
- `Remotes/Functions/RequestVenueTeleport`
- `Remotes/Functions/RequestMediaInteract`
- `Remotes/Functions/RequestFounderAction`
