#Runs for ECL232 presentation
#Noam Ross
#This script will reproduce all data and plots for the presentation in ECL232, March 16, 2002
#It requires the 'smap_functions' file to run
# Note that `.parallel=TRUE` requires a parallel backend.

#Import packages and functions
source('R/smap_functions.R')  #This will load more libraries that you actually need.

set.seed(0)
#Create a list of Ricker time series of 500 points, cutting off the initial values
rickerparms <- expand.grid(a=c(0.5,1,2,3,4), z=c(0.001, 0.005, 0.01, 0.05, 0.1))
initial = 0.8
nsteps=1000
ricks <- alply(rickerparms, 1, function(z) time.series(ricker.series, initial, nsteps, parms=list(a=z[,"a"], z=z[,"z"])), .parallel=TRUE)
ricks <- llply(ricks, function(z) ts(z[501:1000]))
#Plot these outputs
par(mfrow=c(5,5), mar=c(1,0.2,0,0.2), oma=c(2,2,2,2))
l_ply(1:25, function(z) plot(1:500, ricks[[z]], type="l", col="slateblue", ylim=c(0,7),yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n"))
pdf("fig1ricks.pdf")
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,0,2,0))
a_ply(1:25, 1, function(z) {
  plot(1:500, ricks[[z]], type="l", col="slateblue", yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n", xlab="", ylab="")
  if(z<6) mtext(paste("a =", c(0.5,1,2,3,4)[z]))
  if(z %%5 ==0) mtext(substitute(theta == y, list(y=c(0.001, 0.005, 0.01, 0.05, 0.1)[z/5])), side=4)
})
title("Figure 1: Ricker Model Series", outer=TRUE)
mtext("Time Steps", 1, outer=TRUE, padj=2)
dev.off()
#Create a list of 3-species model attractors

times=seq(from=0, to=10000, by=1)
parms = c(xc=0.4, yc=2.009, xp=0.08, yp=2.876, R0=0.16129, C0=0.5,  K=0.997,sd=0.001)
inits = c(R=0.5, C=0.4, P=0.8)
Ksvals <- rep(seq(from=0.84, to=0.99, length.out=5), times=5)
stochs <- rep(c(0.0005, 0.001, 0.005, 0.01, 0.05), each=5)
randR = cbind(runif(10002,-1,1))
randC = cbind(runif(10002,-1,1))
randP = cbind(runif(10002,-1,1))
forceR <- cmpfun(approxfun(x=0:10001, y=randR, method="linear", rule=2))
forceC <- cmpfun(approxfun(x=0:10001, y=randR, method="linear", rule=2))
forceP <- cmpfun(approxfun(x=0:10001, y=randR, method="linear", rule=2))
trophs <- alply(1:25, 1, function(z) {
  randR = cbind(runif(10002,-1,1))
  randC = cbind(runif(10002,-1,1))
  randP = cbind(runif(10002,-1,1))
  forceR <- cmpfun(approxfun(x=0:10001, y=randR, method="linear", rule=2))
  forceC <- cmpfun(approxfun(x=0:10001, y=randR, method="linear", rule=2))
  forceP <- cmpfun(approxfun(x=0:10001, y=randR, method="linear", rule=2))
  lsoda(y=c(R=0.5, C=0.4, P=0.8), times=times, func=troph3s.func, parms=replace(parms, c("K", "sd"), c(Ksvals[z], stochs[z])))
}, .parallel=TRUE)
load("trophs.R")
#Plot the 3-species model attractors
par(mfrow=c(5,5), mar=c(0,0,0,0))
l_ply(trophs, function(z) scatterplot3d(z[,2:4], type="l", color=col.alpha("black", alpha=0.3), axis=FALSE, mar=c(0,0,0,0), box=FALSE, xlim=c(0,1), ylim=c(0,1), zlim=c(0,1)))
#Extract independent points and plot
mut.lags <- laply(trophs, function(z) firstminmut(z[,4]))
trophps <- alply(1:25, 1, function(z) ts(trophs[[z]][(101:600)*mut.lags[z],4]))
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5))
a_ply(1:25,1, function(z) plot(1:500, trophps[[z]], type="l", col="slateblue", ylim=c(0,1), yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n"))
par(mfrow=c(5,5), mar=c(0.1,0.1,0.1,0.1), oma=c(0.5,0.5,0.5,0.5))
l_ply(trophps, function(z) plot(1:500, z, type="l", col="slateblue", yaxt="n",xaxt="n")) # Plots with different scales, shows transitions between regimes better
par(mfrow=c(5,5), mar=c(0,0,0,0))
l_ply(trophs, function(z) scatterplot3d(z[(101:600)*mut.lags[z],2:4], type="l", color=col.alpha("black", alpha=1), axis=FALSE, mar=c(0,0,0,0), box=FALSE)) #xlim=c(0,1), ylim=c(0,1), zlim=c(0,1)

#Save the original time series and remove from workspace for memory, along with some other big things
save(trophs, file="trophs.R")
rm(trophs, randC, randP, randR, forceC, forceP, forceR)


#Now let's see how each do with dimensionality
emlist <- expand.grid(E=1:10, ser=1:25)  #make a grid of embeddings in different dimensions
em.t <- alply(emlist,1, function(z) embed.series(series=trophps[[z[,"ser"]]], dimensions=z[,"E"]), .parallel=TRUE) #embed the trophic series
em.r <- alply(emlist, 1, function(z) embed.series(series=ricks[[z[,"ser"]]], dimensions=z[,"E"]), .parallel=TRUE) #embed the ricker series
t.simfits <- llply(em.t, function(z) simplex.cv(z, allvalues=TRUE), .parallel=TRUE)  #Do a simlex projection cv fit to estmate dimensions
r.simfits <- llply(em.r, function(z) simplex.cv(z, allvalues=TRUE), .parallel=TRUE)
t.simfit.table <- laply(em.t, function(z) simplex.cv(z, allvalues=FALSE), .parallel=TRUE)
r.simfit.table <- laply(em.r, function(z) simplex.cv(z, allvalues=FALSE), .parallel=TRUE)
t.simfit.peaks <- aaply(t.simfit.table, 2, function(z) which.max(z))   #Find the maximum fit across dimensions
r.simfit.peaks <- aaply(r.simfit.table, 2, function(z) which.max(z))

a_ply(1:20, 1, function(z) {   #Plot the dimensional fits for the ricker
  plot(1:10, r.simfit.table[,z], type="l", ylim=c(0,1), xlim=c(1,10), yaxt=if(z%%5 != 1) "n", xaxt="n", col="slateblue", lwd=4)
  points(r.simfit.peaks[z], r.simfit.table[r.simfit.peaks[z], z], col="blue", pch=16, cex=2)
})
a_ply(21:25, 1, function(z) {
  plot(1:10, r.simfit.table[,z], type="l", ylim=c(0,1), xlim=c(1,10), yaxt=if(z%%5 != 1) "n", col="slateblue", lwd=4)
  points(r.simfit.peaks[z], r.simfit.table[r.simfit.peaks[z], z], col="blue", pch=16, cex=2)
})

##Plot the projections against the real values for the correct dimensionality for each of these
rick1s <- seq(from=1, to=250, by=10)
troph3s <- seq(from=3, to=250, by=10)
a_ply(rick1s, 1, function(z) plot(r.simfits[[z]]$reals, r.simfits[[z]]$predictions, col=col.alpha("slateblue", 0.5), cex=0.8, pch=16, yaxt=if(((z-1)/10)%%5 != 0) "n", xaxt=if(z<200) "n"))


#Now let's do S-Map fits
em.r1 <- em.r[rick1s]
em.t3 <- em.t[troph3s]
r.smapfit <- laply(em.r1, fit.smap, .parallel=TRUE)
t.smapfit <- laply(em.t3, fit.smap, .parallel=TRUE)
rtheta.seq = 10^(seq(0,3.7, by=0.1))
rgrd <- expand.grid(ser = 1:25, theta=rtheta.seq)
ttheta.seq = seq(0,150, by=3)
tgrd <- expand.grid(ser = 1:25, theta=ttheta.seq)
rthetacors <- aaply(rgrd, 1, function(z) smap.cv(em.r1[[z[, "ser"]]], theta=z[, "theta"], horizon=1), .parallel=TRUE)
tthetacors <- aaply(tgrd, 1, function(z) smap.cv(em.t3[[z[, "ser"]]], theta=z[, "theta"], horizon=1), .parallel=TRUE)
t.smapfit[20,2] <- max(tthetacors[20, ])  #This didn't get fit right by the solver
t.smapfit[20,1] <- rtheta.seq[which.max(tthetacors[20,])]
t.smapfit[25,2] <- max(tthetacors[25, ], na.rm=TRUE)  #This didn't get fit right by the solver
t.smapfit[25,1] <- ttheta.seq[which.max(tthetacors[25,])]
t.smapfit[21,2] <- max(tthetacors[21, ], na.rm=TRUE)  #This didn't get fit right by the solver
t.smapfit[21,1] <- ttheta.seq[which.max(tthetacors[21,])]

r.allpoints <- aaply(1:25, 1, function(z) pointsused(em.r1[[z]],r.smapfit[z,1], allvalues=TRUE, fraction=TRUE), .parallel=TRUE)
t.allpoints <- aaply(1:25, 1, function(z) pointsused(em.t3[[z]],t.smapfit[z,1], allvalues=TRUE, fraction=TRUE), .parallel=TRUE)

r.points <- rowMeans(r.allpoints)
t.points <- rowMeans(t.allpoints)


pdf(paper="letter")
par(mfrow=c(5,5), mar=c(1,0.2,0,0.2), oma=c(2,2,1,1))
a_ply(1:25, 1, function(z){
  plot(ttheta.seq, tthetacors[z,], type="l",yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n", col="slateblue", lwd=4, ylim=c(0.7,1))
  points(t.smapfit[z,1], t.smapfit[z,2], col="blue", pch=16, cex=2)
  text(140, 0.9, substitute(bar(P)[list(theta, 0.95)] == y, list(y = round(t.points[z],3))), adj=c(1, 0.5))
})
dev.off()
a_ply(1:25, 1, function(z) {
  dens(r.allpoints[z, ], adj=1,xlim=c(0,1), ylim=c(0,10), ,yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n")
  abline(v=r.points[z], col="blue", lty=2)
  })

a_ply(1:25, 1, function(z) {
  dens(t.allpoints[z, ], adj=1,xlim=c(0,1), ylim=c(0,10), ,yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n")
  abline(v=t.points[z], col="blue", lty=2)
})

par(mfrow=c(1,1))
plot(log(r.smapfit[,1]), r.points)
plot((log(t.smapfit[,1])), t.points)

save.image("paperrun20120318_NR.Rdata")

#PLOTS!

#Ricker Series Grid
pdf("Fig1_RickerSeries.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,1.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z) {
  plot(1:500, ricks[[z]], type="l", col="slateblue", yaxt="n", xaxt=if(z<21) "n", xlab="", ylab="", lwd=0.5)
  axis(2, at=c(max(ricks[[z]]), min(ricks[[z]])), labels=round(c(max(ricks[[z]]), min(ricks[[z]])), 2), las=1, hadj=0.5, tck=-0.02 )
  if(z<6) mtext(paste("a =", c(0.5,1,2,3,4)[z]))
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.001, 0.005, 0.01, 0.05, 0.1)[z/5])), side=4, line=1)
})
mtext("Time Steps", 1, outer=TRUE, padj=2)
mtext("Population (scaled to range of series)", 2, outer=TRUE, padj=-2)
dev.off()

