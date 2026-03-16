#Call from 'Modules' directory using ../Scripts/simulate_sv.ps1

param(
    [switch]$help,
    [int]$time = 1000
)

$timer = [System.Diagnostics.Stopwatch]::StartNew()

$vsimArgs = ""

if ($Help) {
    # You can put your usage message here
    Write-Output "
    -help:              shows this dialog
    -time <INTEGER>     sets the runtime of the questia simulation to be <INTEGER> micro seconds, default is 2us
    "
    exit 0
}

$do = @"
file delete -force sim.log
transcript file sim.log;
vlog *.sv;
vsim -voptargs=+acc work.top_verichip4 $vsimArgs;
run ${time}us; quit -f
"@

vsim -c -do $do

Select-String -Path sim.log -Pattern "error" | Out-String | Write-Host -ForegroundColor Cyan

$timer.Stop()
Write-Host ("Total runtime: {0}" -f $timer.Elapsed)