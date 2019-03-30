% the function recieves two blocks and return the normalized correletion
% between them using FFT and IFFT for a better efficiency : o(n*lon) insted
% of o(n^2)- this is good for 

function [NormCorr] = NormalizedCorr(block1,block2)
if (   (sum(block1(:).^2)*sum(block2(:).^2)) == 0  ) 
    NormCorr = 0; 
    if (  sum(block1(:).^2) == sum(block2(:).^2)  )
        NormCorr = 1;   % this is the case that they are both zeros
    end;
else 
    NormCorr = sum(block1(:).*block2(:))/(sum(block1(:).^2)*sum(block2(:).^2))^0.5;
end;

