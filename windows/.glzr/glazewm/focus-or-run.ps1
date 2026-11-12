# focus-or-run.ps1 - focus an app's open window, or start the app.
#
# GlazeWM has no "focus by app" command, so a keybinding runs this script:
# it asks GlazeWM for its windows, and if one matches the process (and
# optional window class) it focuses it, switching workspace if needed.
# Pressing the key again while one is focused cycles to the next window
# of that app. With no match it starts the app.
#
# Bind it in config.yaml, e.g.:
#   - commands: ['shell-exec conhost.exe --headless powershell.exe -NoProfile
#                 -ExecutionPolicy Bypass -File %USERPROFILE%\.glzr\glazewm\focus-or-run.ps1
#                 -Process msedge -Run msedge']
# (conhost --headless keeps a console window from flashing up.)

param(
    [Parameter(Mandatory)] [string] $Process,  # processName as GlazeWM shows it, e.g. msedge
    [string] $Class = '',                      # optional window class, e.g. CabinetWClass
    [Parameter(Mandatory)] [string] $Run,      # program to start when no window matches
    [string] $RunArgs = ''
)

$glazewm = Join-Path $env:LOCALAPPDATA 'Programs\GlazeWM\cli\glazewm.exe'

try {
    $windows = (& $glazewm query windows | ConvertFrom-Json).data.windows
} catch {
    $windows = @()
}

$matching = @($windows | Where-Object {
    $_.processName -eq $Process -and (-not $Class -or $_.className -eq $Class) -and
    $_.state.type -ne 'minimized'
})
if ($matching.Count -eq 0) {
    # Minimized windows count too, but only when nothing else matches.
    $matching = @($windows | Where-Object {
        $_.processName -eq $Process -and (-not $Class -or $_.className -eq $Class)
    })
}

if ($matching.Count -gt 0) {
    $i = [array]::FindIndex([object[]]$matching, [Predicate[object]]{ param($w) $w.hasFocus })
    $target = $matching[($i + 1) % $matching.Count]   # first, or next after the focused one
    & $glazewm command focus --container-id $target.id | Out-Null
} elseif ($RunArgs) {
    Start-Process -FilePath $Run -ArgumentList $RunArgs
} else {
    Start-Process -FilePath $Run
}
