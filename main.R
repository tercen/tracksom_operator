library(tercen)
library(dplyr)
library(TrackSOM)
library(data.table)
# options("tercen.workflowId"= "7132ce367ee5df28fea4032b3f011888")
# options("tercen.stepId"= "426b00e4-b970-4042-9a53-93a10ac2da90")

ctx = tercenCtx()

seed <- NULL
if(!is.null(ctx$op.value('seed')) && !ctx$op.value('seed') < 0) seed <- as.integer(ctx$op.value('seed'))

set.seed(seed)

nclust <- NULL
if(!is.null(ctx$op.value('nclust')) && !ctx$op.value('nclust') == "NULL") nclust <- as.integer(ctx$op.value('nclust'))

stopifnot("Two factors need to be projected onto columns." = ncol(ctx$cselect()) == 2)

ctx$colors

df <- ctx %>% 
  as.matrix() %>%
  t() 

colnames(df) <- ctx$rselect()[[1]]
df <- data.table::data.table(df)
df[[".ci"]] <- seq_len(nrow(df)) - 1

timepoints <- unique(ctx$cselect()[[1]])

df_list <- lapply(timepoints, function(x) {
  df_tmp <- df[ctx$cselect()[[1]] %in% x, ]
  df_tmp[["timepoint"]] <- x
  return(df_tmp)
})

tracksom.result <- TrackSOM(
  inputFiles = df_list,
  colsToUse = colnames(df_list[[1]])[!colnames(df_list[[1]]) %in% c("timepoint", ".ci")],
  tracking = TRUE,
  noMerge = TRUE,
  nClus = NULL,
  maxMeta = 10,
  dataFileType = "data.frame"
)

df_cat <- data.table::rbindlist(df_list)

df_out <- ExportClusteringDetailsOnly(tracksom.result)
df_out[[".ci"]] <- seq_len(nrow(df_out)) - 1

df_out %>%
  rename(
    cluster_id = TrackSOM_cluster,
    metacluster_id = TrackSOM_metacluster,
    metacluster_lineage_tracking = TrackSOM_metacluster_lineage_tracking
  ) %>%
  ctx$addNamespace() %>%
  ctx$save()


