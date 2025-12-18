# Documentation Files in /docs Folder

This folder contains all required documentation for Lab 2 submission.

## Required Files Structure

```
/docs/
├── report.pdf (or report.docx)        ✅ Final performance evaluation report
├── performance_table.pdf               ✅ Performance comparison table
├── performance_graph.png               ✅ Performance comparison graphs
├── part1_output.txt                   ✅ Part 1 test results (100 requests)
└── part2_output.txt                   ✅ Part 2 test results (100 requests)
```

## File Descriptions

### 1. report.pdf / report.docx
**Final Performance Evaluation Report**
- Complete performance analysis
- Experimental setup
- Results and analysis
- Conclusions
- Based on 100 request tests

### 2. performance_table.pdf
**Performance Comparison Table**
- Formatted table showing Part 1 vs Part 2 comparison
- Detailed metrics
- Analysis of each operation
- Can be created from `performance_table.txt` or Excel

### 3. performance_graph.png
**Performance Graphs/Charts**
- Bar chart: Part 1 vs Part 2 response times
- Line chart: Improvement percentages
- Created in Excel or other graphing tool

### 4. part1_output.txt
**Part 1 Test Output**
- Results from baseline system (no caching, no replication)
- 100 requests per operation
- Detailed metrics and statistics

### 5. part2_output.txt
**Part 2 Test Output**
- Results from enhanced system (with caching and replication)
- 100 requests per operation
- Detailed metrics and statistics
- Cache effectiveness analysis

## How to Create Missing Files

### performance_table.pdf
1. Open `performance_table.txt` in Word
2. Format as a nice table
3. Save as PDF

OR

1. Create table in Excel
2. Copy data from `performance_table.txt`
3. Format nicely
4. Export as PDF

### performance_graph.png
1. Open Excel
2. Create data:
   ```
   Operation      | Part 1 | Part 2
   Info Query     | 40.71  | 40.93
   Search Query   | 40.88  | 39.06
   Purchase       | 46.19  | 63.60
   ```
3. Insert → Bar Chart
4. Format chart
5. Right-click → Save as Picture → PNG

### report.pdf
1. Use `FINAL_REPORT_STRUCTURE.md` as base
2. Update with 100 request results:
   - Info Query: 40.71ms vs 40.93ms (-0.54%)
   - Search Query: 40.88ms vs 39.06ms (+4.45%)
   - Purchase: 46.19ms vs 63.60ms (-37.69%)
3. Add graphs
4. Save as PDF

## Current Status

- ✅ part1_output.txt - Created
- ✅ part2_output.txt - Created
- ✅ performance_table.txt - Created (convert to PDF)
- ⏳ performance_graph.png - Need to create
- ⏳ report.pdf - Need to create from FINAL_REPORT_STRUCTURE.md

## Next Steps

1. Create performance_graph.png (bar chart in Excel)
2. Create performance_table.pdf (from performance_table.txt)
3. Create report.pdf (from FINAL_REPORT_STRUCTURE.md with 100 request results)
4. Verify all files are in /docs folder

