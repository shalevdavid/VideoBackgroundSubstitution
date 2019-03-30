
% % % Tracking the edge only  % % %
% % % SetOfNewPoints is a  series of points that were traced after being arranged by order
% % % 2m+1 is the environment of the point, an  environment according
% % % to which we will classify the point as good or not. Thus we will
% % % be able to bring out a series of controled points,  that the function
% % % will return at ControledSet
% % % control_parameter is the distance which according to a point is 
% % % classified as good or not. the higher the control parameter is, the
% % % ControledSet will be smaller, and the other way around

function [ControledSet] = ControledPoints(SetOfNewPoints, m , control_prameter)

ControledSet = [];
i_control = 0;
for i=1+m:size(SetOfNewPoints,1)-m
    p = SetOfNewPoints(i,:);
    envi_p = SetOfNewPoints(i-m:i+m,:);
    avg_envi_p = [ mean( envi_p(:,1) ) , mean( envi_p(:,2) ) ];
    vectors = envi_p - repmat(avg_envi_p ,[2*m+1 1]);
    distance = sqrt(vectors(:,1).^2+vectors(:,2).^2);
    sigma = mean(distance);
   if ( sigma < control_prameter)
       i_control = i_control+1;
       ControledSet(i_control,:) = SetOfNewPoints(i,:);
   end;
end;