#3-species series grid
pdf("Fig2_TrophSeries.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,1.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z) {
  plot(1:500, trophps[[z]], type="l", col="slateblue", yaxt="n", xaxt=if(z<21) "n", xlab="", ylab="", lwd=0.5)
  axis(2, at=c(max(trophps[[z]]), min(trophps[[z]])), labels=round(c(max(trophps[[z]]), min(trophps[[z]])), 2), las=1, hadj=0.5, tck=-0.02 )
  if(z<6) mtext(paste("K =", seq(from=0.84, to=0.99, length.out=5)[z]))
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.0005, 0.001, 0.005, 0.01, 0.05)[z/5])), side=4, line=1)
})
mtext("Time Steps", 1, outer=TRUE, padj=2)
mtext("Population (scaled to range of series)", 2, outer=TRUE, padj=-2)
dev.off()

#Ricker dimensional plots
pdf("Fig3_RickerDim.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z) {   #Plot the dimensional fits for the trophic series
  plot(1:10, r.simfit.table[,z], type="l", ylim=c(0,1), xlim=c(1,10), yaxt="n", xaxt=if(z<21) "n", col="slateblue", lwd=4)
  if(z%%5 == 1) axis(2, c(0,0.2,0.4,0.6,0.8,1), c(0,0.2,0.4,0.6,0.8,1), las=1)
  points(r.simfit.peaks[z], r.simfit.table[r.simfit.peaks[z], z], col="blue", pch=16, cex=2)
  if(z<6) mtext(paste("a =", c(0.5,1,2,3,4)[z]), padj=-0.5)
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.001, 0.005, 0.01, 0.05, 0.1)[z/5])), side=4, line=1, padj=-0.5)
})
mtext("Embedding Dimension (E)", 1, outer=TRUE, padj=2.5)
mtext(expression(Correlation (rho)), 2, outer=TRUE, padj=-1.5)
dev.off()

