
##
## DEFINE FUNCTIONS
##

cluster.meth.diff <- function(DNAme.mat=NULL,
                              IGHV_identity.column=NULL,
                              UCLL.cutoff=100,
                              MCLL.cutoff=95,
                              delta=0.5,
                              top.Up.Down.CpGs=100){
  
  stopifnot(!is.null(DNAme.mat))
  stopifnot(!is.matrix(DNAme.mat) | !is.data.frame(DNAme.mat))
  stopifnot(IGHV_identity.column %in% colnames(Samples.metadata))
  stopifnot(all(colnames(DNAme.mat) %in% Samples.metadata[,Sample_id.column]))
  
  
  if(!is.null(IGHV_identity.column)){
    message("[cluster.meth.diff] Performing differential analyses.")
    UCLLs <- Samples.metadata$Sample_id[which(Samples.metadata[,IGHV_identity.column]>=UCLL.cutoff)]
    MCLLs <- Samples.metadata$Sample_id[which(Samples.metadata[,IGHV_identity.column]<=MCLL.cutoff)]
    Groups <- factor(c(rep("UCLLs",length(UCLLs)),
                       rep("MCLLs",length(MCLLs))),levels = c("UCLLs","MCLLs")
    )
    res <- rowttests(x = as.matrix(DNAme.mat[,c(UCLLs,MCLLs)]),
                     fac = Groups
    )
    res <- res[which(abs(res$dm)>=delta),]
    res <- res[order(res$dm,decreasing = T),]
    if(nrow(res)>=200){
      res <- rbind(head(res,top.Up.Down.CpGs),
                   tail(res,top.Up.Down.CpGs)
      )
      res <- res[!duplciated(res),]
    }
    res <- as.matrix(DNAme.mat[rownames(res),])
  }else{
    message("[cluster.meth.diff] Finding most variable CpGs. Ignoring 'delta' and 'IGHV' cutoffs.")
    res <- DNAme.mat[,colnames(DNAme.mat)[match(Samples.metadata[,Sample_id.column],colnames(DNAme.mat))]]
    row.sd <- rowSds(as.matrix(res))
    res <- head(res[order(row.sd,decreasing = T),],top.Up.Down.CpGs*2)
    res <- res[!duplicated(res),]
  }
  
  attributes(res) <- c(attributes(res),
                       meth.diff=T
  )
  return(res)
}


cluster.search <- function(DNAme.mat.meth.diff=NULL,
                           N.permut=500,
                           maxK=7,
                           plot=NULL){
  d <- DNAme.mat.meth.diff
  stopifnot(!is.null(d))
  stopifnot(any(names(attributes(d))=="meth.diff"))
  if(!is.null(plot)){
    plot <- match.arg(arg = plot, choices = c("pdf","png","pngBMP")) 
  }
  maxK <- as.numeric(match.arg(arg = as.character(maxK),choices = paste0(4:10)))
  
  if(N.permut>10000){
    warnings("N.permut set to 10000.")
    N.permut <- 10000
  }
  
  message("[cluster search] Performing consensus clustering.")
  cons.clust <- ConsensusClusterPlus(d=d,
                                     maxK=maxK,
                                     writeTable = T,
                                     reps = N.permut,
                                     title = "Clusters",
                                     seed=6,
                                     plot=plot
  )
  #calculate class probabilities
  icl = calcICL(cons.clust,
                title="Clusters",
                writeTable = T,
                plot=plot)
  return(list(cons.clust=cons.clust,
              icl=icl
  )
  )
}


cluster.assing <- function(k.clusters=NULL,
                           k=3,
                           IGHV_identity.column = NULL){
  
  stopifnot(!is.null(k.clusters))
  stopifnot(all(names(k.clusters) %in% c("cons.clust","icl")))
  k <- as.character(k)
  k <- as.numeric(match.arg(arg = k, choices = c(2,3)))
  if(k!=3){
    warning("Please, note that uncertainity in predictions is only analyzed when k is 3.") 
  }
  
  cons.clust <- k.clusters$cons.clust
  icl <- k.clusters$icl
  
  CLL.epitypes <- icl$itemConsensus[which(icl$itemConsensus$k==k),]
  all.indxs <- split(seq_len(nrow(CLL.epitypes)),factor(CLL.epitypes$item,levels = unique(CLL.epitypes$item)))
  
  ## Assing epitypes based on max probabilities and uncertainties
  CLL.epitypes <- lapply(all.indxs,function(indx){
    dat <- CLL.epitypes[indx,]
    Suggested.cluster <- dat$cluster[which.max(dat$itemConsensus)]
    k.probs <- lapply(seq_along(dat$cluster),function(cluster.i){
      res <- data.frame(dat$itemConsensus[cluster.i])
      colnames(res) <- paste0("P.k",cluster.i)
      return(res)
    })
    k.probs <- do.call(cbind,k.probs)
    
    dat <- data.frame(Sample_id=unique(dat$item),
                      Raw.prediction = cons.clust[[k]]$consensusClass[unique(dat$item)],
                      k.probs
    )
    dat$Suggested <- as.character(Suggested.cluster)
    if(k==3){
      dat$Suggested <- 
        ifelse(max(dat[,grep("P.k",colnames(dat))])<0.5 | sum(dat[,grep("P.k",colnames(dat))]>0.35)>1,
               "unclassified",
               dat$Suggested
        )
    }
    return(dat)
  })
  
  CLL.epitypes <- do.call(rbind,CLL.epitypes)
  colnames(CLL.epitypes) <- paste0(colnames(CLL.epitypes),".cluster")
  CLL.epitypes <- cbind(Samples.metadata,CLL.epitypes[match(Samples.metadata[,Sample_id.column],CLL.epitypes$Sample_id.cluster),])
  CLL.epitypes <- CLL.epitypes[,grep("^Sample_id.cluster$",colnames(CLL.epitypes),invert = T)]
  
  ## Name clusters in case IGHV is available
  if(!is.null(IGHV_identity.column) & k==3){
    stopifnot(is.character(IGHV_identity.column))
    stopifnot(IGHV_identity.column %in% colnames(Samples.metadata))
    
    tab <- as.matrix(table(cut(CLL.epitypes[,IGHV_identity.column],breaks = c(0,96,99,100)),
                           CLL.epitypes$Suggested.cluster))
    tab <- tab[,paste0(1:3)]
    epitypes <- structure(c("n-CLL","i-CLL","m-CLL"),
                          names=c(colnames(tab)[which.max(tab["(99,100]",])],
                                  colnames(tab)[which.max(tab["(96,99]",])],
                                  colnames(tab)[which.max(tab["(0,96]",])])
    )
    CLL.epitypes$Suggested.epitype <- epitypes[CLL.epitypes$Suggested.cluster]
    CLL.epitypes$Suggested.epitype[which(CLL.epitypes$Suggested.cluster=="unclassified")] <- "unclassified"
  }
  
  return(CLL.epitypes)
}
