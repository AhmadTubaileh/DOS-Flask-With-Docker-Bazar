# PowerShell script to compare Part 1 and Part 2 results (No Python Required)

$part1File = "part1_results.json"
$part2File = "part2_results.json"

if (-not (Test-Path $part1File)) {
    Write-Host "Error: $part1File not found. Please run Part 1 tests first." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $part2File)) {
    Write-Host "Error: $part2File not found. Please run Part 2 tests first." -ForegroundColor Red
    exit 1
}

# Load results
$part1Results = Get-Content $part1File | ConvertFrom-Json
$part2Results = Get-Content $part2File | ConvertFrom-Json

$separator = "=" * 70
Write-Host $separator -ForegroundColor Cyan
Write-Host "BAZAR Performance Comparison: Part 1 vs Part 2" -ForegroundColor Cyan
Write-Host $separator -ForegroundColor Cyan

$comparison = @{}

# Compare Info endpoint
if ($part1Results.info -and $part2Results.info) {
    $p1Avg = $part1Results.info.avg_time
    $p2Avg = $part2Results.info.avg_time
    $improvement = (($p1Avg - $p2Avg) / $p1Avg) * 100
    
    Write-Host "`nInfo Query Performance:" -ForegroundColor Yellow
    Write-Host "  Part 1 (No Cache):     $([math]::Round($p1Avg, 2))ms" -ForegroundColor White
    Write-Host "  Part 2 (With Cache):  $([math]::Round($p2Avg, 2))ms" -ForegroundColor White
    Write-Host "  Improvement:          $([math]::Round($improvement, 2))% faster with caching" -ForegroundColor Green
    if ($improvement -gt 0) {
        Write-Host "  Part 2 is $([math]::Round($improvement, 1))% faster!" -ForegroundColor Green
    } else {
        Write-Host "  Part 2 is $([math]::Round([math]::Abs($improvement), 1))% slower (unexpected)" -ForegroundColor Red
    }
    
    $comparison.info = @{
        part1_avg = $p1Avg
        part2_avg = $p2Avg
        improvement_percent = $improvement
    }
}

# Compare Search endpoint
if ($part1Results.search -and $part2Results.search) {
    $p1Avg = $part1Results.search.avg_time
    $p2Avg = $part2Results.search.avg_time
    $improvement = (($p1Avg - $p2Avg) / $p1Avg) * 100
    
    Write-Host "`nSearch Query Performance:" -ForegroundColor Yellow
    Write-Host "  Part 1 (No Cache):     $([math]::Round($p1Avg, 2))ms" -ForegroundColor White
    Write-Host "  Part 2 (With Cache):  $([math]::Round($p2Avg, 2))ms" -ForegroundColor White
    Write-Host "  Improvement:          $([math]::Round($improvement, 2))% faster with caching" -ForegroundColor Green
    if ($improvement -gt 0) {
        Write-Host "  Part 2 is $([math]::Round($improvement, 1))% faster!" -ForegroundColor Green
    } else {
        Write-Host "  Part 2 is $([math]::Round([math]::Abs($improvement), 1))% slower (unexpected)" -ForegroundColor Red
    }
    
    $comparison.search = @{
        part1_avg = $p1Avg
        part2_avg = $p2Avg
        improvement_percent = $improvement
    }
}

# Compare Purchase
if ($part1Results.purchase -and $part2Results.purchase) {
    $p1Avg = $part1Results.purchase.avg_time
    $p2Avg = $part2Results.purchase.avg_time
    $improvement = (($p1Avg - $p2Avg) / $p1Avg) * 100
    
    Write-Host "`nPurchase Operation Performance:" -ForegroundColor Yellow
    Write-Host "  Part 1 (No Replication): $([math]::Round($p1Avg, 2))ms" -ForegroundColor White
    Write-Host "  Part 2 (With Replication): $([math]::Round($p2Avg, 2))ms" -ForegroundColor White
    Write-Host "  Difference: $([math]::Round($improvement, 2))%" -ForegroundColor White
    if ([math]::Abs($improvement) -lt 5) {
        Write-Host "  Similar performance (replication overhead is minimal)" -ForegroundColor Cyan
    } elseif ($improvement -gt 0) {
        Write-Host "  Part 2 is $([math]::Round($improvement, 1))% faster!" -ForegroundColor Green
    } else {
        Write-Host "  Part 2 is $([math]::Round([math]::Abs($improvement), 1))% slower (replication overhead)" -ForegroundColor Yellow
    }
    
    $comparison.purchase = @{
        part1_avg = $p1Avg
        part2_avg = $p2Avg
        improvement_percent = $improvement
    }
}

# Save comparison
$allResults = @{
    part1 = $part1Results
    part2 = $part2Results
    comparison = $comparison
}

$outputFile = "comparison_results.json"
$allResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "`n$separator" -ForegroundColor Cyan
Write-Host "Comparison results saved to: $outputFile" -ForegroundColor Green
Write-Host $separator -ForegroundColor Cyan

# Print summary table
Write-Host "`n$separator" -ForegroundColor Cyan
Write-Host "SUMMARY TABLE" -ForegroundColor Cyan
Write-Host $separator -ForegroundColor Cyan
Write-Host ("{0,-20} {1,-15} {2,-15} {3,-15}" -f "Operation", "Part 1 (ms)", "Part 2 (ms)", "Improvement") -ForegroundColor White
Write-Host ("-" * 70) -ForegroundColor Gray

if ($comparison.info) {
    Write-Host ("{0,-20} {1,-15} {2,-15} {3,14}%" -f "Info Query", 
        [math]::Round($comparison.info.part1_avg, 2), 
        [math]::Round($comparison.info.part2_avg, 2), 
        [math]::Round($comparison.info.improvement_percent, 2)) -ForegroundColor White
}

if ($comparison.search) {
    Write-Host ("{0,-20} {1,-15} {2,-15} {3,14}%" -f "Search Query", 
        [math]::Round($comparison.search.part1_avg, 2), 
        [math]::Round($comparison.search.part2_avg, 2), 
        [math]::Round($comparison.search.improvement_percent, 2)) -ForegroundColor White
}

if ($comparison.purchase) {
    Write-Host ("{0,-20} {1,-15} {2,-15} {3,14}%" -f "Purchase", 
        [math]::Round($comparison.purchase.part1_avg, 2), 
        [math]::Round($comparison.purchase.part2_avg, 2), 
        [math]::Round($comparison.purchase.improvement_percent, 2)) -ForegroundColor White
}

Write-Host $separator -ForegroundColor Cyan
