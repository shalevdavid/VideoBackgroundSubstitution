%   mask is a filled binary image. This function returns it's outer limit's
%   indexes  e.g.  its edge indexes, and also returns for every such pixel 
%   from its 8 neigbours those who belong to the edge also
%
%   mask = I_close - a filled binary image with 0's and 1's only
%   save_index = the indexes of the neigbours found for [u,v] 
%   u = the outer edge of the mask ROW indexes
%   v = the outer edge of the mask COL indexes
%  ObjectsArray = An array of STRUCT
%  count = the number of relevant neigbours of the pixel 
%  We have chosen to expand the mask image inorder to cope with 
%  problems the edge in the boarder of the image so the 
%  pixels over there will be found 

function [ObjectsArray,u,v] = EdgeIndexNew (mask) 

ExpendedMask = zeros(size(mask)+[2 2]);     %% expanding the mask - will be referred to as the ref image
[len_u,len_v]=size(ExpendedMask);
ExpendedMask(2:len_u-1,2:len_v-1)=mask;
edge_mask = edge(ExpendedMask,'prewitt');   %% edge_mask is the edge of the Expended Mask !!!

%  now, in case that the edge is deteted at the boarders of the ref image
% (e.g  the expended) we shift them into the lines whose limits 
% are contained in the source mask 
edge_mask(:,2)= ( (edge_mask(:,2)+edge_mask(:,1)) >0 );
edge_mask(:,1)=0;
edge_mask(:,len_v-1)=( (edge_mask(:,len_v-1)+edge_mask(:,len_v)) >0 );
edge_mask(:,len_v)=0;
edge_mask(2,:)= ( (edge_mask(2,:)+edge_mask(1,:)) >0 );
edge_mask(1,:)=0;
edge_mask(len_u-1,:) = ( (edge_mask(len_u-1,:)+edge_mask(len_u,:))>0 );
edge_mask(len_u,:)=0;

[u ,v] = find(edge_mask(2:len_u-1,2:len_v-1)==1);
 u = u+ones(1,length(u))';                          %% in order to relate to the ref image
 v = v+ones(1,length(v))';                          %% in order to relate to the ref image
 
 ObjectsArray = [];

for k=1:length(u) 
    
        save_index=0;
        save_index(2,:)=0;
        count=0;
    
        for i=-1:1
            for j=-1:1
                    
                    flag=1;
                    if (i==0 && j==0)
                            flag=0;
                    end;
                    
                    if (edge_mask(u(k)+i,v(k)+j)==1 && flag==1)                %%  shifting for the pixel position of the ref
                            count=count+1;
                            save_index(:,count) = [u(k)-1+i,v(k)-1+j]';              %%  entering the pixel position of the source !!!
                    end;
           
            end;     % for j
        end;    % for i
        
        ObjectsArray(k).array = save_index;
        ObjectsArray(k).count = count;
        
end;    % for k

 u = u-ones(1,length(u))';
 v = v-ones(1,length(v))';