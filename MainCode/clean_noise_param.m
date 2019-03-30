% %%%%%     clean noise   %%%%%%
%%%% diff - B/W Image
%%%% param - The maximal size of linked group that will be cleaned from
%%%% the "diff" image.

function im = clean_noise_param(diff,param);

[L,num]=bwlabel(diff);
im=zeros(size(L));
for m=1:num
    Z=(L==m);
    mass=sum(Z(:));
    if (mass > param)
        im=im+Z;
    end
end

im=1*(im>0);

