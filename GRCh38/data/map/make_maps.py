import csv, gzip

with gzip.open("aau1043_datas3.gz", "rt") as fin, open("aau1043_datas3.noheader", "wt") as fout:
    for line in fin:
        if line.startswith("#"):
            continue
        fout.write(line)

file_dict = {"chr" + str(x): open("chr" + str(x) + ".map", "wt") for x in range(1, 23)}
for file in file_dict.values():
    file.write("position COMBINED_rate(cM/Mb) Genetic_Map(cM)\n")

with open("aau1043_datas3.noheader", "rt") as f:
    reader = csv.DictReader(f, delimiter="\t") 
    # Chr	Begin	End	cMperMb	cM
    for row in reader:
        if row["Chr"] not in file_dict:
            continue
        mid = int(row["Begin"]) + (int(row["End"]) - int(row["Begin"])) // 2
        file_dict[row["Chr"]].write(str(mid) + " " + row["cMperMb"] + " " + row["cM"] + "\n")

for file in file_dict.values():
    file.close()