# Windows: i3-like setup

[GlazeWM](https://github.com/glzr-io/glazewm) as the tiling WM (bindings ported
from `.config/i3/config`, `$mod` = `alt`) and
[Zebar](https://github.com/glzr-io/zebar) as an i3bar-style bar with the gruvbox
colours.

```
.glzr/glazewm/config.yaml   -> %USERPROFILE%\.glzr\glazewm\config.yaml
.glzr/zebar/settings.json   -> %USERPROFILE%\.glzr\zebar\settings.json
.glzr/zebar/i3bar/          -> %USERPROFILE%\.glzr\zebar\i3bar\
```

## Install without admin

The releases only ship MSI installers, which need admin. An administrative
extract unpacks them into a user folder instead:

```powershell
# GlazeWM (standalone-glazewm-<ver>-x64.msi from the releases page)
msiexec /a standalone-glazewm-x64.msi /qn TARGETDIR="$env:TEMP\gwm"
Copy-Item "$env:TEMP\gwm\PFiles64\glzr.io\GlazeWM" "$env:LOCALAPPDATA\Programs\" -Recurse

# Zebar (zebar-<ver>-opt1-x64.msi). Keep the _up_\_up_\resources layout as is.
msiexec /a zebar-x64.msi /qn TARGETDIR="$env:TEMP\zebar"
Copy-Item "$env:TEMP\zebar\PFiles\glzr.io\Zebar" "$env:LOCALAPPDATA\Programs\" -Recurse

# Configs
Copy-Item .glzr "$env:USERPROFILE\" -Recurse -Force
```

GlazeWM starts Zebar itself (`startup_commands`). To start GlazeWM at login,
put a shortcut to `%LOCALAPPDATA%\Programs\GlazeWM\glazewm.exe start` in
`shell:startup`.

## Differences from i3

- No stacking/tabbed layouts, focus parent/child or urgent focus.
- No scratchpad: `alt+shift+plus` minimizes instead.
- `alt+shift+q` redraws windows (i3: restart).
- `alt+tab` replaces the Windows app switcher (workspace back_and_forth).
- `alt+p` / `alt+o` (rofi) are unbound.
- Workspaces are GlazeWM's own, not Windows virtual desktops; stay on one
  Windows desktop.
