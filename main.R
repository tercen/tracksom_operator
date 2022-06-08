library(tercen)
# library(tercenApi)
library(dplyr)
library(TrackSOM)
library(data.table)
# options("tercen.workflowId"= "c9b128311c1a99b2e1248092ef00d5a0")
# options("tercen.stepId"= "d235974b-f9f1-4b53-be1a-26f4195dd32d")

ctx = tercenCtx()

seed <- NULL
if(!is.null(ctx$op.value('seed')) && !ctx$op.value('seed') < 0) seed <- as.integer(ctx$op.value('seed'))

set.seed(seed)

nclust <- NULL
if(!is.null(ctx$op.value('nclust')) && !ctx$op.value('nclust') == "NULL") nclust <- as.integer(ctx$op.value('nclust'))
maxMeta <- NULL
if(!is.null(ctx$op.value('maxMeta')) && !ctx$op.value('maxMeta') == "NULL") maxMeta <- as.integer(ctx$op.value('maxMeta'))

if(is.null(maxMeta) & is.null(nclust)) maxMeta <- 10

tracking  = ifelse(is.null(ctx$op.value('tracking')), TRUE, as.logical(ctx$op.value('tracking')))
if(!tracking) tracking <- NULL
noMerge   = ifelse(is.null(ctx$op.value('noMerge')), FALSE, as.logical(ctx$op.value('noMerge')))

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

mat <- ctx %>% 
  as.matrix() %>%
  t() 

colnames(mat) <- ctx$rselect()[[1]]
df <- as_tibble(mat) %>%
  mutate(.ci = seq_len(nrow(.)) - 1)

col1_values <- ctx$cselect()[[1]]
timepoints <- unique(col1_values)

df_list <- lapply(timepoints, function(x) {
  cond <- col1_values == x
  df_tmp <- df %>%
    filter(cond) %>%
    mutate(timepoint = x)
  df_tmp <- data.table::data.table(df_tmp)
  return(df_tmp)
})

tracksom.result <- TrackSOM(
  inputFiles = df_list,
  colsToUse = colnames(df_list[[1]])[!colnames(df_list[[1]]) %in% c("timepoint", ".ci")],
  tracking = tracking,
  noMerge = noMerge,
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
  mutate(
    cluster_number = as.integer(cluster_id), 
    metacluster_number = as.integer(metacluster_id)
  ) %>%
  ctx$addNamespace() %>%
  ctx$save()


