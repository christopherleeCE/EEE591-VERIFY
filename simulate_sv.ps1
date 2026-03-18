#Call from 'Modules' directory using ../Scripts/simulate_sv.ps1

param(
    [switch]$help,
    [string]$file_name,
    [int]$time = 1000
)

$timer = [System.Diagnostics.Stopwatch]::StartNew()

$vsimArgs = ""

if ($Help) {
    # You can put your usage message here
    Write-Output "
    -help:              shows this dialog
    -time <INTEGER>     sets the runtime of the questia simulation to be <INTEGER> micro seconds, default is 2us
    -file_name          required, give the filename of the top file, excluding the .sv, for example... ..\simulate_sv.ps1 top_verichip4

    "
    exit 0
}

if($file_name -eq ""){
    Write-Host "Error: pleas give file name like seen in -help" -ForegroundColor Red
    exit 1
}

$do = @"
file delete -force sim.log
transcript file sim.log;
vlog *.sv;
vsim -voptargs=+acc work.$file_name $vsimArgs;
run ${time}us; quit -f
"@

vsim -c -do $do

Write-Host "`n`ngrep 'error'" -ForegroundColor Magenta -NoNewline
Select-String -Path sim.log -Pattern "error" | Out-String | Write-Host -ForegroundColor Cyan
Write-Host "grep 'warning'" -ForegroundColor Magenta -NoNewline
Select-String -Path sim.log -Pattern "warning" | Out-String | Write-Host -ForegroundColor Cyan

$timer.Stop()
Write-Host ("Total runtime: {0}" -f $timer.Elapsed)