#3-species dimensional plots
pdf("Fig4_TrophDim.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z) {   #Plot the dimensional fits for the trophic series
  plot(1:10, t.simfit.table[,z], type="l", ylim=c(0,1), xlim=c(1,10), yaxt="n", xaxt=if(z<21) "n", col="slateblue", lwd=4)
  points(t.simfit.peaks[z], t.simfit.table[t.simfit.peaks[z], z], col="blue", pch=16, cex=2)
  if(z<6) mtext(paste("K =", seq(from=0.84, to=0.99, length.out=5)[z]), padj=-0.5)
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.0005, 0.001, 0.005, 0.01, 0.05)[z/5])), side=4, line=1, padj=-0.5)
})
mtext("Embedding Dimension (E)", 1, outer=TRUE, padj=2.5)
mtext(expression(Correlation (rho)), 2, outer=TRUE, padj=-1.5)
dev.off()

#real v. actual plot for 3species model at 3 dimension
pdf("Fig5_TrophPred.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(troph3s, 1, function(z) {
  plot(t.simfits[[z]]$reals, t.simfits[[z]]$predictions, col=col.alpha("slateblue", 0.3), cex=0.75, pch=16, yaxt="n", xaxt=if(z<200) "n", xlim=c(0,1), ylim=c(0,1))
  if( ((z-3)/10) %% 5 == 0) axis(2, c(0,0.2,0.4,0.6,0.8,1), c(0,0.2,0.4,0.6,0.8,1), las=1)
  abline(a=0,b=1, col="grey")
  if(z<50) mtext(paste("K =", seq(from=0.84, to=0.99, length.out=5)[(z+8)/10]), padj=-0.5)
  if(((z+7)/10) %% 5 == 0) mtext(substitute(sigma == y, list(y=c(0.0005, 0.001, 0.005, 0.01, 0.05)[(z+7)/50])), side=4, line=1, padj=-0.5)
  })
