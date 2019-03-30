function [] = DrawPath(mask)

    [ObjectsArray,u,v] = EdgeIndexNew(mask);
    [ObjectsArrayNew,u_new,v_new] = EdgeIndexNewUpdate(ObjectsArray,u,v);
    [SetOrder] = PathArrange(ObjectsArrayNew,u_new,v_new);
    t=zeros(size(mask));
    for i =1:length(SetOrder)
        t( u_new(SetOrder(i)) , v_new(SetOrder(i)) )=1;
        imshow(t);
        pause(0.025);
    end;