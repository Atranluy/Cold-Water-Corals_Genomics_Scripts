#!/usr/bin/env python3
from pathlib import Path
from Bio import SeqIO

folder = Path(".")  # current directory
fas_files = sorted(folder.glob("*.fas"))

for f in fas_files:
    backup = f.with_suffix(".fas.bak")
    if not backup.exists():
        f.replace(backup)  # make a backup copy

    records = []
    for record in SeqIO.parse(backup, "fasta"):
        seq = str(record.seq).upper().replace("?", "N")
        record.seq = record.seq.__class__(seq)
        records.append(record)

    SeqIO.write(records, f, "fasta")

print(f"Replaced '?' with 'N' in {len(fas_files)} FASTA files.")
print("Backup copies saved as *.fas.bak")
