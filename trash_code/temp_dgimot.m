
i=1;
nfi=50;

while  (i<nfi)
    
    frame1 = mov(i);
    frame2 = mov(i+1);
    I1 = frame2im(frame1);
    I2 = frame2im(frame2); 
    
    GRAY1 = im2double(rgb2gray(I1));
    GRAY2 = im2double(rgb2gray(I2));

    dgimot(:,:,i) = (GRAY2-GRAY1);
       
%     sum_source_background = sum_source_background + im2double(I1);
    i=i+1;
end;

[n,xout] = hist(dgimot(88,204,:)) ; bar(xout,n);
[n,xout] = hist(dgimot(88,99,:)) ; figure(2),bar(xout,n);