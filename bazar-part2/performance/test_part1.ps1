# PowerShell Performance Test for Part 1 (No Python Required)
$FRONTEND_URL = "http://localhost:5002"
$NUM_REQUESTS = 500  # Increased to match Part 2 for fair comparison

$separator = "=" * 70
Write-Host $separator -ForegroundColor Cyan
Write-Host "BAZAR Part 1 Performance Test (No Caching, No Replication)" -ForegroundColor Cyan
Write-Host $separator -ForegroundColor Cyan
Write-Host "Frontend URL: $FRONTEND_URL"
Write-Host "Number of requests per test: $NUM_REQUESTS"
Write-Host "Make sure Part 1 is running (bazar-part1)" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Cyan

$results = @{}

# Function to measure response time
function Measure-ResponseTime {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Body = $null
    )
    
    $start = Get-Date
    try {
        if ($Method -eq "GET") {
            $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10 -ErrorAction Stop
        } else {
            $jsonBody = $Body | ConvertTo-Json
            $response = Invoke-WebRequest -Uri $Url -Method POST -Body $jsonBody -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
        }
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

# Test Info Endpoint
Write-Host "`nTesting Info Query..." -ForegroundColor Yellow
$infoTimes = @()
$infoSuccess = 0

for ($i = 0; $i -lt $NUM_REQUESTS; $i++) {
    $result = Measure-ResponseTime -Url "$FRONTEND_URL/info/1" -Method "GET"
    if ($result.Success -and $result.Status -eq 200) {
        $infoTimes += $result.Time
        $infoSuccess++
    }
    if (($i + 1) % 100 -eq 0) {
        Write-Host "  Completed $($i + 1)/$NUM_REQUESTS requests..." -ForegroundColor Gray
    }
}

if ($infoTimes.Count -gt 0) {
    $avgInfo = ($infoTimes | Measure-Object -Average).Average
    $medianInfo = ($infoTimes | Sort-Object)[[math]::Floor($infoTimes.Count / 2)]
    $minInfo = ($infoTimes | Measure-Object -Minimum).Minimum
    $maxInfo = ($infoTimes | Measure-Object -Maximum).Maximum
    
    Write-Host "  Results: Avg=$([math]::Round($avgInfo, 2))ms, Median=$([math]::Round($medianInfo, 2))ms, Min=$([math]::Round($minInfo, 2))ms, Max=$([math]::Round($maxInfo, 2))ms" -ForegroundColor Green
    Write-Host "  Successful: $infoSuccess/$NUM_REQUESTS" -ForegroundColor Green
    
    $results['info'] = @{
        operation = "Info Query"
        avg_time = $avgInfo
        median_time = $medianInfo
        min_time = $minInfo
        max_time = $maxInfo
        successful_requests = $infoSuccess
        total_requests = $NUM_REQUESTS
    }
}

# Test Search Endpoint
Write-Host "`nTesting Search Query..." -ForegroundColor Yellow
$searchTimes = @()
$searchSuccess = 0

for ($i = 0; $i -lt $NUM_REQUESTS; $i++) {
    $result = Measure-ResponseTime -Url "$FRONTEND_URL/search/distributed%20systems" -Method "GET"
    if ($result.Success -and $result.Status -eq 200) {
        $searchTimes += $result.Time
        $searchSuccess++
    }
    if (($i + 1) % 100 -eq 0) {
        Write-Host "  Completed $($i + 1)/$NUM_REQUESTS requests..." -ForegroundColor Gray
    }
}

if ($searchTimes.Count -gt 0) {
    $avgSearch = ($searchTimes | Measure-Object -Average).Average
    $medianSearch = ($searchTimes | Sort-Object)[[math]::Floor($searchTimes.Count / 2)]
    $minSearch = ($searchTimes | Measure-Object -Minimum).Minimum
    $maxSearch = ($searchTimes | Measure-Object -Maximum).Maximum
    
    Write-Host "  Results: Avg=$([math]::Round($avgSearch, 2))ms, Median=$([math]::Round($medianSearch, 2))ms, Min=$([math]::Round($minSearch, 2))ms, Max=$([math]::Round($maxSearch, 2))ms" -ForegroundColor Green
    Write-Host "  Successful: $searchSuccess/$NUM_REQUESTS" -ForegroundColor Green
    
    $results['search'] = @{
        operation = "Search Query"
        avg_time = $avgSearch
        median_time = $medianSearch
        min_time = $minSearch
        max_time = $maxSearch
        successful_requests = $searchSuccess
        total_requests = $NUM_REQUESTS
    }
}

# Test Purchase Operation
Write-Host "`nTesting Purchase Operation..." -ForegroundColor Yellow
$purchaseTimes = @()
$purchaseSuccess = 0
$purchaseCount = 20

for ($i = 0; $i -lt $purchaseCount; $i++) {
    $result = Measure-ResponseTime -Url "$FRONTEND_URL/purshase" -Method "POST" -Body @{book_id = 1}
    if ($result.Success -and $result.Status -eq 200) {
        $purchaseTimes += $result.Time
        $purchaseSuccess++
    }
    if (($i + 1) % 5 -eq 0) {
        Write-Host "  Completed $($i + 1)/$purchaseCount requests..." -ForegroundColor Gray
    }
    Start-Sleep -Milliseconds 100
}

if ($purchaseTimes.Count -gt 0) {
    $avgPurchase = ($purchaseTimes | Measure-Object -Average).Average
    $medianPurchase = ($purchaseTimes | Sort-Object)[[math]::Floor($purchaseTimes.Count / 2)]
    $minPurchase = ($purchaseTimes | Measure-Object -Minimum).Minimum
    $maxPurchase = ($purchaseTimes | Measure-Object -Maximum).Maximum
    
    Write-Host "  Results: Avg=$([math]::Round($avgPurchase, 2))ms, Median=$([math]::Round($medianPurchase, 2))ms, Min=$([math]::Round($minPurchase, 2))ms, Max=$([math]::Round($maxPurchase, 2))ms" -ForegroundColor Green
    Write-Host "  Successful: $purchaseSuccess/$purchaseCount" -ForegroundColor Green
    
    $results['purchase'] = @{
        operation = "Purchase"
        avg_time = $avgPurchase
        median_time = $medianPurchase
        min_time = $minPurchase
        max_time = $maxPurchase
        successful_requests = $purchaseSuccess
        total_requests = $purchaseCount
    }
}

# Save results to JSON
$outputFile = "part1_results.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "`n$separator" -ForegroundColor Cyan
Write-Host "Results saved to: $outputFile" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Cyan

# Print summary
Write-Host "`nSUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan
if ($results['info']) {
    Write-Host "Info Query:    $([math]::Round($results['info'].avg_time, 2))ms (average)" -ForegroundColor White
}
if ($results['search']) {
    Write-Host "Search Query:   $([math]::Round($results['search'].avg_time, 2))ms (average)" -ForegroundColor White
}
if ($results['purchase']) {
    Write-Host "Purchase:      $([math]::Round($results['purchase'].avg_time, 2))ms (average)" -ForegroundColor White
}
Write-Host ("=" * 70) -ForegroundColor Cyan

