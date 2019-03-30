[motionVect, ARPScomputations] = motionEstARPS(double(Ibw3), double(Ibw2),M,p );                   
[mask_next_estimation] = motionComp(double(mask), motionVect, M);    

[motionVectReverse ARPScomputations] = motionEstARPS(double(Ibw2), double(Ibw3),M,p );
[mask_next_Reverse] = motionComp(double(mask_next_estimation), motionVectReverse, M);
maskaddition=(1-mask).*mask_next_estimation;
maskdecresion1 = (1-mask_next_estimation).*mask;
% maskdecresion2 = (1-mask_next_Reverse).*mask;
maskdecresion3 = (1-mask_next_estimation).*mask_next_Reverse;

maskdecresion = (maskdecresion1+maskdecresion2+maskdecresion3)>0;


masknew = (mask_next_estimation - maskdecresion)>0;