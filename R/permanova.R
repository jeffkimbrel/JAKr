#' Permanova (adonis) and visualization
#'
#' @param phyloObject A phyloseq object
#' @param group A column name from the phyloseq object sample data to group samples for comparison
#' @param metric The distance metric to use
#' @param palettePick A palette object if you don't want to use the default
#' @param ordPoints X,Y points to use. If none given, then an NMDS will be run
#'
#' @export

permanova = function(phyloObject, group = "TYPE", metric = "jsd", ordPoints = "none") {

  require("vegan")

  sd = data.frame(sample_data(phyloObject))
  sd = sd[group]
  colnames(sd) = "GROUP"

  #palette = ""
  #if (palettePick[1] == FALSE) {
  #  colorCount = length(unique(sd$GROUP))
  #  palette = getPalette(colorCount)
  #} else{
  #  palette = palettePick
  #}

  distJSD = phyloseq::distance(phyloObject, metric)
  adon.GROUP = adonis(distJSD ~ GROUP, sd)
  GROUP.p = adon.GROUP$aov.tab$`Pr(>F)`[1]

  ord = ordPoints

  if (ord[1] == "none") {
    ord = as.data.frame(ordinate(phyloObject, "NMDS", metric)$points)
  }

  df = cbind(ord, sd)
  df$SAMPLE = rownames(df)

  df.x = aggregate(MDS1 ~ GROUP, data = df, mean)
  colnames(df.x) = c("GROUP", "Xmean")

  df.y = aggregate(MDS2 ~ GROUP, data = df, mean)
  colnames(df.y) = c("GROUP", "Ymean")

  df = left_join(df, df.x, by = "GROUP")
  df = left_join(df, df.y, by = "GROUP")

  p1 = ggplot(df, aes(x = MDS1, y = MDS2)) +
    jak_theme() +
    geom_segment(aes(x = Xmean, y = Ymean, xend = MDS1, yend = MDS2, color = GROUP)) +
    geom_point(pch = 21, color = "black", size = 3, aes(fill = GROUP)) +
    #scale_fill_manual(values = palette) +
    #scale_color_manual(values = palette) +
    theme(legend.position = "bottom")

  list("plot" = p1,
       "pval" = GROUP.p,
       "group" = group,
       "metric" = metric,
       "df" = df)
}
