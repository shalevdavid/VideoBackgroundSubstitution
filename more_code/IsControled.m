function [is_controled] = IsControled(NewPoint, SeriesOfNewNeigbours, control_prameter)

is_controled = 0;
m = size(SeriesOfNewNeigbours,1);
p = NewPoint;
envi_p = SeriesOfNewNeigbours;
avg_envi_p = [ mean( envi_p(:,1) ) , mean( envi_p(:,2) ) ];
vectors = envi_p - repmat(avg_envi_p ,[m  1]);
distance = sqrt(vectors(:,1).^2+vectors(:,2).^2);
sigma = mean(distance);
if ( sigma < control_prameter)
    is_controled = 1;
end;