% the images I and SourceBackground are 2 dimensional 

function mask_matching = MaskMatchingSAD( mask , I , SourceBackgroundI , saf , M)

[J,K] = size( SourceBackgroundI);
Image = I.*mask;
SourceBackground =  SourceBackgroundI.*mask;
mask_matching = mask;

for j=1:M:J-M+1
    for k=1:M:K-M+1
               
        if (  SAD( Image(j:j+M-1,k:k+M-1),SourceBackground(j:j+M-1,k:k+M-1) ) > saf  )
            mask_matching(j:j+M-1,k:k+M-1) = 0;
        end;
        
    end;
end;