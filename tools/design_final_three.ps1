# Final three tracks for Palaces 13-15. Prints the exact data as Lua tables (round numbers) and writes final images to track_designs\final_*.png
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here "palace_designer.ps1")
$outDir = Join-Path $here "track_designs"
New-Item -ItemType Directory -Force $outDir | Out-Null
$inv = [Globalization.CultureInfo]::InvariantCulture
function Pt { param([double]$x, [double]$z) return ("{0},{1}" -f ([math]::Round($x).ToString($inv)), ([math]::Round($z).ToString($inv))) }
function Ring {
	param([double]$r, [double]$fromDeg, [double]$toDeg, [double]$step)
	$pts = @()
	$n = [math]::Max(2, [int]([math]::Abs($toDeg - $fromDeg) / $step))
	for ($i = 0; $i -le $n; $i++) {
		$a = ($fromDeg + ($toDeg - $fromDeg) * $i / $n) * [math]::PI / 180
		$pts += (Pt -x ($r * [math]::Cos($a)) -z ($r * [math]::Sin($a)))
	}
	return $pts
}
function Polar { param([double]$r, [double]$deg) $a = $deg * [math]::PI / 180; return (Pt -x ($r * [math]::Cos($a)) -z ($r * [math]::Sin($a))) }

# 13. CARNIVAL (trefoil pinwheel)
$tre = @((Pt -x -20 -z -105))
foreach ($ang in @(-90, 30, 150)) {
	$tre += (Polar -r 30 -deg ($ang + 23)); $tre += (Polar -r 88 -deg ($ang + 20))
	$tre += (Polar -r 88 -deg ($ang - 20)); $tre += (Polar -r 30 -deg ($ang - 23))
}
$tre += (Pt -x 0 -z 40)
# 14. ECHOES (double spiral, in and back out)
$ds = @()
$ds += (Ring -r 95 -fromDeg 200 -toDeg -80 -step 20)
$ds += (Ring -r 70 -fromDeg -80 -toDeg -330 -step 20)
$ds += (Ring -r 45 -fromDeg -330 -toDeg -560 -step 20)
$ds += (Ring -r 62 -fromDeg -560 -toDeg -300 -step 20)
# 15. ARCHIPELAGO (serpentine with a lake in every U-turn)
$lk = "-105,-80;90,-80;90,-32;-90,-32;-90,16;90,16;90,64;-60,64;-60,90;0,90"

$specs = @(
 @{ Name = "Carnival"; Lanes = ($tre -join ";"); PoolR = 12; NPools = 2; NPads = 5 },
 @{ Name = "Echoes"; Lanes = ($ds -join ";"); PoolR = 12; NPools = 2; NPads = 5 },
 @{ Name = "Archipelago"; Lanes = $lk; PoolR = 14; NPools = 3; NPads = 4 }
)
foreach ($s in $specs) {
	$sug = [Designer]::Suggest($s.Lanes, $s.NPools, $s.PoolR, $s.NPads)
	$parts = $sug.Split('|')
	$png = Join-Path $outDir ("final_" + $s.Name + ".png")
	$null = [Designer]::Analyze($s.Name, $s.Lanes, $parts[0], $parts[1], $png)
	"== $($s.Name)"
	"LANE   = `"$($s.Lanes)`""
	"POOLS  = `"$($parts[0])`""
	"PADS   = `"$($parts[1])`""
}
