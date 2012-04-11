bogdAP <- getpctAP('bogd.txt')
bogdlin <- diff(lint(bogdAP))
bogdems <- alply(1:20, 1, function(z) embed.series(series=bogdlin,dimension=z))
t.simfits <- llply(bogdems, function(z) simplex.cv(z, allvalues=TRUE), .parallel=TRUE)
t.simfit.table <- laply(bogdems, function(z) simplex.cv(z, allvalues=FALSE), .parallel=TRUE)
plot(t.simfit.table, type="l", xlab="Dimensions", ylab="Correlation Between Actual and Predicted Values")
par(mfrow=c(1,1))
for(i in 10) {
  plot(t.simfits[[i]]$reals, t.simfits[[i]]$predictions, xlim=c(-0.15,0.15), ylim=c(-0.15,0.15))
}
ttheta.seq = seq(0,150, by=3)
tthetacors <- aaply(ttheta.seq, 1, function(z) smap.cv(bogdems[[10]], theta=z, horizon=1), .parallel=TRUE)

fit.smap(bogdems[[10]])

Need a function to fit best dimension, theta, AND window size