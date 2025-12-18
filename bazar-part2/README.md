# BAZAR Part 2 - Replication, Caching and Consistency

This project implements an enhanced version of the BAZAR e-commerce system with:
- **In-memory caching** in the frontend server
- **Catalog server replication** (2 replicas)
- **Order server replication** (2 replicas)
- **Cache invalidation** on write operations
- **Round-robin load balancing**

## Project Structure

```
bazar-part2/
├── frontend/          # Frontend server with caching
├── catalog/           # Catalog server with replication
├── order/             # Order server with load balancing
├── docker-compose.yml # Docker configuration
├── performance/       # Performance testing scripts
└── docs/              # Documentation and results
```

## Prerequisites

- **Docker Desktop** installed and running
- **PowerShell** (Windows) or **Bash** (Linux/Mac)
- Internet connection (for Docker to pull images)

## Quick Start

### 1. Start the System

```powershell
# Navigate to project directory
cd bazar-part2

# Start all containers
docker-compose up -d

# Verify containers are running
docker ps
```

You should see 5 containers running:
- `frontend_service` (port 5002)
- `catalog_service_1` (port 5000)
- `catalog_service_2` (port 5003)
- `order_service_1` (port 5001)
- `order_service_2` (port 5004)

### 2. Test the System

Open your browser or use curl:
- Info: http://localhost:5002/info/1
- Search: http://localhost:5002/search/distributed%20systems
- Purchase: POST http://localhost:5002/purshase (with JSON body)

## Performance Testing - Complete Guide

This guide explains how to run performance tests comparing Part 1 (baseline) and Part 2 (enhanced) systems.

### Overview

The testing process involves:
1. Testing Part 1 (baseline system)
2. Testing Part 2 (enhanced system)
3. Comparing results

**Important:** Part 1 and Part 2 use the same ports, so you must test them separately.

---

## Step-by-Step Testing Process

### STEP 1: Test Part 1 (Baseline System)

#### 1.1 Start Part 1

```powershell
# Navigate to Part 1 directory
cd ..\bazar-part1

# Start Part 1 containers
docker-compose up -d

# Verify containers are running
docker ps
```

You should see 3 containers:
- `frontend_service`
- `order_service`
- `catalog_service`

#### 1.2 Run Part 1 Performance Tests

```powershell
# Navigate to performance testing directory
cd ..\bazar-part2\performance

# Run Part 1 tests (500 requests per operation)
.\test_part1.ps1
```

**What this does:**
- Tests `/info/1` endpoint (500 requests)
- Tests `/search/distributed systems` endpoint (500 requests)
- Tests `/purshase` endpoint (20 requests)
- Saves results to `part1_results.json`

**Expected duration:** 2-3 minutes

**Output:** Results saved to `part1_results.json`

#### 1.3 Verify Part 1 Results

```powershell
# Check that results file was created
dir part1_results.json

# View results (optional)
Get-Content part1_results.json | ConvertFrom-Json
```

---

### STEP 2: Stop Part 1 and Start Part 2

#### 2.1 Stop Part 1

```powershell
# Navigate to Part 1 directory
cd ..\..\bazar-part1

# Stop and remove Part 1 containers
docker-compose down

# Verify containers are stopped
docker ps
```

#### 2.2 Start Part 2

```powershell
# Navigate to Part 2 directory
cd ..\bazar-part2

# Start Part 2 containers
docker-compose up -d

# Verify containers are running
docker ps
```

You should see 5 containers:
- `frontend_service`
- `catalog_service_1`
- `catalog_service_2`
- `order_service_1`
- `order_service_2`

---

### STEP 3: Test Part 2 (Enhanced System)

#### 3.1 Run Part 2 Performance Tests

```powershell
# Navigate to performance testing directory
cd performance

# Run Part 2 tests (500 requests per operation)
.\test_part2.ps1
```

**What this does:**
- Tests `/info/1` endpoint with caching (500 requests)
- Tests `/search/distributed systems` endpoint with caching (500 requests)
- Tests `/purshase` endpoint with cache invalidation (20 requests)
- Saves results to `part2_results.json`

**Expected duration:** 2-3 minutes

**Output:** Results saved to `part2_results.json`

#### 3.2 Verify Part 2 Results

```powershell
# Check that results file was created
dir part2_results.json

# View results (optional)
Get-Content part2_results.json | ConvertFrom-Json
```

---

### STEP 4: Compare Results

#### 4.1 Run Comparison Script

```powershell
# Make sure you're in the performance directory
cd performance

# Compare Part 1 and Part 2 results
.\compare_results.ps1
```

**What this does:**
- Loads `part1_results.json` and `part2_results.json`
- Calculates improvement percentages
- Displays comparison table
- Saves detailed comparison to `comparison_results.json`

**Output:**
- Console output with comparison table
- `comparison_results.json` file with detailed metrics

