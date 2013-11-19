function val = rbf_kernel(x, y, sigma)
	val = exp( -1/2 * 1/sigma^2 * (x - y)' * (x - y) );

