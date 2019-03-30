% M is the block size, Image is the unknown image,  SourceBackground is
% the backgroung of the movie
% Image and SourceBackground  are 2D arrays of the same size
% This function recieves Image and Background and creates a block mask by the Normalized
% values of the midle pixel at its enviroment 

function [Blockmask] = CreateBlockMask( Image , SourceBackground , saf , M )

[J,K] = size(Image);
    for j=1:M:J-M+1
        for k=1:M:K-M+1
            
            PixelImage = Image(j+round((M-1)/2) , k+round((M-1)/2));
            PixelSource = SourceBackground( j+round((M-1)/2) , k+round((M-1)/2) );
            ImageBlock = Image(j:j+M-1,k:k+M-1)  ;
            SourceBlock = SourceBackground(j:j+M-1,k:k+M-1);
            mue1 = mean( ImageBlock(:));
            mue2 = mean( SourceBlock(:));
            if (  abs( (PixelImage-mue1) - (PixelSource - mue2) )  > saf  )
               Blockmask(j:j+M-1,k:k+M-1) = 1;
            else
                Blockmask(j:j+M-1,k:k+M-1) = 0;
            end;
            
        end;
    end;
    Blockmask(   size(Blockmask,1)+1:J  ,  :   ) = Blockmask(  2*size(Blockmask,1)+1-J:size(Blockmask,1)  ,  :   );
    Blockmask(   :  ,  size(Blockmask,2)+1:K   ) = Blockmask(  :  ,  2*size(Blockmask,2)+1-K:size(Blockmask,2)   );