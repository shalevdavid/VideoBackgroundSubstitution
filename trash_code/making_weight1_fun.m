
function [cell_weight]=making_weight1_fun(mat_r,mat_g,mat_b,mat)
 w_fg=7/10;
 w_fz=2/10;
 w_fd=1/10;
 
row=size(mat_r,1);
coloumn=size(mat_r,2);

weight=cell(row,coloumn);

Ix(1:row,1:coloumn-1)=mat(:,2:coloumn)-mat(:,1:coloumn-1);
Ix = [Ix ones(size(Ix,1),1)];
Iy(1:row-1,1:coloumn)=mat(2:row,:)-mat(1:row-1,:);
Iy = [Iy; ones(1,size(Iy,2))];

%%%%%%%%%%%%%%%%%calculating the red fg 
Ix_r(1:row,1:coloumn-1)=mat_r(:,2:coloumn)-mat_r(:,1:coloumn-1);
Ix_r = [Ix_r ones(size(Ix_r,1),1)];
Iy_r(1:row-1,1:coloumn)=mat_r(2:row,:)-mat_r(1:row-1,:);
Iy_r = [Iy_r; ones(1,size(Iy_r,2))];

G_r=sqrt(Ix_r(1:row,1:coloumn).^2+Iy_r(1:row,1:coloumn).^2);
fg_r=(max(max(G_r))-G_r(1:row,1:coloumn))/max(max(G_r));
%%%%%%%%%%%%%%%%%calculating the green fg 
Ix_g(1:row,1:coloumn-1)=mat_g(:,2:coloumn)-mat_g(:,1:coloumn-1);
Ix_g = [Ix_g ones(size(Ix_g,1),1)];
Iy_g(1:row-1,1:coloumn)=mat_g(2:row,:)-mat_g(1:row-1,:);
Iy_g = [Iy_g; ones(1,size(Iy_g,2))];

G_g=sqrt(Ix_g(1:row,1:coloumn).^2+Iy_g(1:row,1:coloumn).^2);
fg_g=(max(max(G_g))-G_g(1:row,1:coloumn))/max(max(G_g));
%%%%%%%%%%%%%%%%%calculating the blue fg 
Ix_b(1:row,1:coloumn-1)=mat_b(:,2:coloumn)-mat_b(:,1:coloumn-1);
Ix_b = [Ix_b ones(size(Ix_b,1),1)];
Iy_b(1:row-1,1:coloumn)=mat_b(2:row,:)-mat_b(1:row-1,:);
Iy_b = [Iy_b; ones(1,size(Iy_b,2))];

G_b=sqrt(Ix_b(1:row,1:coloumn).^2+Iy_b(1:row,1:coloumn).^2);
fg_b=(max(max(G_b))-G_b(1:row,1:coloumn))/max(max(G_b));
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ix_y(1:row,1:coloumn-1,)=mat_y(:,2:coloumn)-mat_y(:,1:coloumn-1);
% Ix_y = [Ix_y ones(size(Ix_y,1),1)];
% Iy_y(1:row-1,1:coloumn)=mat_y(2:row,:)-mat_y(1:row-1,:);
% Iy_y = [Iy_y; ones(1,size(Iy_y,2))];
% 
% G_y=sqrt(Ix_y(1:row,1:coloumn).^2+Iy_y(1:row,1:coloumn).^2);
% fg_y=(max(max(G_y))-G_y(1:row,1:coloumn))/max(max(G_y));


%%%%%%%%%%%%%%%%%calculating the average fg
%fg=1/3*(fg_r+fg_g+fg_b);
fg=min(min(fg_r,fg_g),fg_b);


%%%%%%%%%%%%%%%%%calculating  fz 

fz_r=edge(mat_r,'zerocross');
fz_g=edge(mat_g,'zerocross');
fz_b=edge(mat_b,'zerocross');
% fz_y=edge(mat_y,'zerocross');


