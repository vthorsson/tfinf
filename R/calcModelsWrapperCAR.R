##
## June 2008
## Pipeline from pdna objects to model fitted objects for Cytokine and Receptor subset
##

library(lars)
library(lasso2)
library(odesolve)

source("./utilitiesTAC.R")
source("./utilitiesFiniteDiff3D.R")
source("./selectionUtilities.R")
source("./utilitiesODEsolve.R")
source("./analyticODE.R")
source("./utilitiesMods.R")
source("./matrixExtrema.R")

t.index.min <- 1
t.index.max <- 11
tau <- 600./log(2.)

annot.dir <- file.path(Sys.getenv("TFINF"),"annotations")
exp.dir <- file.path(Sys.getenv("TFINF"),"expression_data")
interact.dir <- file.path(Sys.getenv("TFINF"),"interaction_data")
seq.dir <- file.path(Sys.getenv("TFINF"),"sequence_data")
ddata.dir <- file.path(Sys.getenv("TFINF"),"derived_data")

load(paste(exp.dir,"scaled.mus.objects.RData",sep="/"))
load(paste(annot.dir,"representativeProbes.RData",sep="/"))
load(paste(annot.dir,"tteMaps.RData",sep="/"))
tte <- transfac.tfs.expressed
load(paste(ddata.dir,"boost.vec.RData",sep="/"))
load(paste(annot.dir,"annotation.objects.RData",sep="/"))
load(paste(exp.dir,"all.mus.objects.RData",sep="/"))
load(paste(interact.dir,"pdna.curated.RData",sep="/"))
load(paste(interact.dir,"pdnaModels.RData",sep="/"))


cytokines.eids <- read.table(file="~/data/GeneOntology/CytokineActivity.tsv",as.is=TRUE)$V1
cytokines.psois <- paste(cytokines.eids,"_at",sep="")
cytokinebinding.eids <- read.table(file="~/data/GeneOntology/CytokineBinding.tsv",as.is=TRUE)$V1
cytokinebinding.psois <- paste(cytokinebinding.eids,"_at",sep="")
car.psois <- c(cytokines.psois,cytokinebinding.psois)

##
## Filter pdnas
##
pdna.car.enrp.05 <- pdna.enrp.05[intersect(car.psois,names(pdna.enrp.05))]
pdna.car.enrp.01 <- pdna.enrp.01[intersect(car.psois,names(pdna.enrp.01))]
pdna.car.enrs.001 <- pdna.enrs.001[intersect(car.psois,names(pdna.enrs.001))]
pdna.car.hs.et.5 <- pdna.hs.et.5[intersect(car.psois,names(pdna.hs.et.5))]
pdna.car.hs.et.1 <- pdna.hs.et.1[intersect(car.psois,names(pdna.hs.et.1))]
pdna.car.hs.et.05 <- pdna.hs.et.05[intersect(car.psois,names(pdna.hs.et.05))]
pdna.car.hs.et.01 <- pdna.hs.et.01[intersect(car.psois,names(pdna.hs.et.01))]
pdna.car.hs.et.001 <- pdna.hs.et.001[intersect(car.psois,names(pdna.hs.et.001))]
pdna.car.curated <- pdna.curated[intersect(car.psois,names(pdna.curated))]

pdna.car.strings <- c("pdna.car.enrp.05","pdna.car.enrp.01","pdna.car.enrs.001",
                      "pdna.car.hs.et.5","pdna.car.hs.et.1","pdna.car.hs.et.05","pdna.car.hs.et.01",
                      "pdna.car.hs.et.001","pdna.car.curated")

save(list=pdna.car.strings,file=paste(interact.dir,"pdna.car.RData",sep="/"))
##
## Runc calcModels to get OLS solutions
##  

cat ("Starting calcModels runs \n")

mods.car.enrp.05 <- calcModels(pdna.car.enrp.05,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=2,zero.offset=TRUE,tau.estimate=TRUE)
mods.car.enrp.01 <- calcModels(pdna.car.enrp.01,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=2,zero.offset=TRUE,tau.estimate=TRUE)

mods.car.enrs.001 <- calcModels(pdna.car.enrs.001,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)

mods.car.hs.et.5 <- calcModels(pdna.car.hs.et.5,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)
mods.car.hs.et.1 <- calcModels(pdna.car.hs.et.1,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)
mods.car.hs.et.05 <- calcModels(pdna.car.hs.et.05,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)
mods.car.hs.et.01 <- calcModels(pdna.car.hs.et.01,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)
mods.car.hs.et.001 <- calcModels(pdna.car.hs.et.001,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)

