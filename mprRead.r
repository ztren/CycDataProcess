#!/usr/bin/env Rscript EDA0050_SYM_3_20240816_Na_NP25_GFC_1mA_Brushed_CD8.mpr
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  cat("Filename:\n")
  args <- readLines("stdin", n = 1)
} else if (length(args) > 1) {
  stop("Too many arguments.", call. = FALSE)
}
Data <- Echem.Data:::load.biologic.mpr(paste("Data/", args[1], sep = ""))
Filename <- gsub(".mpr", "", args[1])
write.csv(Data, file(paste("Data/", Filename, ".csv", sep = "")))