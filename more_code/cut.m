function [negative_matrix,cut_matrix]=cut(path_x,path_y,math,zoom_paste_mode)

[row,coloumn,l]=size(math);
%  
x_max=path_x(find(path_x==max(path_x)));
y_max=path_y(find(path_y==max(path_y)));
x_min=path_x(find(path_x==min(path_x)));
y_min=path_y(find(path_y==min(path_y)));
 
x_center=(x_max(1)+x_min(1))/2;
y_center=(y_max(1)+y_min(1))/2;

%cut_matrix=zeros(x_max(1)-x_min(1),y_max(1)-y_min(1));

path=zeros(row,coloumn);
path_matrix=zeros(row,coloumn,l);
for j=1:size(path_x,1)
    path(path_x(j),path_y(j))=1;
end
% path_matrix=line(path_x,path_y,'w');
path=imfill(path,'holes')-path;
path=filter2(ones(5)/25,path,'same');
% figure(1); imshow(path);
negative_matrix=1-path(x_min(1):x_max(1),y_min(1):y_max(1));
% figure(3);imshow(negative_matrix);
% % negative_matrix=filter2(ones(5)/25,negative_matrix,'same');
 %figure(4);imshow(negative_matrix);

negative_matrix=repmat(negative_matrix,[1 1 3]);

% figure(1);imshow(negative_matrix);

path_matrix=repmat(path,[1 1 3]);

path_matrix=uint8(path_matrix.*double(math));

cut_matrix=path_matrix(x_min(1):x_max(1),y_min(1):y_max(1),:);
if zoom_paste_mode==1
    negative_matrix=imresize(negative_matrix,1/3);
    cut_matrix=imresize(cut_matrix,1/3);
end

%  figure(2);imshow(path_matrix);
%  figure(3);imshow(negative_matrix);
%  figure(4);imshow(cut_matrix);