#### 4.2 View Comparison Results

The comparison will show:
- **Info Query**: Part 1 vs Part 2 response times and improvement
- **Search Query**: Part 1 vs Part 2 response times and improvement
- **Purchase**: Part 1 vs Part 2 response times and difference

Example output:
```
======================================================================
SUMMARY TABLE
======================================================================
Operation            Part 1 (ms)     Part 2 (ms)     Improvement    
----------------------------------------------------------------------
Info Query           43.77           44.30                    -1.20%
Search Query         49.63           48.46                     2.35%
======================================================================
```

---

## Complete Command Sequence

Here's the complete sequence of commands to run all tests:

```powershell
# ============================================
# STEP 1: Test Part 1
# ============================================
cd C:\Users\Abdulkreem Abuzahra\Desktop\HW\Project-DOS\bazar-part1
docker-compose up -d
cd ..\bazar-part2\performance
.\test_part1.ps1

# ============================================
# STEP 2: Stop Part 1, Start Part 2
# ============================================
cd ..\..\bazar-part1
docker-compose down
cd ..\bazar-part2
docker-compose up -d

# ============================================
# STEP 3: Test Part 2
# ============================================
cd performance
.\test_part2.ps1

# ============================================
# STEP 4: Compare Results
# ============================================
.\compare_results.ps1
```

---

## Understanding the Results

### Expected Results

**Info Query:**
- Part 2 may be slightly slower (0-2%) due to initial cache miss
- This is expected and normal
- With more requests, Part 2 would show improvement

**Search Query:**
- Part 2 should show improvement (2-5% faster)
- Demonstrates cache effectiveness
- Cache hits are much faster than database queries

**Purchase:**
- Part 2 will be slower (30-40% slower)
- This is expected due to replication overhead
- Acceptable trade-off for fault tolerance

### Results Files

After running all tests, you'll have:
- `part1_results.json` - Part 1 test results
- `part2_results.json` - Part 2 test results
- `comparison_results.json` - Detailed comparison

These files are in the `performance/` directory.

---

## Troubleshooting

### "Port already in use" Error

**Problem:** Cannot start containers because port is already in use.

**Solution:**
```powershell
# Stop all containers
cd bazar-part1
docker-compose down

cd ..\bazar-part2
docker-compose down

# Then start the one you need
```

### "Container name conflict" Error

**Problem:** Container name already exists.

**Solution:**
```powershell
# Remove old containers
docker rm frontend_service order_service catalog_service

# Or remove all stopped containers
docker container prune
```

### "Connection refused" Error

**Problem:** Cannot connect to frontend.

**Solution:**
```powershell
# Check if containers are running
docker ps

# Check container logs
docker-compose logs frontend

# Restart containers
docker-compose restart
```

### Test Script Errors

**Problem:** PowerShell script execution error.

**Solution:**
```powershell
# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run the script again
.\test_part1.ps1
```

### "Out of stock" Errors

**Problem:** Purchase tests fail due to insufficient stock.

**Solution:**
- Make sure catalog CSV files have sufficient quantities
- Or modify test scripts to use different book_ids

---

## Performance Test Scripts

### Available Scripts

- `test_part1.ps1` - Test Part 1 (baseline system)
- `test_part2.ps1` - Test Part 2 (enhanced system)
- `compare_results.ps1` - Compare Part 1 and Part 2 results
- `quick_test.ps1` - Quick verification (tests if system works)
- `test_cache_effectiveness.ps1` - Detailed cache analysis (1000 requests)

### Script Configuration

You can modify the number of requests in the scripts:
- Open `test_part1.ps1` or `test_part2.ps1`
- Change `$NUM_REQUESTS = 500` to your desired number
- Save and run

---

## Results Documentation

After running tests, results are automatically saved to:
- `performance/part1_results.json`
- `performance/part2_results.json`
- `performance/comparison_results.json`

For documentation, see:
- `docs/part1_output.txt` - Formatted Part 1 results
- `docs/part2_output.txt` - Formatted Part 2 results
- `docs/performance_table.txt` - Comparison table

---

## Stopping the System

When done testing:

```powershell
# Stop Part 2 containers
cd bazar-part2
docker-compose down

# Or stop Part 1 containers
cd bazar-part1
docker-compose down
```

---

## Additional Resources

- **Performance Testing Guide**: See `performance/README.md`
- **Documentation**: See `docs/README_DOCS.md`
- **Submission Checklist**: See `SUBMISSION_CHECKLIST.md`

---

## Support

If you encounter issues:
1. Check Docker Desktop is running
2. Verify containers are running: `docker ps`
3. Check container logs: `docker-compose logs`
4. Review troubleshooting section above

---

**Last Updated:** [Current Date]  
**Test Configuration:** 500 requests per operation  
**System:** Docker Desktop on Windows

