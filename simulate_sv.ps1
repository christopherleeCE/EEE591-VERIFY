#Call from 'Modules' directory using ../Scripts/simulate_sv.ps1

param(
    [switch]$help,
    [int]$time = 100
)

$vsimArgs = ""

if ($Help) {
    # You can put your usage message here
    Write-Output "
    -help:              shows this dialog
    -time <INTEGER>     sets the runtime of the questia simulation to be <INTEGER> micro seconds, default is 2us
    "
    exit 0
}
vsim -c -do "file delete -force sim.log; transcript file sim.log; vlog *.sv; vsim -voptargs=+acc work.top_verichip $vsimArgs; run ${time}us; quit -f"