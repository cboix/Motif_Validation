- motifDist:Distribution for motif enrichment rank for mixture model
- TF_validatability.txt: the chance of making accept/reject decision by simulation, if the motif is very specific, then it will be high validatability
- TrainSetInfo.txt: the list of previous ChIP-seq datasets from cistrome database are used in the training the mixture model parameters
- badRankMotif.txt: the motif has lower enrichment in the corresponding TF ChIP-seq datasets than average enrichment other TF ChIP-seq datasets, usually means those motifs are wrong or non-specific
- gene2Protein.txt: mapping gene name to TF name, because some TF like AP-1 has several sub-unit corresponding to several genes and several antibodies
- lazyload.min.js: javascript for load the image on demand
- motifs-clust-names.txt: the information of 282 motif clusters
- name-mapping.txt: mapping ENCODE ChIP-seq file name to HGNC gene name
- uniqueMotif: the list of motifs in consider
