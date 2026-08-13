#!/usr/bin/env Rscript

if (!require("data.table", warn.conflicts = F, quietly = TRUE)) { install.packages("data.table", repos="https://www.stats.bris.ac.uk/R/"); library(data.table, quietly = TRUE, warn.conflicts = FALSE) }
if (!require("optparse", warn.conflicts = F, quietly = TRUE)) { install.packages("optparse", repos="https://www.stats.bris.ac.uk/R/"); library(optparse, quietly = TRUE, warn.conflicts = FALSE) }


parser <- OptionParser(
  formatter = IndentedHelpFormatter,
  description = "
Write mean LDscores for multiple ancestries, weighted by sample sizes
",
  usage = "If using the scores from this repository, provide --build and sample sizes [--nafr, --namr, etc.]
for at least two populations.

Otherwise you can provide paths to any (AFR, AMR, EAS, EUR or SAS) scores using the --pX flags + your
desired sample sizes"
)

parser <- add_option(
  parser, "--build", help = "Genome build: GRCh37 or GRCh38", type = "character", required = FALSE, default = NULL,
  callback = function(option, flag, value, parser) {
    if(value == "GRCh37" || value == "GRCh38" || is.null(value) ) { return(value) }
    cat("Error: --build must be one of {GRCh37, GRCh38}\n")
    quit(save = "no", status = 1)
  }  
)
parser <- add_option(parser, "--nafr", help = "Number of samples with AFR ancestry", type = "integer", default = as.integer(0))
parser <- add_option(parser, "--namr", help = "Number of samples with AMR ancestry", type = "integer", default = as.integer(0))
parser <- add_option(parser, "--neas", help = "Number of samples with EAS ancestry", type = "integer", default = as.integer(0))
parser <- add_option(parser, "--neur", help = "Number of samples with EUR ancestry", type = "integer", default = as.integer(0))
parser <- add_option(parser, "--nsas", help = "Number of samples with SAS ancestry", type = "integer", default = as.integer(0))

parser <- add_option(parser, "--pafr", help = "Path to LDscores for AFR ancestry", type = "character")
parser <- add_option(parser, "--pamr", help = "Path to LDscores for AMR ancestry", type = "character")
parser <- add_option(parser, "--peas", help = "Path to LDscores for EAS ancestry", type = "character")
parser <- add_option(parser, "--peur", help = "Path to LDscores for EUR ancestry", type = "character")
parser <- add_option(parser, "--psas", help = "Path to LDscores for SAS ancestry", type = "character")

parser <- add_option(parser, "--outdir", help = "name of output folder to write weighted mean ldscores to", type = "character")

args <- parse_args(parser)

if(is.null(args$build)) {
  if(sum(sapply(c(args$pafr, args$pamr, args$peas, args$peur, args$psas), function(x) { length(x) != 0 }) < 2 )) {
    cat("Error: if you don't provide --build, you must provide at least 2 paths to population-specific LDscores")
    quit(save = "no", status = 1)
  }
} else {
  args$pafr <- file.path(args$build, "results", "ldscores", "AFR")
  args$pamr <- file.path(args$build, "results", "ldscores", "AMR")
  args$peas <- file.path(args$build, "results", "ldscores", "EAS")
  args$peur <- file.path(args$build, "results", "ldscores", "EUR")
  args$psas <- file.path(args$build, "results", "ldscores", "SAS")
}

RETAINED_POPS <- list(
  list(name = "AFR", path = args$pafr, n = args$nafr),
  list(name = "AMR", path = args$pamr, n = args$namr),
  list(name = "EAS", path = args$peas, n = args$neas),
  list(name = "EUR", path = args$peur, n = args$neur),
  list(name = "SAS", path = args$psas, n = args$nsas)
)[sapply(c(args$nafr, args$namr, args$neas, args$neur, args$nsas), FUN = function(x) { x != 0 } )]

for(POP in RETAINED_POPS) {
  objname <- paste0(POP["name"], "_ldscores_new")
  for(CHR in 1:22) {
    filename <- file.path(POP["path"], paste0(CHR, ".l2.ldscore.gz"))
    df <- fread(filename)
    colnames(df) <- c("CHR", "SNP", "BP", paste0("L2_", POP["name"]))
    if(CHR == 1) {
      assign(objname, df)
    } else {
      assign(objname, rbind(get(objname), df))
    }
  }
}

ldscores <- get(paste0(RETAINED_POPS[[1]]["name"], "_ldscores_new"))
for(POP in RETAINED_POPS[2:length(RETAINED_POPS)]) {
  ldscores <- merge(
    ldscores, 
    get(paste0(POP["name"], "_ldscores_new")),
    all = FALSE,
    sort = FALSE)
}

n <- as.vector(unlist(sapply(RETAINED_POPS, FUN = function(x) return(x["n"]) )))
d <- sum(n)
weights <- n / d
ldscores$L2_MEAN_WEIGHTED <- apply(ldscores[,4:(4+length(RETAINED_POPS)-1)], 1, FUN = function(x) {
  sum(as.vector(unlist(x)) * weights)
})

if(!dir.exists(args$outdir)) {
  dir.create(args$outdir, recursive = TRUE)
}
for(chr in 1:22) {
  gzf <- gzfile(file.path(args$outdir, paste0(chr, ".l2.ldscore.gz")))
  
  sub <- subset(ldscores, subset = CHR == chr, select = c("CHR", "SNP", "BP", "L2_MEAN_WEIGHTED"))
  colnames(sub)[4] <- "L2"
  
  write.table(
    sub,
    gzf,
    row.names = F,
    quote = F,
    sep = "\t")
  
  f <- file(file.path(args$outdir, paste0(chr, ".l2.M")))
  writeLines(as.character(nrow(sub)), f)
  close(f)
}

