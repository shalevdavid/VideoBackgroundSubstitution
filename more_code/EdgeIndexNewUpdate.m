function [ObjectsArrayNew,u_new,v_new] = EdgeIndexNewUpdate(ObjectsArray,u,v)

ObjectsArrayNew=[];
u_new =[];
v_new =[];
index=0;
for k=1:length(u)
    if (ObjectsArray(k).count == 2)
        index=index+1;
        u_new(index)=u(k);
        v_new(index)=v(k);
        ObjectsArrayNew(index).array=ObjectsArray(k).array;
    end;
end;
