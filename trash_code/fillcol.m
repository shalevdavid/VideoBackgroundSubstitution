function [I_rec] = fillcol(I,col)

array_col = I( :,col);

first_index = find(array_col,1,'first');
last_index = find(array_col,1,'last');

array_col(first_index:last_index) = 1;
I(:,col)=array_col;
I_rec=I;

