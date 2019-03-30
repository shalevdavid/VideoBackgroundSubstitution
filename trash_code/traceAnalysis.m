 
 maskp=mask;
  [r,c] = find(maskp);
 SetOfPoints = [r,c];
 p=16;
 M=8;
 In = GREEN;
 Ip = greenpre;
 
 [SetOfNewPoints] = TraceObject(SetOfPoints, Ip, In, maskp, M, p);
 
maskn = zeros(J,K);
for j=1:size(SetOfNewPoints,1) 
    maskn(SetOfNewPoints(j,1),SetOfNewPoints(j,2))=1;
end;
