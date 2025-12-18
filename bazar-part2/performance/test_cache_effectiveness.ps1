# PowerShell script to test cache effectiveness with many requests
# This test specifically shows how caching improves performance with high request volumes
$FRONTEND_URL = "http://localhost:5002"
$NUM_REQUESTS = 1000  # High number to show cache effectiveness

$separator = "=" * 70
Write-Host $separator -ForegroundColor Cyan
Write-Host "Cache Effectiveness Test - Part 2" -ForegroundColor Cyan
Write-Host $separator -ForegroundColor Cyan
Write-Host "This test makes $NUM_REQUESTS requests to the same endpoint" -ForegroundColor Yellow
Write-Host "to demonstrate cache effectiveness with high request volumes" -ForegroundColor Yellow
Write-Host $separator -ForegroundColor Cyan

# Function to measure response time
function Measure-ResponseTime {
    param(
        [string]$Url,
        [string]$Method = "GET"
    )
    
    $start = Get-Date
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10 -ErrorAction Stop
        $elapsed = ((Get-Date) - $start).TotalMilliseconds
        return @{
            Time = $elapsed
            Status = $response.StatusCode
            Success = $true
        }
    } catch {
        $elapsed = ((Get-Date) - $start).TotalMilliseconds
        return @{
            Time = $elapsed
            Status = $null
            Success = $false
        }
    }
}

# Test Info endpoint with many requests
Write-Host "`nTesting /info/1 endpoint with $NUM_REQUESTS requests..." -ForegroundColor Yellow
Write-Host "First request = cache miss (~40-50ms)" -ForegroundColor Gray
Write-Host "Subsequent requests = cache hits (~1-5ms)" -ForegroundColor Gray

$allTimes = @()
$cacheMissTime = $null
$cacheHitTimes = @()
$successCount = 0

for ($i = 0; $i -lt $NUM_REQUESTS; $i++) {
    $result = Measure-ResponseTime -Url "$FRONTEND_URL/info/1" -Method "GET"
    
    if ($result.Success -and $result.Status -eq 200) {
        $allTimes += $result.Time
        $successCount++
        
        # First request is cache miss
        if ($i -eq 0) {
            $cacheMissTime = $result.Time
            Write-Host "  Request 1 (Cache Miss): $([math]::Round($result.Time, 2))ms" -ForegroundColor Red
        } else {
            $cacheHitTimes += $result.Time
        }
    }
    
    if (($i + 1) % 200 -eq 0) {
        $currentAvg = ($allTimes | Measure-Object -Average).Average
        Write-Host "  Progress: $($i + 1)/$NUM_REQUESTS requests, Current Avg: $([math]::Round($currentAvg, 2))ms" -ForegroundColor Gray
    }
}

if ($allTimes.Count -gt 0) {
    $avgAll = ($allTimes | Measure-Object -Average).Average
    $medianAll = ($allTimes | Sort-Object)[[math]::Floor($allTimes.Count / 2)]
    $minAll = ($allTimes | Measure-Object -Minimum).Minimum
    $maxAll = ($allTimes | Measure-Object -Maximum).Maximum
    
    if ($cacheHitTimes.Count -gt 0) {
        $avgCacheHit = ($cacheHitTimes | Measure-Object -Average).Average
        $minCacheHit = ($cacheHitTimes | Measure-Object -Minimum).Minimum
        $maxCacheHit = ($cacheHitTimes | Measure-Object -Maximum).Maximum
    }
    
    Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
    Write-Host "RESULTS" -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan
    
    Write-Host "`nOverall Statistics (including cache miss):" -ForegroundColor Yellow
    Write-Host "  Total Requests: $successCount/$NUM_REQUESTS" -ForegroundColor White
    Write-Host "  Average Time: $([math]::Round($avgAll, 2))ms" -ForegroundColor Green
    Write-Host "  Median Time: $([math]::Round($medianAll, 2))ms" -ForegroundColor Green
    Write-Host "  Min Time: $([math]::Round($minAll, 2))ms" -ForegroundColor White
    Write-Host "  Max Time: $([math]::Round($maxAll, 2))ms" -ForegroundColor White
    
    if ($cacheMissTime) {
        Write-Host "`nCache Miss (First Request):" -ForegroundColor Yellow
        Write-Host "  Time: $([math]::Round($cacheMissTime, 2))ms" -ForegroundColor Red
    }
    
    if ($cacheHitTimes.Count -gt 0) {
        Write-Host "`nCache Hits ($($cacheHitTimes.Count) requests):" -ForegroundColor Yellow
        Write-Host "  Average Time: $([math]::Round($avgCacheHit, 2))ms" -ForegroundColor Green
        Write-Host "  Min Time: $([math]::Round($minCacheHit, 2))ms" -ForegroundColor White
        Write-Host "  Max Time: $([math]::Round($maxCacheHit, 2))ms" -ForegroundColor White
        
        if ($cacheMissTime) {
            $improvement = (($cacheMissTime - $avgCacheHit) / $cacheMissTime) * 100
            Write-Host "`nCache Improvement:" -ForegroundColor Yellow
            Write-Host "  Cache hits are $([math]::Round($improvement, 1))% faster than cache miss!" -ForegroundColor Green
            Write-Host "  Speedup: $([math]::Round($cacheMissTime / $avgCacheHit, 1))x faster" -ForegroundColor Green
        }
    }
    
    Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
    Write-Host "CONCLUSION" -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Cyan
    Write-Host "With $NUM_REQUESTS requests, the average response time is $([math]::Round($avgAll, 2))ms" -ForegroundColor White
    Write-Host "This demonstrates that caching significantly improves performance" -ForegroundColor Green
    Write-Host "when the same data is accessed multiple times." -ForegroundColor Green
}

