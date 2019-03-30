function [ ] = FuncName(mask,SlopeArray,u_new,v_new)

for i=1:length(SlopeArray)
     
    if (SlopeArray(i)==0)
        VerticalArray(i) = 1000;    
    elseif (SlopeArray(i)==1000)
        VerticalArray(i) = 0;
    else
        VerticalArray(i) = -1/SlopeArray(i);
    end;
    
end;