fz=(fz_r | fz_g | fz_b);
fz=1-fz;
%%%%%%%%%%%%%%%%%

den = sqrt(Ix.^2+Iy.^2)+eps;
Dx = Ix./den;
Dy=Iy./den;

for i=1:size(mat,1)
    for j=1:size(mat,2)
        cell_weight{i,j}=1000*ones(3,3);
        X=i;
        Y=j;
        rnb=1;  %row num begining
        rnf=3; %row num final
        cnb=1; %column num begining
        cnf=3;  %column num final
        rnb_b=1;  %row num begining
        rnf_f=3; %row num final
        cnb_b=1; %column num begining
        cnf_f=3;  %column num final
        l=X+1;
        m=X-1;
        h=Y-1;
        k=Y+1;

        if X==1  %the edge of the pic-fill the missing pixels with 100
            rnb=2; 
            rnb_b=3;
            m=X+1;
        elseif X==size(mat,1)  %20 is the size of row & coloumn
            rnf=2;
            rnf_f=1;
            l=X-1;
        end;
     
         if Y==1
             cnb=2;
             cnb_b=3;
             h=Y+1;
        elseif Y==size(mat,2)
            cnf=2;
            cnf_f=1;
             k=Y-1;
        end;
    
    %%%
%making fd  matric    
        
    dist=1000*ones(3,3);
 % the vector p is [ X , Y ];
 % the vector q is [X+dx,Y+dy];
        Dp_x=Dy(X,Y);
        Dp_y=-Dx(X,Y);
        for dx=-1:1
            if ((X+dx)>=1 & (X+dx)<=size(mat,1))
                for dy=-1:1
                    if ((Y+dy)>=1 & (Y+dy)<=size(mat,2))
                        if (dx~=0 || dy~=0)
                            Dq_x=Dy(X+dx,Y+dy);
                            Dq_y=-Dx(X+dx,Y+dy);
                        
                            % define L(p,q);
                            product = dx*Dp_x + dy*Dp_y;
                            if product>=0
                                Lpq_x=dx;
                                Lpq_y=dy;
                            else
                                Lpq_x=-dx;
                                Lpq_y=-dy;
                            end
                            den2=sqrt(Lpq_x^2+Lpq_y^2);
                            Lpq_x = Lpq_x/den2;
                            Lpq_y = Lpq_y/den2;
                        
                            % calculate dp and dq
                            dp = (Dp_x*Lpq_x+Dp_y*Lpq_y)/2;
                            dq=(Lpq_x*Dq_x+Lpq_y*Dq_y)/2;
                        
                            fd=(acos(dp)+acos(dq))/pi;
                            dist(dx+2,dy+2)=fd; 
                           
                    end
                end
            end
        end
    end
        cell_weight{i,j}(rnb_b:2:rnf_f,cnb_b:2:cnf_f)=w_fd*dist(rnb_b:2:rnf_f,cnb_b:2:cnf_f)+w_fg*1.414*fg(m:2:l,h:2:k)+w_fz*fz(m:2:l,h:2:k);
 
        if Y~=size(fg,2)
            cell_weight{i,j}(2,3)=w_fd*dist(2,3)+w_fg*fg(X,Y+1)+w_fz*fz(X,Y+1);
          end;
   
        if Y~=1
              cell_weight{i,j}(2,1)=w_fd*dist(2,1)+w_fg*fg(X,Y-1)+w_fz*fz(X,Y-1);
        end;
   
        if X~=1
            cell_weight{i,j}(1,2)=w_fd*dist(1,2)+w_fg*fg(X-1,Y)+w_fz*fz(X-1,Y);
        end;
   
        if X~=size(fg,1)
            cell_weight{i,j}(3,2)=w_fd*dist(3,2)+w_fg*fg(X+1,Y)+w_fz*fz(X+1,Y);
        end;
        
   end;
end;

