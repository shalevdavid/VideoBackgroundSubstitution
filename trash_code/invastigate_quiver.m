M=8;
p=7;


for k=1:nfi
    
    frame1 = mov(k);
    frame2 = mov(k+1);
    I1 = frame2im(frame1);
    I2 = frame2im(frame2); 
    
    GRAY1 = im2double(rgb2gray(I1));
    GRAY2 = im2double(rgb2gray(I2));
    
    [motionVect, ARPScomputations] = motionEstARPS(GRAY2, GRAY1,M,p );  
    
    VECT_X=motionVect(2,:);
    VECT_Y=motionVect(1,:);
    VECT_col = reshape(VECT_X , 80 , 60);
    VECT_row = reshape(VECT_Y , 80 , 60);
    VECT_col = VECT_col';
    VECT_row = VECT_row';
   
    
    Vectors_col(60,80) = 0; 
    Vectors_row(60,80) = 0; 
    for n=1:60
        Vectors_col(n,:) =  VECT_col(60-n+1,:);
        Vectors_row(n,:) =  VECT_row(60-n+1,:);
    end;
    
    figure, quiver( Vectors_col,Vectors_row);
    figure,imshow(GRAY1);
        
    
end;
    figure,imshow(GRAY2)
    