function [d1,d2]=dijksta1_v222_fun(spx,spy,m_spx1,m_spx2,m_spx3,m_spy1,m_spy2,m_spy3,cell_weight,mat)
global weight;
[row,coloumn]=size(mat);

flag1=0;
flag2=0;
flag3=0;

 spx=spx+1;
 spy=spy+1;
 m_spx1=m_spx1+1;
 m_spy1=m_spy1+1;
 m_spx2=m_spx2+1;
 m_spy2=m_spy2+1;
 m_spx3=m_spx3+1;
 m_spy3=m_spy3+1;

t=zeros(row+2,coloumn+2);  %t is vertices mat and contain the places we were in
t(:,[1,end])=1000; % border.
t([1,end],:)=1000;

d1=zeros(row+2,coloumn+2);  %the x cordinates of the previous pixel we came from (in weight-it is the arrow)
d2=zeros(row+2,coloumn+2);  %the y cordinates of the previous pixel
weight = [];
weight(1:row+2,1:coloumn+2)=1000;
weight(spx,spy)=0;

open = [spx,spy];
open_weight = weight(open(1,1),open(1,2));
while flag1==0 | flag2==0 | flag3==0
%for i=1:(row*coloumn)
    [m,min_i]= min(open_weight);
    X = open(min_i,1);
    Y = open(min_i,2);
    
    %remove point from open list
    open = open([1:min_i-1,min_i+1:end],:);
    open_weight = open_weight([1:min_i-1,min_i+1:end],:);
    
    if t(X,Y)==1000
        continue;
    end
    
%	[r,c]=find(weight+t==min(min(weight+t)));    % finding the 'cordinatot' of the min spot in dist
%	X=r(1);
%	Y=c(1);
	t(X,Y)=1000;
     
    if X==m_spx1 & Y==m_spy1
         flag1=1;
     end
     if X==m_spx2 & Y==m_spy2
         flag2=1;
     end
	  if X==m_spx3 & Y==m_spy3
         flag3=1;
     end	
	neighbors_weigth = weight(X+[-1:1],Y+[-1:1]);
	neighbors_d1 = d1(X+[-1:1],Y+[-1:1]);
	neighbors_d2 = d2(X+[-1:1],Y+[-1:1]);
	neighbors = weight(X,Y)+t(X+[-1:1],Y+[-1:1])+cell_weight{X-1,Y-1};%%changed
	neighbors(2,2) = inf;
	
	%find open neighbors;
	open_neighbors = find(neighbors < neighbors_weigth);
    [open_X,open_Y] = find(neighbors < neighbors_weigth);
	
	% update weight to all open neighbors
	neighbors_weigth(open_neighbors) = cell_weight{X-1,Y-1}(open_neighbors)+weight(X,Y);%%changed
	neighbors_d1(open_neighbors) = X-1;
	neighbors_d2(open_neighbors) = Y-1;
	
    open = [open;X+open_X-2,Y+open_Y-2 ];
    open_weight = [ open_weight ; neighbors_weigth(open_neighbors) ];
        
    % update the matrixes.
	weight(X+[-1:1],Y+[-1:1]) = neighbors_weigth;
	d1(X+[-1:1],Y+[-1:1]) = neighbors_d1;
	d2(X+[-1:1],Y+[-1:1]) = neighbors_d2; 
    
end;

% remove the border.
weight = weight(2:end-1,2:end-1);
d1 = d1(2:end-1,2:end-1);
d2 = d2(2:end-1,2:end-1);
t = t(2:end-1,2:end-1);