% M is the block size, Image is the unknown image,  SourceBackground is
% the backgroung of the movie 

function [mask] = CreateMaskCorr( Image , SourceBackground , saf , J , K , M )

for j=1:M:J-M+1
    for k=1:M:K-M+1

        if (  NormalizedCorr( Image(j:j+M-1,k:k+M-1),SourceBackground(j:j+M-1,k:k+M-1) ) > saf  )
            mask(j:j+M-1,k:k+M-1) = 0;
        else
            mask(j:j+M-1,k:k+M-1) = 1;
        end;

    end;
end;

mask(   size(mask,1)+1:J  ,  :   ) = mask(  2*size(mask,1)+1-J:size(mask,1)  ,  :   );
mask(   :  ,  size(mask,2)+1:K   ) = mask(  :  ,  2*size(mask,2)+1-K:size(mask,2)   );