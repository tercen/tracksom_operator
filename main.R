library(tercen)
library(tercenApi)
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
maxMeta <- NULL
if(!is.null(ctx$op.value('maxMeta')) && !ctx$op.value('maxMeta') == "NULL") maxMeta <- as.integer(ctx$op.value('maxMeta'))

if(is.null(maxMeta) & is.null(nclust)) maxMeta <- 10

xdim   = ifelse(is.null(ctx$op.value('xdim')), 10, as.integer(ctx$op.value('xdim')))
ydim   = ifelse(is.null(ctx$op.value('ydim')), 10, as.integer(ctx$op.value('ydim')))
rlen   = ifelse(is.null(ctx$op.value('rlen')), 10, as.integer(ctx$op.value('rlen')))
mst    = ifelse(is.null(ctx$op.value('mst')), 1, as.integer(ctx$op.value('mst')))
alpha  = c(
  ifelse(is.null(ctx$op.value('alpha_1')), 0.05, as.double(ctx$op.value('alpha_1'))),
  ifelse(is.null(ctx$op.value('alpha_2')), 0.01, as.double(ctx$op.value('alpha_2')))
)
distf  = ifelse(is.null(ctx$op.value('distf')), 2, as.integer(ctx$op.value('distf')))


stopifnot("Two factors need to be projected onto columns." = ncol(ctx$cselect()) == 2)

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
  nClus = nclust,
  xdim = xdim,
  ydim = ydim,
  maxMeta = maxMeta,
  rlen = rlen,
  mst = mst,
  alpha = alpha,
  distf = distf,
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


