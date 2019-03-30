%%% the object we would like to trace is given to us by the set of points in
%%% the primary frame, and we would like to estimate for every point its new
%%% location in the next frame
%%% Ip = Primary frame image (in double)
%%% In = next frame image (in double)
%%% In this algorithem we estimate for every point ( in  (row,col)  pairs) when
%%% SetOfPoints(i,:) is the pair i

%%% before the function is called
%%%  [r,c] = find(mask);
%%%  SetOfPoints = [r,c];

%%% after the function is called
% % % masknew = zeros(J,K);
% % % for j=1:size(SetOfNewPoints,1) 
% % %     masknew(SetOfNewPoints(j,1),SetOfNewPoints(j,2))=1;
% % % end;

function [SetOfNewPoints,AvgComputation] = TraceObjectNTSScorr(SetOfPoints, Ip, In, maskp, M, p)

[J,K] =  size(Ip);
TotalComputation = 0;
SetOfNewPoints=[];

for i=1:size(SetOfPoints,1)
    
    r = SetOfPoints(i,1);
    c = SetOfPoints(i,2);
    
    r1 = r-M;
    r2 = r+M;
    c1 = c-M;
    c2 = c+M;
    
    if  ( r1<= 0 )
        r1 = 1;
        r2 = 2*M+1;
    end;
    
    if ( c1<= 0 )
        c1 = 1;
        c2 = 2*M+1;
    end;
    
    if  ( r2>= J )
        r2 = J;
        r1 = J-2*M;
    end;
    
    if  ( c2>= K )
        c2 = K;
        c1 = K-2*M;
    end;
       
    maskBlock = maskp(r1:r2,c1:c2);
    
    [motionVect, NTSScomputations] = BlockTraceNTSScorr(In, Ip, maskBlock, 2*M+1, p, r1, c1);
    
    TotalComputation = TotalComputation + NTSScomputations;
    SetOfNewPoints(i,:) = SetOfPoints(i,:) + motionVect;
    
end;

if (size(SetOfPoints,1)==0)
    AvgComputation=0;
else
    AvgComputation = TotalComputation/size(SetOfPoints,1);
end;
    
    