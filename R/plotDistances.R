#' Boxplot of Beta-diversity Distances
#'
#' Takes a `phyloseq` object with samples grouped in the sample data, calculates all pairwise beta-diversity metrics, and plots the distances in facets.
#'
#' @param p A phyloseq object
#' @param m Distance metric
#' @param s Column name with sample IDs
#' @param d Grouping for comparisons
#' @param plot Set to true to include a boxplot of the distances
#'
#' @export

plotDistances = function(p = GlobalPatterns, m = "wunifrac", s = "X.SampleID", d = "SampleType", plot = TRUE) {

  require("phyloseq")
  require("dplyr")
  require("reshape2")
  require("ggplot2")

  # calc distances
  wu = phyloseq::distance(p, m)
  wu.m = melt(as.matrix(wu))

  # remove self-comparisons
  wu.m = wu.m %>%
    filter(as.character(Var1) != as.character(Var2)) %>%
    mutate_if(is.factor, as.character)

  # get sample data (S4 error OK and expected)
  sd = sample_data(p) %>%
    select(s, d) %>%
    mutate_if(is.factor,as.character)

  # combined distances with sample data
  colnames(sd) = c("Var1", "Type1")
  wu.sd = left_join(wu.m, sd, by = "Var1")

  colnames(sd) = c("Var2", "Type2")
  wu.sd = left_join(wu.sd, sd, by = "Var2")

  # plot
  p = ggplot(wu.sd, aes(x = Type2, y = value)) +
    theme_bw() +
    geom_point() +
    geom_boxplot(aes(color = ifelse(Type1 == Type2, "red", "black"))) +
    scale_color_identity() +
    facet_wrap(~ Type1, scales = "free_x") +
    theme(axis.text.x=element_text(angle = 90, hjust = 1, vjust = 0.5)) +
    ggtitle(paste0("Distance Metric = ", m)) +
    ylab(m) +
    xlab(d)

  # return
  if (plot == TRUE) {
    return(p)
  } else {
    return(wu.sd)
  }
}