mtext("Actual Values", 1, outer=TRUE, padj=2.5)
mtext("Predicted Values", 2, outer=TRUE, padj=-2)
dev.off()

pdf("Fig6_RickerTheta.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z){
  plot(log10(rtheta.seq), rthetacors[z,], type="l",yaxt="n", xaxt=if(z<21) "n", col="slateblue", lwd=4, ylim=c(0,1))
  points(log10(r.smapfit[z,1]), r.smapfit[z,2], , col="blue", pch=16, cex=2)
  if(z%%5 == 1) axis(2, c(0,0.2,0.4,0.6,0.8,1), c(0,0.2,0.4,0.6,0.8,1), las=1)
  if(z<6) mtext(paste("a =", c(0.5,1,2,3,4)[z]), padj=-0.5)
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.001, 0.005, 0.01, 0.05, 0.1)[z/5])), side=4, line=1, padj=-0.5)
  text(3.5, 0.7, substitute(bar(P)[list(theta, 0.95)] == y, list(y = round(r.points[z],3))), adj=c(1, 0.5))
})
mtext(expression(log(theta)), 1, outer=TRUE, padj=1.5)
mtext(expression(Correlation (rho)), 2, outer=TRUE, padj=-1.5)
dev.off()

pdf("Fig7_TrophicTheta.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z){
  plot(ttheta.seq, tthetacors[z,], type="l",yaxt="n", xaxt=if(z<21) "n", col="slateblue", lwd=4, ylim=c(0.7,1))
  points(t.smapfit[z,1], t.smapfit[z,2], , col="blue", pch=16, cex=2)
  if(z%%5 == 1) axis(2, seq(0.75,1,by=0.05), seq(0.75,1,by=0.05), las=1)
  if(z<6) mtext(paste("K =", seq(from=0.84, to=0.99, length.out=5)[z]), padj=-0.5)
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.0005, 0.001, 0.005, 0.01, 0.05)[z/5])), side=4, line=1, padj=-0.5)
  text(135, 0.9, substitute(bar(P)[list(theta, 0.95)] == y, list(y = round(t.points[z],3))), adj=c(1, 0.5))
})
mtext(expression(theta), 1, outer=TRUE, padj=1.5)
mtext(expression(Correlation (rho)), 2, outer=TRUE, padj=-1.5)
dev.off()

