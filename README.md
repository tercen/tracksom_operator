# TrackSOM operator

##### Description

`TrackSOM`: An algorithm that clusters cells based on chosen channels and maps them into populations.

##### Usage

Input projection|.
---|---
`column1`   | represents the timepoint (e.g. measurement day)
`column2`   | represents the variables (e.g. channels, markers)
`col`   | represents the clusters (e.g. cells) 
`y-axis`| is the value of measurement signal of the channel/marker

Input parameters|.
---|---
`nclust`   | Number of clusters to make (default = `NULL`)
`maxMeta`   | Maximal number of cluster (ignored if `nclust` is not `NULL`)
`seed`   | Random seed
`xdim`   | Width of the grid
`ydim`   | Hight of the grid
`rlen`| Number of times to loop over the training data for each MST
`mst`| Number of times to build an MST
`alpha_start`| Start learning rate
`alpha_end`|  End learning rate
`distf`| Distance function (1=manhattan, 2=euclidean, 3=chebyshev, 4=cosine)


Output relations|.
---|---
`cluster_id`| character, cluster ID
`metacluster_id`| character, metacluster ID
`metacluster_lineage_tracking`| character, metacluster lineage tracking

##### Details

The operator is a wrapper for the `TrackSOM` function of the `TrackSOM` [R package](https://github.com/ghar1821/TrackSOM). 

##### See Also

[flowsom_operator](https://github.com/tercen/flowsom_operator)
