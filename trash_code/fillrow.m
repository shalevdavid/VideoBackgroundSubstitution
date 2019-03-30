function [I_rec] = fillrow(I,row)

array_row = I(row, :);

first_index = find(array_row,1,'first');
last_index = find(array_row,1,'last');

array_row(first_index:last_index)=1;
I(row,:)=array_row;
I_rec=I;

