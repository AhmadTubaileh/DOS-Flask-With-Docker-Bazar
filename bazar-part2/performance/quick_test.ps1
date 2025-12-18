# Quick PowerShell test script (no Python required)
$FRONTEND_URL = "http://localhost:5002"

Write-Host "Quick System Test" -ForegroundColor Green
Write-Host "=" * 40

# Test 1: Info endpoint
Write-Host "`n1. Testing /info/1 endpoint..." -ForegroundColor Yellow
$start = Get-Date
try {
    $response = Invoke-WebRequest -Uri "$FRONTEND_URL/info/1" -Method GET -TimeoutSec 5
    $elapsed = ((Get-Date) - $start).TotalMilliseconds
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Response Time: $([math]::Round($elapsed, 2))ms"
    $json = $response.Content | ConvertFrom-Json
    Write-Host "   Book: $($json.title)"
} catch {
    Write-Host "   ERROR: $_" -ForegroundColor Red
}

# Test 2: Search endpoint
Write-Host "`n2. Testing /search/distributed%20systems endpoint..." -ForegroundColor Yellow
$start = Get-Date
try {
    $response = Invoke-WebRequest -Uri "$FRONTEND_URL/search/distributed%20systems" -Method GET -TimeoutSec 5
    $elapsed = ((Get-Date) - $start).TotalMilliseconds
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Response Time: $([math]::Round($elapsed, 2))ms"
    $json = $response.Content | ConvertFrom-Json
    Write-Host "   Found $($json.Count) books"
} catch {
    Write-Host "   ERROR: $_" -ForegroundColor Red
}

# Test 3: Purchase endpoint
Write-Host "`n3. Testing /purshase endpoint..." -ForegroundColor Yellow
$start = Get-Date
try {
    $body = @{book_id = 1} | ConvertTo-Json
    $response = Invoke-WebRequest -Uri "$FRONTEND_URL/purshase" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
    $elapsed = ((Get-Date) - $start).TotalMilliseconds
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Response Time: $([math]::Round($elapsed, 2))ms"
    $json = $response.Content | ConvertFrom-Json
    Write-Host "   Response: $($json.message)"
} catch {
    Write-Host "   ERROR: $_" -ForegroundColor Red
}

Write-Host "`n" + ("=" * 40)
Write-Host "Quick test completed!" -ForegroundColor Green

