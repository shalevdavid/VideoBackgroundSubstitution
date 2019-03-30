function [cut_matrix,path2,path_x,path_y]=TightenMask(mask, I, decimation)

[spx,spy,x,y] = DrawPathNew(mask);
j=1:decimation:size(x,1);
x2=x(j);
y2=y(j);
[path2,path_x,path_y]=main333_fun(spx,spy,x2,y2,size(x2,1),I);
[negative_matrix,cut_matrix]=cut(path_x,path_y,I,0);