% % % Binarization using Blocks
% M is the block size, Image is the unknown image,  SourceBackground is
% the backgroung of the movie
% Image and SourceBackground  are 2D arrays of the same size
% This function recieves Image and Background and creates a block mask by
% its ASD in the blocks reffered to a gloabal saf

% ASD = Absolute Sum Differences

function [Blockmask] = CreateMaskASD( Image , SourceBackground , saf , M )

    [J,K] = size(Image);
    for j=1:M:J-M+1
        for k=1:M:K-M+1
            
            tempdiff = Image(j:j+M-1,k:k+M-1) - SourceBackground(j:j+M-1,k:k+M-1);
            ASD = abs( sum(tempdiff(:)) );
            if (  ASD>saf  )
                Blockmask(j:j+M-1,k:k+M-1) = 1;
            else
                Blockmask(j:j+M-1,k:k+M-1) = 0;
            end;
            
        end;
    end;
    Blockmask(   size(Blockmask,1)+1:J  ,  :   ) = Blockmask(  2*size(Blockmask,1)+1-J:size(Blockmask,1)  ,  :   );
   Blockmask(   :  ,  size(Blockmask,2)+1:K   ) = Blockmask(  :  ,  2*size(Blockmask,2)+1-K:size(Blockmask,2)   );