pdf("Fig8_RickerDens.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z) {
  dens(r.allpoints[z, ], adj=1,xlim=c(0,1), ylim=c(0,10), ,yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n")
  abline(v=r.points[z], col="blue", lty=2)
  if(z<6) mtext(paste("a =", c(0.5,1,2,3,4)[z]), padj=-0.5)
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.001, 0.005, 0.01, 0.05, 0.1)[z/5])), side=4, line=1, padj=-0.5)
})
mtext(expression(bar(P)[list(theta, 0.95)]), 1, outer=TRUE, padj=1.5)
mtext("Density", 2, outer=TRUE, padj=-2)
dev.off()

#Trophic denity plots
pdf("Fig9_TrophicDens.pdf", width=8)
par(mfrow=c(5,5), mar=c(0.5,0.5,0.5,0.5), oma=c(4,4,2,2))
a_ply(1:25, 1, function(z) {
  dens(t.allpoints[z, ], adj=1,xlim=c(0,1), ylim=c(0,10), ,yaxt=if(z%%5 != 1) "n", xaxt=if(z<21) "n")
  abline(v=t.points[z], col="blue", lty=2)
  if(z<6) mtext(paste("a =", seq(from=0.84, to=0.99, length.out=5)[z]), padj=-0.5)
  if(z %%5 ==0) mtext(substitute(sigma == y, list(y=c(0.0005, 0.001, 0.005, 0.01, 0.05)[z/5])), side=4, line=1, padj=-0.5)
})
mtext(expression(bar(P)[list(theta, 0.95)]), 1, outer=TRUE, padj=1.5)
mtext("Density", 2, outer=TRUE, padj=-2)
dev.off()
