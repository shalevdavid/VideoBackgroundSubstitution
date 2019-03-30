% M is the block size, Image is the unknown image,  SourceBackground is
% the backgroung of the movie
% Image and SourceBackground  are 2D arrays of the same size
% This function recieves Image and Background and creates a block mask by
% its MAD in the blocks reffered to a gloabal saf

% MAD = Absolute Sum Differences

function [Blockmask] = CreateMaskMAD( Image , SourceBackground , saf , M )

    [J,K] = size(Image);
    for j=1:M:J-M+1
        for k=1:M:K-M+1
            
            tempdiff = Image(j:j+M-1,k:k+M-1) - SourceBackground(j:j+M-1,k:k+M-1);
            MAD = sum( abs(tempdiff(:)) );
            if (  MAD>saf  )
                Blockmask(j:j+M-1,k:k+M-1) = 1;
            else
                Blockmask(j:j+M-1,k:k+M-1) = 0;
            end;
            
        end;
    end;
    Blockmask(   size(Blockmask,1)+1:J  ,  :   ) = Blockmask(  2*size(Blockmask,1)+1-J:size(Blockmask,1)  ,  :   );
   Blockmask(   :  ,  size(Blockmask,2)+1:K   ) = Blockmask(  :  ,  2*size(Blockmask,2)+1-K:size(Blockmask,2)   );