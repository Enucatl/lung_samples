#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(argparse)
commandline_parser = ArgumentParser(
        description="merge the datasets into one data.table")
commandline_parser$add_argument('-f', '--file',
            type='character', nargs='?', default='reconstructed.csv',
            help='file with the data.table')
commandline_parser$add_argument('-o', '--output',
            type='character', nargs='?', default='data/pixels.rds',
            help='file with all the pixels')
args = commandline_parser$parse_args()

table = readRDS(args$f)[v > 0.05]

print(table)

visibility_histogram = ggplot(table, aes(x=v, fill=name)) + geom_density(alpha=0.2)
absorption_histogram = ggplot(table, aes(x=A, fill=name)) + geom_density(alpha=0.2)
dark_field_histogram = ggplot(table, aes(x=B, fill=name)) + geom_density(alpha=0.2)
ratio_histogram = ggplot(table, aes(x=R, fill=name)) +
    geom_density(alpha=0.2) +
    scale_x_continuous(limits = c(0, 4))

#print(visibility_histogram)
#print(absorption_histogram)
#print(ratio_histogram)
print(dark_field_histogram)

invisible(readLines(con="stdin", 1))
