#### FCB Ch.10 p.175-179

set.seed(1)
sigma2 <- 1
tau2 <- 10
mu <- 5
n <- 5
y<-round(rnorm(n,10,1),2)
theta <- 0
delta2 <- 2
S <- 10000
THETA <- NULL
mu.n<-( mean(y)*n/sigma2 + mu/tau2 )/( n/sigma2+1/tau2)
tau2.n<-1/(n/sigma2+1/tau2)

for(s in 1:S){
  
  theta.star <- rnorm(1,theta,sqrt(delta2)) #proposal dist
  
  log.r <- (sum(dnorm(y, theta.star, sqrt(sigma2), log=TRUE)) + 
                dnorm(theta.star, mu, sqrt(tau2), log=TRUE)) -
           (sum(dnorm(y, theta, sqrt(sigma2), log=TRUE)) + 
                dnorm(theta, mu, sqrt(tau2), log=TRUE))
  
  if(log(runif(1)) < log.r) { theta <- theta.star }
  
  THETA <- c(THETA, theta)
  
}

#### Figure 10.3

par(mar=c(3,3,1,1),mgp=c(1.75,.75,0))
par(mfrow=c(1,3))

skeep<-seq(10,S,by=10)
plot(skeep,THETA[skeep],type="l",xlab="iteration",ylab=expression(theta))

hist(THETA[-(1:50)],prob=TRUE,main="",xlab=expression(theta),ylab="density")
th<-seq(min(THETA),max(THETA),length=100)
lines(th,dnorm(th,mu.n,sqrt(tau2.n)) )
acf(THETA,ci.col="gray",xlab="lag")

#### Figure 10.4

par(mfrow=c(4,3))
ACR<-ACF<-NULL
THETAA<-NULL
for(delta2 in 2^c(-5,-1,1,5,7) ) {
  set.seed(1)
  THETA<-NULL
  S<-10000
  theta<-0
  acs<-0
  delta<-2
  
  for(s in 1:S) 
  {
    
    theta.star<-rnorm(1,theta,sqrt(delta2))
    log.r<-sum( dnorm(y,theta.star,sqrt(sigma2),log=TRUE)-
                  dnorm(y,theta,sqrt(sigma2),log=TRUE)  )  +
      dnorm(theta.star,mu,sqrt(tau2),log=TRUE)-dnorm(theta,mu,sqrt(tau2),log=TRUE) 
    
    if(log(runif(1))<log.r)  { theta<-theta.star ; acs<-acs+1 }
    THETA<-c(THETA,theta) 
    
  }

  THETAA<-cbind(THETAA,THETA)
}


par(mfrow=c(1,3),mar=c(2.75,2.75,.5,.5),mgp=c(1.7,.7,0))
laby<-c(expression(theta),"","","","")

for(k in c(1,3,5)) {
  plot(THETAA[1:500,k],type="l",xlab="iteration",ylab=laby[k], 
       ylim=range(THETAA) )
  abline(h=mu.n,lty=2)
}