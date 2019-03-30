Main.m - The main function


functions:

clean_noise_param.m:

	diff - B/W Image
	param - The maximal size of linked group that will be cleaned from the "diff" image.

fill_holes_param.m:

	mask - the mask we want to fill
	param - the maximum size of holes (size in pixels) that we would like to fill in the mask

solidify_image_param.m:

	im - a B/W image
	param_rec - The rectangle element by which the edge is closed
	param_line - The line element by which the edge is closed
	param_pha - The phase element by which the edge is closed

CreateMaskASD.m:

	Binarization using Blocks
	M is the block size, Image is the unknown image,  SourceBackground is
	the backgroung of the movie
	Image and SourceBackground  are 2D arrays of the same size
	This function recieves Image and Background and creates a block mask by
	its ASD in the blocks reffered to a gloabal saf
	ASD = Absolute Sum Differences

CreateMaskMAD.m:

	Binarization using Blocks
	M is the block size, Image is the unknown image,  SourceBackground is
	the backgroung of the movie
	Image and SourceBackground  are 2D arrays of the same size
	This function recieves Image and Background and creates a block mask by
	its MAD in the blocks reffered to a gloabal saf
	MAD = Mean Absolute Differences


CreateMaskCorr.m:

	Binarization using Blocks
	M is the block size
	Image is the unknown image
	SourceBackground is the backgroung we would like to substruct
	This function recieves Image and Background and creates a block mask by
	its Correlation in the blocks reffered to a gloabal saf  

MaskCenterization.m:

	This function recieves a mask, and a movenment vector and  moves
	the mask according to that vector 