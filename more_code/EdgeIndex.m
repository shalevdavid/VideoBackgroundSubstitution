%   mask is a filled binary image. This function returns it's outer limit's
%   indexes  e.g.  its edge indexes
%
%   mask = I_close - a filled binary image with 0's and 1's only
%   save_index = the indexes of the neigbours found for [u,v] 
%   sizes_array = number of neigbours found in [u,v]
%   u = the outer edge of the mask ROW indexes
%   v = the outer edge of the mask COL indexes

function [save_index,sizes_array,u,v] = EdgeIndex (mask) 

edge_mask = edge(mask,'prewitt');
[len_u,len_v]=size(mask);
[u ,v] = find(edge_mask(2:len_u-1,2:len_v-1)==1);
 u = u+ones(1,length(u))';
 v = v+ones(1,length(v))';
 tic
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
                    
                    if (edge_mask(u(k)+i,v(k)+j)==1 && flag==1)
                            count=count+1;
                            save_index(:,count) = [u(k)+i,v(k)+j]';
                    end;
                    
                    sizes_array(1,k)=count;
            
                    %do_something ( save_index );
           
            end;
        end;
        
 end;
 toc