function [SlopeArray] =FindSlope(ObjectsArrayNew)

for i=1:length(ObjectsArrayNew)
    
    array = ObjectsArrayNew(i).array;
    
    if (array(1,1)==array(1,2))
        SlopeArray(i) = 0;    
    elseif (array(2,1)==array(2,2))
         SlopeArray(i) = 1000;
    else
        SlopeArray(i) = (array(1,2) - array(1,1)) / (array(2,2) - array(2,1));
    end;
    
end;
    
    
       
         