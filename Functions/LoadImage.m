function [im, wellName, imageName] = LoadImage(imageFileName)
%function to load an im and determine its well and im name
%based on the filename used to locate it
%
%INPUTS
%imageFileName		-	string, the file location of the im to load
%
%OUTPUTS
%im				-	the image matrix
%
%wellName			-	the name of the well from which the im came
%
%imageName			-	the name of the image
%

	tempFileName = imageFileName;
	im = imread(imageFileName);
    
    if ~isa(im,'uint16')
        im = uint16(im);
    end
   
	%remove trailing filesep character
	if(tempFileName(size(tempFileName,2)) == filesep)
		tempFileName = tempFileName(1:size(tempFileName,2)-1);
	end

	%isolate im name
	filesepIdx = find(tempFileName == filesep);
	imageName = tempFileName(filesepIdx(size(filesepIdx,2))  + 1: ...
							 size(tempFileName,2));

	%isolate well name
	wellName = tempFileName(filesepIdx(size(filesepIdx,2)-1) + 1: ...
							filesepIdx(size(filesepIdx,2))   - 1);

end
