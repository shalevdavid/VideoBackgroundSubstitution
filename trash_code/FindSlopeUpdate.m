function [SlopeArray] =FindSlopeUpdate(ObjectsArrayNew)

for i=1:length(ObjectsArrayNew)
    
    array = ObjectsArrayNew(i).array;
    SlopeArray(i) = (array(1,2) - array(1,1)) / (array(2,2) - array(2,1));
    
end;
    
    
       
         