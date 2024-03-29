

##
## create boost vec
## using information on induction time
## global refits, and which TFs have nucloc data
## 

annot.dir <- file.path(Sys.getenv("TFINF"),"annotations")
ddata.dir <- file.path(Sys.getenv("TFINF"),"derived_data")

load(paste(annot.dir,"tteMaps.RData",sep="/"))
load(paste(annot.dir,"TFcategories.RData",sep="/"))
load(paste(annot.dir,"representativeProbes.RData",sep="/"))
load(paste(ddata.dir,"boost.vec.refit.RData",sep="/"))
##load("./jared.tfs.expressed.RData")

##target.pull <- 60

array.times <- c(0,20,40,60,80,120,240,360,480,1080,1440)

t.index.max <- 11

input.boost.time <- 60

##inputs.boosted <- matrix(nrow=length(transfac.tfs.expressed),ncol=t.index.max)
##rownames(inputs.boosted) <- transfac.tfs.expressed
##for ( psoii in transfac.tfs.expressed ){
##  inputs.boosted[psoii,] <- approx(array.times,lps.mat.max1[psoii,],array.times-input.boost.time,rule=2)$y
##}

boost.vec <- rep(input.boost.time,length(transfac.tfs.expressed))
names(boost.vec) <- transfac.tfs.expressed


early.tfs <- names(halfChangeAt[halfChangeAt %in% c("min20","min40","min60","min80")])
mid.tfs <- names(halfChangeAt[halfChangeAt %in% c("min120","hr2","hr4")])
late.tfs <- names(halfChangeAt[halfChangeAt %in% c("hr6","hr8","hr18","hr24")])
boost.vec[early.tfs] <- 0
boost.vec[mid.tfs] <- 30
boost.vec[late.tfs] <- 60

##targ.exp.pulled <- approx(array.times,lps.mat.max1[targ,],array.times+target.pull,rule=2)$y

## For some input variables, use the nuclear protein
## 
## For now, use no 'boost' time

nucloc.input.set <- c("Rel","Atf3","Egr1","Egr2","Fos","Rela")
for ( coi in nucloc.input.set ){
  boost.vec[repProbes.cname[coi]] <- 0
}


## insert globally fitted boost time where known
if ( !is.null(boost.vec.refit) ){
  boost.vec[names(boost.vec.refit)] <- boost.vec.refit
}

## June 2007

## For randomization trials,  create a boost.vec for other TFS

#addeds <- setdiff(jared.tfs.expressed,transfac.tfs.expressed )
#boost.vec.addeds <- rep(60,length=length(addeds))
#names(boost.vec.addeds) <- addeds
#boost.vec <- c(boost.vec,boost.vec.addeds)

save(boost.vec,file=paste(ddata.dir,"boost.vec.RData",sep="/"))

##boost.vec.mat <- sortRows(cbind(cc[names(boost.vec)],ncbiID[names(boost.vec)],names(boost.vec),boost.vec),1)
##colnames(boost.vec.mat) <- c("MGNC","EntrezID","Probeset","Delay")
##write.table(boost.vec.mat,file="TFDelays.tsv",quote=FALSE,row.names=FALSE,sep='\t')
