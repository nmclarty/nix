# *nix*
### welcome to my system configuration repo!

Hi!, I'm new to NixOS (and its associated tools) so you probably shouldn't use this as anything like a template to be followed.

However, feel free to take inspiration or give suggestions on how I could make something better!

### Structure
This flake uses the (opinionated) library [Blueprint](https://github.com/numtide/blueprint) for organizing everything since I wanted to avoid boilerplate. It mostly follows the structure as specified in their docs, save for some extra module types.

```
.
├── hosts # per host configurations
│   └── brittlehollow
│       ├── containers # quadlet containers for services
│       └── users # per system user config (imports main home manager module)
├── lib # helper functions
└── modules 
    ├── darwin # macos system config
    ├── disko # disk layouts
    ├── home # home manager config
    │   └── programs # per program config (e.g. when more than a few lines)
    ├── nixos # nixos system config
    ├── server # server specific config
    └── shared # shared config between darwin and nixos
```

---
 
### Dependencies
Key flakes:
- nix-private - sops-nix managed secrets and other config that I'd rather not have public
- py_motd - A custom MOTD app that I made to learn more about Python and Nix packaging
