## Helper script

## Load libraries
library(dplyr)
library(ggplot2)
library(spocc)
library(gatoRs)


## Format spocc
spocc_data <- spocc::occ2df(spocc::occ(query = c("Galax urceolata", "Galax aphylla"),
                                       from = c("gbif", "idigbio"), limit = 10000))
sch <- spocc_data %>%
       group_by(prov) %>%
       summarize(count = n())
sch$package <- "spocc"
colnames(sch) <- c("aggregator", "count", "package")
sch$aggregator[sch$aggregator == "gbif"] <- "GBIF"
sch$aggregator[sch$aggregator == "idigbio"] <- "iDigBio"

## Format gatoRs
gatoRs_data  <- gators_download(synonyms.list = c("Galax urceolata", "Galax aphylla"))
gch <- gatoRs_data %>%
       group_by(aggregator) %>%
       summarize(count = n())
gch$package <- "gatoRs"

## Format rgbif and ridigbio
dach <- data.frame(aggregator = c("GBIF", "iDigBio"),
                   count = c(7097, 1692),
                   package = c("rgbif", "ridigbio"))

# Combined and factor
spgp <- rbind(sch, gch, dach)
spgp$package <- factor(spgp$package, levels = c("rgbif", "ridigbio", "spocc", "gatoRs"))

## Plot
ggplot(spgp, aes(y = factor(package), x = count)) +
  geom_bar(position="stack", stat = "identity",
           mapping = aes(fill = factor(package),
                         color = factor(package),
                         alpha=factor(aggregator))) +
  scale_fill_manual(values = c( "#cbb61cff", "#5fad43ff",
                                "#0021A5","#FC8161"))+
  scale_color_manual(values = c( "#cbb61cff", "#5fad43ff",
                                 "#0021A5","#FC8161"))+
  ylab("")+
  xlab("Records Downloaded") +
  theme_bw() +
  theme(legend.position = "none",
        text = element_text(size = 12),
        axis.text = element_text(size = 12))
