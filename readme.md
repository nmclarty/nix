# *nix*
### welcome to my system configuration repo!

Hi!, I'm new to NixOS (and its associated tools) so you probably shouldn't use this as anything like a template.

However, feel free to take inspiration or give suggestions on how I could make something better!

### Structure
This flake uses the (opinionated) library [Blueprint](https://github.com/numtide/blueprint) for organizing everything since I wanted to avoid boilerplate. It mostly follows the structure as specified in their docs, save for some extra module types.
```
.
├── hosts # individual systems
│   └── brittlehollow
│       ├── *.nix # per-system config (such as ups settings)
│       ├── users # per-system users (also imports modules/home)
│       └── containers # per-system containers
├── lib # helper functions
└── modules
    ├── darwin # MacOS system
    ├── disko # disk layouts
    ├── extra # extra modules (to be imported as-needed)
    ├── home # home manager
    │   └── programs # per program (e.g. when more than a few lines)
    ├── nixos # NixOS system
    └── server # NixOS server
```
 
### Dependencies
Key flakes:
- nix-private - sops-nix managed secrets and other config that I'd rather not have public
- py_motd - A custom MOTD app that I made to learn more about Python and Nix packaging
