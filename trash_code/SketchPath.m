% this function gets mask, isolates its  outer boarder , operates an
% algorithem that we have developed by ourselves which is supposed to
% arange the limit by their position order
% this function also finds the center of mass and returns it as the seed point
% expected for the sciccoring algorithem

function [x,y] = SketchPath(mask)

    x=[];
    y=[];
    [ObjectsArray,u,v] = EdgeIndexNew(mask);
    [ObjectsArrayNew,u_new,v_new] = EdgeIndexNewUpdate(ObjectsArray,u,v);
    [SetOrder] = PathArrange(ObjectsArrayNew,u_new,v_new);
    for i =1:length(SetOrder)
        x(i) = u_new(SetOrder(i));
        y(i) = v_new(SetOrder(i));
    end;
    
    x=x';
    y=y';
    