mods.car.curated <- calcModels(pdna.car.curated,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)


mods.car.strings <- c("mods.car.enrp.05","mods.car.enrp.01","mods.car.enrs.001",
                      "mods.car.hs.et.5","mods.car.hs.et.1","mods.car.hs.et.05","mods.car.hs.et.01",
                      "mods.car.hs.et.001","mods.car.curated")

save(list=mods.car.strings,file=paste(ddata.dir,"models.car.precor.RData",sep="/"))

##
## For two-input cases, treat correlated inputs
##

tte.cormat <- cor(t(lps.mat.max1[tte,]))
tte.cormat[lower.tri(tte.cormat)] <- 0
diag(tte.cormat) <- 0
corTFPairs <- matrixExtrema(tte.cormat,cutoff=0.8,decreasing=TRUE)$pairs
anticorTFPairs <- matrixExtrema(-tte.cormat,cutoff=0.8,decreasing=TRUE)$pairs

cat ("Treating correlated inputs, for paired sites \n")

result.01 <- pairToSingleMods(mods.car.enrp.01,rbind(corTFPairs,anticorTFPairs))
mods.car.enrp.sansCorTFPairs.01 <- result.01$mods.pairs
pdna.car.singles.fromCorTFPairs.01 <- result.01$targsAndCands.singles
mods.car.singles.fromCorTFPairs.01 <- calcModels(pdna.car.singles.fromCorTFPairs.01,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)

result.05 <- pairToSingleMods(mods.car.enrp.05,rbind(corTFPairs,anticorTFPairs))
mods.car.enrp.sansCorTFPairs.05 <- result.05$mods.pairs
pdna.car.singles.fromCorTFPairs.05 <- result.05$targsAndCands.singles
mods.car.singles.fromCorTFPairs.05 <- calcModels(pdna.car.singles.fromCorTFPairs.05,t.index.min,t.index.max,tau,boost.vec,lps.mat.max1,n.cands=1,zero.offset=TRUE,tau.estimate=TRUE)


mods.car.strings <- c("mods.car.enrp.sansCorTFPairs.05","mods.car.singles.fromCorTFPairs.05",
                      "mods.car.enrp.sansCorTFPairs.01","mods.car.singles.fromCorTFPairs.01",
                      "mods.car.enrs.001",
                      "mods.car.hs.et.5","mods.car.hs.et.1","mods.car.hs.et.05","mods.car.hs.et.01",
                      "mods.car.hs.et.001","mods.car.curated")

save(list=mods.car.strings,file=paste(ddata.dir,"models.car.preshrinkage.RData",sep="/"))

##load("models.car.preshrinkage.RData")



##
## Model shrinkage
##

cat("Model shrinkage/selection begins\n") 
## ( This one takes a while, so use sparingly ! )
result.ss.01 <- shrinkageSelectModels(mods.car.enrp.sansCorTFPairs.01, t.index.min, t.index.max, tau=0, boost.vec,lps.mat.max1, n.cands=2, zero.offset=TRUE )
mods.car.enrp.dubs.01 <- result.ss.01$mods.pairs
mods.car.enrp.sings.01 <- result.ss.01$mods.singles

result.ss.05 <- shrinkageSelectModels(mods.car.enrp.sansCorTFPairs.05, t.index.min, t.index.max, tau=0, boost.vec,lps.mat.max1, n.cands=2, zero.offset=TRUE )
mods.car.enrp.dubs.05 <- result.ss.05$mods.pairs
mods.car.enrp.sings.05 <- result.ss.05$mods.singles


mods.car.strings <- c("mods.car.enrp.dubs.05","mods.car.enrp.sings.05","mods.car.singles.fromCorTFPairs.05",
                      "mods.car.enrp.dubs.01","mods.car.enrp.sings.01","mods.car.singles.fromCorTFPairs.01",
                      "mods.car.enrs.001",
                      "mods.car.hs.et.5","mods.car.hs.et.1","mods.car.hs.et.05","mods.car.hs.et.01",
                      "mods.car.hs.et.001","mods.car.curated")

save(list=mods.car.strings,file=paste(ddata.dir,"models.car.preode.RData",sep="/"))

##
## Non-linear ODE fitting
## 

cat("Beginning non-linear ODE fitting\n")

mods.car.enrp.dubs.01.ode <- computeODEModsAnalytic(mods.car.enrp.dubs.01,n.cands=2)
mods.car.enrp.sings.01.ode <- computeODEModsAnalytic(mods.car.enrp.sings.01,n.cands=1)
mods.car.singles.fromCorTFPairs.01.ode <- computeODEModsAnalytic( mods.car.singles.fromCorTFPairs.01, n.cands=1)

