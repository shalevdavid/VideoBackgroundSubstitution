%%%  recievs current image and its motion vectors in matrixes
%%%  and returns the estimated next image based on these matrixes

function [next] = Estimate_Next(current,...
                                 Motion_Est_Matrix_row,...
                                 Motion_Est_Matrix_col,block_size);

[n_row,n_col]=size(current);
next(n_row,n_col)=0;


%%%%  In case of overfllow
% 
% if ( mod(n_row,block_size)==0 )
%     last_row = n_row;
% else 
%     last_row = block_size * floor(n_row/block_size);
% end;
% 
% if ( mod(n_col,block_size)==0 )
%     last_col = n_col;
% else 
%     last_col = block_size * floor(n_col/block_size);
% end;
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
for i=1:block_size:n_row
    for j=1:block_size:n_col
       
         temp(1:block_size,1:block_size)=current(i:(i+block_size-1) , j:(j+block_size-1));

         
         mov_row = Motion_Est_Matrix_row(    1+(i-1)/block_size   ,   1+(j-1)/block_size     );
         
         mov_col = Motion_Est_Matrix_col(    1+(i-1)/block_size   ,   1+(j-1)/block_size     );
         
         row_ass1 = i+block_size*mov_row;        
         row_ass2 = i-1+block_size*(mov_row+1);
         col_ass1 = j+block_size*mov_col; 
         col_ass2 = j-1+block_size*(mov_col+1);
         
         condition1 = row_ass1<=n_row;
         condition2 = row_ass2<=n_row;
         condition3 = row_ass1>=1;
         condition4 = row_ass2>=1;
         condition5 = col_ass1<=n_col;
         condition6 = col_ass2<=n_col;
         condition7 = col_ass1>=1;
         condition8 = col_ass2>=1;
         
       
         if (      condition1  &&   condition2  &&  condition3  &&   condition4  && ...
                   condition5  &&  condition6  &&    condition7  &&  condition8      )
                
                    next(   row_ass1 : row_ass2 ,...
                            col_ass1  : col_ass2 ...
                          ) = double(temp);
                          
         end;   %% if condition
      
   end;   %% for j   
end;   %% for i