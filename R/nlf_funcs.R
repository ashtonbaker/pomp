make.lags.nlf <- function(x, lags, cov = NULL, nobs = 10000) {
  x <- as.matrix(x)
  xd <- ncol(x)
  m <- length(lags)
  N <- min(nobs,nrow(x)-max(lags))
  n <- min(nobs,N)
  if (N > nobs)
    warning("in ",sQuote("make.lags.nlf"),
            ": series length truncated to default in make.lags",call.=FALSE)
  start <- max(lags)+1
  temp <- matrix(0,ncol=xd*length(lags),nrow=n)
  for (k in seq_len(length(lags))) {
    a <- start-lags[k]
    b <- a + n - 1
    temp[,(1:xd)+(k-1)*xd] <- x[(a:b),]
  }
  a <- start
  b <- a + n - 1
  if(xd == 1)
    lab <- format(paste0("lag",rep(lags,rep(xd,length(lags)))))
  else
    lab <- format(paste0(rep(seq_len(xd),length(lags)),"lag",rep(lags,rep(xd,length(lags)))))
  dimnames(temp) <- list(NULL,lab)
  skip <- NA
  if (!is.null(cov)) {
    cov <- as.matrix(cov)
    cov <- cov[a:b,,drop=FALSE]
    skip <- (1:ncol(cov))+m*xd
  }
  if(xd == 1)
    y <- c(x[a:b])
  else
    y <- x[a:b,]
  list(
       x=temp,
       y=y,
       nvar=m,
       cov=cov,
       lags=lags,
       skip=skip,
       start=a,
       end=b
       )
}

make.rbfbasis <- function (X, knots, fac) {
  X1 <- X-knots[1]
  nknots <- length(knots)
  if (nknots>1) {
    for (j in seq(from=2,to=nknots,by=1)) {
      X1 <- cbind(X1,X-knots[j])
    }
  }
  exp(fac*(X1^2))
}	 

## GAUSS trimr function:
## trims n1 rows from the start,
## n2 rows from the end of a matrix or vector 
trimr <- function (a, n1, n2) {
    a[seq.int(from=n1+1,to=NROW(a)-n2,by=1)]
}

Newey.West <- function(x, y, maxlag) {
  w <- 1-seq_len(maxlag)/(maxlag+1)
  out <- mean(x*y,na.rm=TRUE)
  for (i in seq_len(maxlag)) {
    out <- out+
        w[i]*mean(trimr(x,i,0)*trimr(y,0,i),na.rm=TRUE)+
        w[i]*mean(trimr(y,i,0)*trimr(x,0,i),na.rm=TRUE)
  }
  out
} 


make.tensorbasis.nlf <- function(A,B) {
  if(nrow(A)!=nrow(B))
      stop("in ",sQuote("make.tensorbasis.nlf"),
           ": incompatible matrices in make.tensorbasis",call.=FALSE)
  ncol.A <- ncol(A)
  ncol.B <- ncol(B)
  Tmat <- matrix(0,nrow(A),ncol.A*ncol.B)
  for (i in seq_len(ncol.A)) {
    start <- (i-1)*ncol.B
    for (j in seq_len(ncol.B)) {
      Tmat[,start+j] <- A[,i]*B[,j]
    }
  }
  Tmat
}
