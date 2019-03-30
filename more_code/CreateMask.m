% M is the block size, Image is the unknown image,  SourceBackground is
% the backgroung of the movie 
% [J,K] = size of this
% This function recieves Image and Background and creates a block mask by
% its MAD in the blocks using a the maxnoise known in the corresponding
% block

function [mask] = CreateMask( Image , SourceBackground , maxnoise , J , K , M )

    for j=1:M:J-M+1
        for k=1:M:K-M+1
            
            tempdiff = Image(j:j+M-1,k:k+M-1) - SourceBackground(j:j+M-1,k:k+M-1);
            tempblocknoise = maxnoise(j:j+M-1,k:k+M-1);
            MAD = sum( abs(tempdiff(:)) )/M^2;
            if (  MAD>sum(tempblocknoise(:))/M  )
                mask(j:j+M-1,k:k+M-1) = 1;
            else
                mask(j:j+M-1,k:k+M-1) = 0;
            end;
            
        end;
    end;
    mask(   size(mask,1)+1:J  ,  :   ) = mask(  2*size(mask,1)+1-J:size(mask,1)  ,  :   );
    mask(   :  ,  size(mask,2)+1:K   ) = mask(  :  ,  2*size(mask,2)+1-K:size(mask,2)   );