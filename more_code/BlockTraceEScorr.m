% Computes motion vectors using exhaustive search method
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%   mbSize : Size of the macroblock
%   p : Search parameter  (read literature to find what this means)
%
% Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   EScomputations: The average number of points searched for a macroblock
%
% Written by Aroh Barjatya

function [motionVect, EScomputations] = BlockTraceEScorr(imgP, imgI, maskBlock, mbSize, p, i, j)

[row col] = size(imgI);

costs = ones(2*p + 1, 2*p +1) * 65537;

computations = 0;


% the exhaustive search starts here
% we will evaluate cost for  (2p + 1) blocks vertically
% and (2p + 1) blocks horizontaly
% m is row(vertical) index
% n is col(horizontal) index
% this means we are scanning in raster order

for m = -p : p        
    for n = -p : p
        refBlkVer = i + m;   % row/Vert co-ordinate for ref block
        refBlkHor = j + n;   % col/Horizontal co-ordinate
        if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
            continue;
        end
        costs(m+p+1,n+p+1) = -NormalizedCorr(imgI(i:i+mbSize-1,j:j+mbSize-1).*maskBlock, ...
                imgP(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1).*maskBlock);

        computations = computations + 1;

    end
end

% Now we find the vector where the cost is minimum
% and store it ... this is what will be passed back.

[dx, dy, min] = minCost(costs); % finds which macroblock in imgI gave us min Cost
vectors(1) = dy-p-1;    % row co-ordinate for the vector
vectors(2) = dx-p-1;    % col co-ordinate for the vector

motionVect = vectors;
EScomputations = computations;
                    