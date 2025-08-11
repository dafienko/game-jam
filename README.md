## Setup

### Initial installation

1. Install [wally](https://wally.run/install)
2. Install [rojo](https://rojo.space/docs/v7/getting-started/installation/)
3. Install [wally-package-types](https://github.com/JohnnyMorganz/wally-package-types/releases)
4. Install [rojo server (or vscode plugin) and rojo studio plugin](https://rojo.space/docs/v7/getting-started/installation/)

### First-time setup or after you add a new package

1. Run `wally install`
2. Run `rojo sourcemap default.project.json --output sourcemap.json`
3. Run `wally-package-types --sourcemap sourcemap.json Packages/`

### Every time you start developing

1. Start rojo server
2. Connect plugin to server in studio
