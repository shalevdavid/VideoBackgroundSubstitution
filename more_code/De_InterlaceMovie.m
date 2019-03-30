function [Interlace] = De_InterlaceMovie(mov)

for j=1:size(mov,2)
    frame_pic = frame2im(mov(j));
    for index = 1:2:size(frame_pic,1)
        TempInterlace((index+1)/2,:,:) = frame_pic(index,:,:);
    end;
    for index = 1:2:size(TempInterlace,2)
        FinalInterlace(:,(index+1)/2,:,j) = TempInterlace(:,index,:);
    end;
end;

for i=1:size(mov,2)
    Interlace(i) = im2frame(FinalInterlace(:,:,:,i));
end
