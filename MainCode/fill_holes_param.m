% % %  An ingenious idea to fill holes 
% % % mask = the mask we want to fill
% % % param = the maximum size of holes (size in pixels) that we would like to fill
% % % in the mask

function [mask_filled] = fill_holes_param( mask , param)

mask_filled = 1 - clean_noise_param( 1-mask,param);