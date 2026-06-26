setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# if(!require("BiocManager", quietly = TRUE)){
#   install.packages("BiocManager")
# }
#   
# if(!require("biomaRt", quietly = TRUE)) {
#   BiocManager::install("biomaRt")
# }
# 
# library(biomaRt)
# 
# 
# snp_mart = useMart("ENSEMBL_MART_SNP", 
#                    dataset="hsapiens_snp",
#                    host = "https://grch37.ensembl.org")
# 
# hm3_table <- read.table("../data/hm3/w_hm3.snplist",
#                         header = T,
#                         sep = "\t")
# 
# rsids <- hm3_table$SNP
# 
# coordinates_raw <- getBM(attributes = c("refsnp_id", "chr_name", "chrom_start"), 
#                          filters = "snp_filter", 
#                          values = rsids, 
#                          mart = snp_mart)
# 
# save(coordinates_raw, file = "../data/hm3/rsid.coordinates.RData")

load("../data/hm3/rsid.coordinates.RData")

coordinates <- data.frame(
  "CHROM" = coordinates_raw$chr_name,
  "POS" = coordinates_raw$chrom_start,
  "ID" = coordinates_raw$refsnp_id
)

coordinates <- coordinates[with(coordinates, order(CHROM, POS)), ]

idx <- coordinates$CHROM %in% 1:22
coordinates <- coordinates[idx,]

write.table(coordinates,
            file = "../data/hm3/rsid.coordinates.hg19.tsv",
            quote = F,
            sep = "\t",
            row.names = F)

for(chr in 1:22) {
  idx <- coordinates$CHROM == chr
  write.table(coordinates[idx,],
              file = paste0("../data/hm3/chr", as.character(chr), ".rsid.coordinates.hg19.tsv"),
              quote = F,
              sep = "\t",
              col.names = T,
              row.names = F)
  write.table(coordinates[idx,1:2],
              file = paste0("../data/hm3/chr", as.character(chr), ".rsid.coordinates.hg19.regions"),
              quote = F,
              sep = "\t",
              row.names = F,
              col.names = F)
}
