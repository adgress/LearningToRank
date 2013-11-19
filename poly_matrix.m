function K = poly_matrix(coord, d)

%function K = rbf(coord,sig)
%
% Computes an rbf kernel matrix from the input coordinates
%
%INPUTS
% coord =  a matrix containing all samples as rows
% sig = sigma, the kernel width; squared distances are divided by
%       squared sig in the exponent
%
%OUTPUTS
% K = the rbf kernel matrix ( = exp(-1/(2*sigma^2)*(coord*coord')^2) )
%
%
% For more info, see www.kernel-methods.net

%
%Author: Tijl De Bie, february 2003. Adapted: october 2004 (for speedup).

n=size(coord,1);
K=(coord*coord').^d;

%% Previous version:
%%
% n = size(coord,1);
% for i=1:n
%     K(i,i)=1;
%     for j=1:i-1
%         K(i,j)=exp(-norm(coord(i,:)-coord(j,:))^2/sig^2);% Should be
%         % 2*sig^2!
%         K(j,i)=K(i,j);
%     end
% end
