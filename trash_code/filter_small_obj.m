function bw=filter_small_obj(bw,th);

[L,num]=bwlabel(bw);

for i=1:num
    indx=find(L==i);
    if length(indx)<th
        bw(indx)=0;
    end
end