mods.car.enrp.dubs.05.ode <- computeODEModsAnalytic(mods.car.enrp.dubs.05,n.cands=2)
mods.car.enrp.sings.05.ode <- computeODEModsAnalytic(mods.car.enrp.sings.05,n.cands=1)
mods.car.singles.fromCorTFPairs.05.ode <- computeODEModsAnalytic( mods.car.singles.fromCorTFPairs.05, n.cands=1)  

mods.car.enrs.001.ode <- computeODEModsAnalytic(mods.car.enrs.001,n.cands=1)

mods.car.hs.et.5.ode <- computeODEModsAnalytic(mods.car.hs.et.5,n.cands=1)
mods.car.hs.et.1.ode <- computeODEModsAnalytic(mods.car.hs.et.1,n.cands=1)
mods.car.hs.et.05.ode <- computeODEModsAnalytic(mods.car.hs.et.05,n.cands=1)
mods.car.hs.et.01.ode <- computeODEModsAnalytic(mods.car.hs.et.01,n.cands=1)
mods.car.hs.et.001.ode <- computeODEModsAnalytic(mods.car.hs.et.001,n.cands=1)

mods.car.curated.ode <- computeODEModsAnalytic(mods.car.curated,n.cands=1)

mods.car.strings.ode <- paste(mods.car.strings,".ode",sep="")
save(list=mods.car.strings.ode,file=paste(ddata.dir,"models.car.ode.RData",sep="/"))

###
### RMSD filter
###

source("./randomTFs.R") ## Processes rmsd distributions from randomly selected TFs for each target
## input collection.1reg.RData, collection.2regs.RData
## produces rmsd thresholds like rands.1reg.0.05 and rands.2regs.0.05

cat("Fitering on RMSD\n")

mods.car.enrp.dubs.01.ode.rmsf <- filterModsByRMSD( mods.car.enrp.dubs.01.ode, rmsd.threshold=rands.2regs.0.05, rmsd.type="fullode", scale=FALSE,n.cands=2)
mods.car.curated.ode.rmsf <- filterModsByRMSD( mods.car.curated.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)
mods.car.hs.et.05.ode.rmsf <- filterModsByRMSD( mods.car.hs.et.05.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)
mods.car.hs.et.01.ode.rmsf <- filterModsByRMSD( mods.car.hs.et.01.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)
mods.car.hs.et.001.ode.rmsf <- filterModsByRMSD( mods.car.hs.et.001.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)
mods.car.enrs.001.ode.rmsf <- filterModsByRMSD( mods.car.enrs.001.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)
mods.car.singles.fromCorTFPairs.01.ode.rmsf <- filterModsByRMSD( mods.car.singles.fromCorTFPairs.01.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)
mods.car.enrp.sings.01.ode.rmsf <- filterModsByRMSD( mods.car.enrp.sings.01.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)

##mods.car.bind.ode.rmsf <- filterModsByRMSD( mods.car.bind.ode, rmsd.threshold=rands.1reg.0.05, rmsd.type="fullode", scale=FALSE,n.cands=1)

mods.car.rmsf.strings <- c("mods.car.curated.ode.rmsf","mods.car.hs.et.05.ode.rmsf","mods.car.hs.et.01.ode.rmsf","mods.car.hs.et.001.ode.rmsf","mods.car.enrs.001.ode.rmsf","mods.car.singles.fromCorTFPairs.01.ode.rmsf","mods.car.enrp.sings.01.ode.rmsf","mods.car.enrp.dubs.01.ode.rmsf")

save(list=mods.car.rmsf.strings,file=paste(ddata.dir,"models.car.rmsf.RData",sep="/"))

## This may be confusing. Fisrt 01 applies to .. , second to randomization scores
##mods.car.enrp.dubs.01.1.ode.rmsf <- filterModsByRMSD( mods.car.enrp.dubs.01.ode, rmsd.threshold=rands.2regs.0.10, rmsd.type="fullode", scale=FALSE,n.cands=2)
##mods.car.enrp.dubs.01.2.ode.rmsf <- filterModsByRMSD( mods.car.enrp.dubs.01.ode, rmsd.threshold=rands.2regs.0.20, rmsd.type="fullode", scale=FALSE,n.cands=2)
##mods.car.enrp.dubs.01.5.ode.rmsf <- filterModsByRMSD( mods.car.enrp.dubs.01.ode, rmsd.threshold=rands.2regs.0.50, rmsd.type="fullode", scale=FALSE,n.cands=2)


