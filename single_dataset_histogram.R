#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(argparse)

theme_set(theme_bw(base_size=12) + theme(
    legend.key.size=unit(1, 'lines'),
    text=element_text(face='plain', family='CM Roman'),
    legend.title=element_text(face='plain'),
    axis.line=element_line(color='black'),
    axis.title.y=element_text(vjust=0.1),
    axis.title.x=element_text(vjust=0.1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.key = element_blank(),
    panel.border = element_blank()
))

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

print(visibility_histogram)
print(absorption_histogram)
print(ratio_histogram)
print(dark_field_histogram)

width = 7
factor = 1
height = width * factor
ggsave("plots/visibility.png", visibility_histogram, width=width, height=height, dpi=300)
ggsave("plots/absorption.png", absorption_histogram, width=width, height=height, dpi=300)
ggsave("plots/ratio.png", ratio_histogram, width=width, height=height, dpi=300)
ggsave("plots/darkfield.png", dark_field_histogram, width=width, height=height, dpi=300)

invisible(readLines(con="stdin", 1))
