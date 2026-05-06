#!/usr/bin/env python3
import sys
import glob
import json

json_dir = sys.argv[1]

for pth in glob.glob(json_dir + '/*.json'):

    with open(pth) as f:
        report = json.load(f)

    r1_before = report['read1_before_filtering']
    r1_after  = report['read1_after_filtering']
    r2_before = report['read2_before_filtering']
    r2_after  = report['read2_after_filtering']

    r1_avg_before = r1_before['total_bases'] / r1_before['total_reads']
    r1_avg_after  = r1_after['total_bases'] / r1_after['total_reads']
    r2_avg_before = r2_before['total_bases'] / r2_before['total_reads']
    r2_avg_after  = r2_after['total_bases'] / r2_after['total_reads']

    print(f"{pth}. Forward: {r1_avg_before:.0f} → {r1_avg_after:.0f} (trim ~{r1_avg_before - r1_avg_after:.0f} bp)")
    print(f"{pth}. Reverse: {r2_avg_before:.0f} → {r2_avg_after:.0f} (trim ~{r2_avg_before - r2_avg_after:.0f} bp)")
