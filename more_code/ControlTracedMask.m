% % % 2m+1 is the enviroment block
% % % SetOfPoints is the points of the previous mask, e.g before tracing
% % % SetOfNewPoints is the result of tracing SetOfPoints point by point
% % % previous_mask is the  mask before tracing
% % % control_parameter is the distance which according to a point is 
% % % classified as good or not. the higher the control parameter is, the
% % % ControledSet will be smaller, and the other way around

function [controled_mask] = ControlTracedMask( SetOfPoints , SetOfNewPoints , previous_mask , control_parameter , m )

[J,K] = size(previous_mask);
controled_mask = zeros(J,K);

for i =1:size(SetOfPoints,1)
    
    SeriesOfNewNeigbours=[];
    r = SetOfPoints(i,1);
    c = SetOfPoints(i,2);
    
    r1 = r-m;
    r2 = r+m;
    c1 = c-m;
    c2 = c+m; 
    if  ( r1<= 0 )
        r1 = 1;
        r2 = 2*m+1;
    end;
    if ( c1<= 0 )
        c1 = 1;
        c2 = 2*m+1;
    end;
    if  ( r2>= J )
        r2 = J;
        r1 = J-2*m;
    end;
    if  ( c2>= K )
        c2 = K;
        c1 = K-2*m;
    end;
       
    maskBlock = previous_mask(r1:r2,c1:c2);
    [r_labled , c_labled] = find(maskBlock==1);
    r_labled = r_labled + r1 - 1;
    c_labled = c_labled + c1 - 1;
    SeriesOfNeigbours = [r_labled , c_labled];
    
    
    %%%  Now we need to extract SeriesOfNewNeigbours out of SeriesOfNeigbours 
    %%%  using SetOfNewPoints and SetOfPoints
    
    for j=1:size(SeriesOfNeigbours,1)
        neigbour = SeriesOfNeigbours(j,:);
        index_new_neigbour= intersect( find (SetOfPoints(:,1)==neigbour(1)) , find (SetOfPoints(:,2)==neigbour(2)) );
        new_neigbour = SetOfNewPoints(index_new_neigbour,:);
        SeriesOfNewNeigbours(j,:)=new_neigbour;
    end;
    
    %%% Now we can supervise (using the controller) the points that were
    %%% traced and verify wheather they are O.K
    
    NewPoint = [ SetOfNewPoints(i,1) , SetOfNewPoints(i,2) ];
    controled_mask( NewPoint(1) , NewPoint(2) ) = IsControled(NewPoint, SeriesOfNewNeigbours, control_parameter);
    
end;

    
   
    