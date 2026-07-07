setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(data.table)

for(POP in c("AFR", "AMR", "EAS", "EUR", "SAS")) {
  objname <- paste0(POP, "_ldscores_new")
  for(CHR in 1:22) {
    filename <- paste0("../results/ldscores/", POP, "/", CHR, ".l2.ldscore.gz")
    df <- fread(filename)
    colnames(df) <- c("CHR", "SNP", "BP", paste0("L2_", POP))
    if(CHR == 1) {
      assign(objname, df)
    } else {
      assign(objname, rbind(get(objname), df))
    }
  }
}

ldscores <- AFR_ldscores_new
for(POP in c("AMR", "EAS", "EUR", "SAS")) {
  ldscores <- merge(
    ldscores, 
    get(paste0(POP, "_ldscores_new")),
    all = FALSE,
    sort = FALSE)
}

ldscores$L2_MEAN <- rowMeans(ldscores[,4:8], na.rm = T)

weights <- c(9358, 1114, 2831, 465060, 10014) / 488377
ldscores$L2_MEAN_WEIGHTED <- apply(ldscores[,4:8], 1, FUN = function(x) {
  sum(as.vector(unlist(x)) * weights)
})

gzf <- gzfile("../results/ldscores.all.plusMean.tsv.gz", "w")
write.table(
  ldscores,
  file = gzf,
  quote = F,
  sep = "\t",
  row.names = F
)

dir.create("../results/ldscores/MEAN")
for(chr in 1:22) {
  gzf <- gzfile(paste0("../results/ldscores/MEAN/", chr, ".l2.ldscore.gz"))

  sub <- subset(ldscores, subset = CHR == chr, select = c("CHR", "SNP", "BP", "L2_MEAN"))
  colnames(sub)[4] <- "L2"
  
  write.table(
    sub,
    gzf,
    row.names = F,
    quote = F,
    sep = "\t")
  
  f <- file(paste0("../results/ldscores/MEAN/", chr, ".l2.M"))
  writeLines(as.character(nrow(sub)), f)
  close(f)
}

dir.create("../results/ldscores/WEIGHTED_MEAN")
for(chr in 1:22) {
  gzf <- gzfile(paste0("../results/ldscores/WEIGHTED_MEAN/", chr, ".l2.ldscore.gz"))
  
  sub <- subset(ldscores, subset = CHR == chr, select = c("CHR", "SNP", "BP", "L2_MEAN_WEIGHTED"))
  colnames(sub)[4] <- "L2"
  
  write.table(
    sub,
    gzf,
    row.names = F,
    quote = F,
    sep = "\t")
  
  f <- file(paste0("../results/ldscores/WEIGHTED_MEAN/", chr, ".l2.M"))
  writeLines(as.character(nrow(sub)), f)
  close(f)
}

