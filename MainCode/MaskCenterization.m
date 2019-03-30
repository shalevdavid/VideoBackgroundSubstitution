% % % This function recieves a mask, and a movenment vector and  moves
% % % the mask according to that vector 

function [mask_centered] = MaskCenterization(mask,movement_vector)
    [J,K] = size(mask);
    row_coordinate = movement_vector(2);
    col_coordinate = movement_vector(1);
    [r,c] = find(mask==1); 
    mask_centered=zeros(J,K);
    
    for j=1:size(r,1)
        row_coordinate_new = r(j)+row_coordinate;
        col_coordinate_new = c(j)+col_coordinate;
        if  ( row_coordinate_new<1  || col_coordinate_new<1 || row_coordinate_new>J || col_coordinate_new>K )
            continue;
        end;
        mask_centered( row_coordinate_new , col_coordinate_new ) = mask( r(j) , c(j) );
    end;