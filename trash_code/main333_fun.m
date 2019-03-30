%%%%%includes the more shorted djikstra_v222 
function [path2,path_x,path_y]=main333_fun(spx,spy,x,y,num_of_points,math)
tic;
%clear all;
% close all;
global weight;

path_x=[];
path_y=[];

spx=round(spx);
spy=round(spy);

x=[x;spx];
y=[y;spy];

x=round(x);
y=round(y);

mat = double(rgb2gray(math));
%mat = mean(math,3);
mat_r = double(math(:,:,1));
mat_g = double(math(:,:,2));
mat_b = double(math(:,:,3));
mat_y=double(rgb2ycbcr(math));

path2=math;

figure(1); imshow(math);
 
%  [cell_weight]=making_weight1_fun(mat);
  [cell_weight]=making_weight1_fun(mat_r,mat_g,mat_b,mat);

  k=1;
  
 while k<(num_of_points)
    [d1,d2]=dijksta1_v222_fun(spx,spy,x(k),x(k+1),x(k+2),y(k),y(k+1),y(k+2),cell_weight,mat);
    m_spx1=x(k);  %kk
    m_spy=y(k) ; %kk
    [xx,yy,path]=making_path1_fun(spx,spy,m_spx1,m_spy,d1,d2,weight);
    xx1=xx;
    yy1=yy;


    m_spx2=x(k+1);  %kk
    m_spy=y(k+1);  %kk 
    [xx,yy,path]=making_path1_fun(spx,spy,m_spx2,m_spy,d1,d2,weight);
    xx2=xx;
    yy2=yy;
%     for_end_pathx=xx2;
%     for_end_pathy=yy2;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m_spx3=x(k+2);  %k
    m_spy=y(k+2);  %kk 
    [xx,yy,path]=making_path1_fun(spx,spy,m_spx3,m_spy,d1,d2,weight);
    xx3=xx;
    yy3=yy;
    for_end_pathx=xx3;
    for_end_pathy=yy3;
%%%%%%%%%%%%%%%%%%%%%%%
figure(1);imshow(math);
 %figure(1);
h1=line(yy1,xx1);
set(h1,'color','g');
h2=line(yy2,xx2);
set(h2,'color','g');
h3=line(yy3,xx3);
set(h3,'color','b');
drawnow;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sub1=size(xx2,1)-size(xx1,1); %the dec
        
    if sub1>=0   %matching xx1 and xx2
        xx2=xx2(sub1+1:size(xx2,1),1);
        yy2=yy2(sub1+1:size(yy2,1),1);
     else     
          xx1=xx1(-sub1+1:size(xx1,1),1);
          yy1=yy1(-sub1+1:size(yy1,1),1);

      end
     xx=[xx1 xx2];
     yy=[yy1 yy2];
     
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      sub2=size(xx,1)-size(xx3,1); %the dec
        
    if sub2>=0   %matching xx1 and xx2
        xx=xx(sub2+1:size(xx,1),:);
        yy=yy(sub2+1:size(yy,1),:);
     else     
          xx3=xx3(-sub2+1:size(xx3,1),1);
          yy3=yy3(-sub2+1:size(yy3,1),1);

      end
     xx=[xx xx3];
     yy=[yy yy3];
     
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
     j=size(xx,1);

    while (j~=1) & (xx(j,1)==xx(j,2) & xx(j,2)==xx(j,3) & yy(j,1)==yy(j,2) & yy(j,2)==yy(j,3) )
           j=j-1;
     end
%size_xx1_b=size(xx1,1)
    if j==1
        xx1=flipud(xx1(j:end,1));
        yy1=flipud(yy1(j:end,1));
    else
         xx1=flipud(xx1(j+1:size(xx1,1),1));
         yy1=flipud(yy1(j+1:size(yy1,1),1));
     end
     
     if ( size(xx1,1) > 5 )
         path_x=[ path_x; xx1];
         path_y=[ path_y; yy1];     
     
     %size_xx1_a=size(xx1,1)
     
         spx=xx1(end,1);
         spy=yy1(end,1);
     end
     
     k=k+1;

 end


%%%%adding the final point for drawing the final path
 path_x=[ path_x; for_end_pathx(1:size(for_end_pathx,1),1)];
 path_y=[ path_y; for_end_pathy(1:size(for_end_pathy,1),1)];   
 
     %%%%drawing the final path
 for l=1: size(path_x,1)
     path2(path_x(l,1),path_y(l,1),:)=1;
end
   toc