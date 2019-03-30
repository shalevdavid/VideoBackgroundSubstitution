% Block Tracing from  a given Frame to an other next Frame
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%   mbSize : Size of the macroblock
%   p : Search parameter  (read literature to find what this means)
%   i,j : location of the left upper edge of the block we would like to
%   estimate, i is the row, j is the coloumn
%   maskBlock : the block you would like to corelate with 
%  Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   TSScomputations: The average number of points searched for a macroblock
%
%  Written by Inon Nussbaum and Shalev David


function [motionVect, TSScomputations] = BlockTraceTSScorr(imgP, imgI, maskBlock, mbSize, p, i, j)

[row col] = size(imgI);

costs = ones(3, 3) * 65537;

computations = 0;

L = floor(log10(p+1)/log10(2));   
stepMax = 2^(L-1);

x = j;
y = i;

costs(2,2) = -NormalizedCorr(imgI(i:i+mbSize-1,j:j+mbSize-1).*maskBlock, ...
                            imgP(i:i+mbSize-1,j:j+mbSize-1).*maskBlock);

computations = computations + 1;
stepSize = stepMax;               

while(stepSize >= 1)  

    for m = -stepSize : stepSize : stepSize        
        for n = -stepSize : stepSize : stepSize
            refBlkVer = y + m;   % row/Vert co-ordinate for ref block
            refBlkHor = x + n;   % col/Horizontal co-ordinate
            if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                continue;
            end

            costRow = m/stepSize + 2;
            costCol = n/stepSize + 2;
            if (costRow == 2 && costCol == 2)
                continue
            end
            costs(costRow, costCol ) = -NormalizedCorr(imgI(i:i+mbSize-1,j:j+mbSize-1).*maskBlock, ...
                imgP(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1).*maskBlock);

            computations = computations + 1;
        end
    end

    [dx, dy, min] = minCost(costs);      % finds which macroblock in imgI gave us min Cost

    x = x + (dx-2)*stepSize;
    y = y + (dy-2)*stepSize;

    stepSize = stepSize / 2;
    costs(2,2) = costs(dy,dx);

end
vectors(1) = y-i;    % row co-ordinate for the vector
vectors(2) = x-j;    % col co-ordinate for the vector            

motionVect = vectors;
TSScomputations = computations;
                    