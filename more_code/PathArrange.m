function [SetOrder] = PathArrange (ObjectsArrayNew,u_new,v_new)

SetOrder = [];
index = [];
indicator=zeros(size(u_new));
i=round(length(u_new)/2);
stop=0;
num_iterations=0;
if i==0
    stop=1;
end
while ( stop==0   ||   num_iterations<length(u_new) )
    indicator(i)=1;
    num_iterations=num_iterations+1;
    SetOrder(num_iterations)=i;
    
    point = [u_new(i),v_new(i)]';
    NeiArray = ObjectsArrayNew(i).array;
    
    N1 = NeiArray(:,1);
    N2 = NeiArray(:,2);
    
    j=1;
    while ( j<=length(u_new) && (((u_new(j)==N1(1))+(v_new(j)==N1(2))) ~=2) )
        j=j+1;
    end
    
    if ( (j<=length(u_new)) && (indicator(j)==1) )
        j=1;
        while ( j<=length(u_new) && (((u_new(j)==N2(1))+(v_new(j)==N2(2))) ~=2) )
            j=j+1;
        end
        if (   (j<=length(u_new))  && (indicator(j)==1)  )
            stop=1;
        end;
    end
    
    if (j>length(u_new))
        dis=(u_new(i)-u_new).^2 +(v_new(i)-v_new).^2;
        dis(find(dis(:)==0))=inf;
        dis(find(indicator(:)==1))=inf;
         [mindis,min_index] = min(dis);
         j=min_index;
    end
    
    i=j;
    
end
    


    
    
    