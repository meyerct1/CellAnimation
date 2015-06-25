function [] = LocalNaiveSegment(D)
directory		= D.imDir;
wellName		= D.wellName;
imageNameBase 	= D.imageNameBase;
fileExt			= D.fileExt;
digitsForEnum	= D.digitsForEnum;
startIndex		= D.startIndex;
endIndex		= D.endIndex;
framestep		= D.framestep;
outdir			= D.outdir;
expName         = D.ExpName

h = waitbar(0,'Segmenting: 0 Percent Complete')

%Include the CIDRE image correction
if D.CIDRE == 1
    load([D.outdir filesep D.ExpName 'CIDRE_Model' filesep  D.ExpName '_cidreModel.mat']
end
%export each object set as a csv file for interfacing with R
for(imNum=startIndex:endIndex)
    %To get the correct number of zeros for each image enumeration
	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * framestep)

	%Load Image name the objSet well name and image name
    %Forces the image to be a 16bit depth image.
	[im, objSet.wellName, objSet.imageName] = ...
		LoadImage([	directory filesep ...
					wellName filesep ...
					imageNameBase imNumStr fileExt]);
    %Add for cases where the images are not uint16
    if D.CIDRE == 1
        im = (im-uint16(CINDREmodel.z)./(uint16(CINDREmodel.v)));
    end
    
	%segment
	[objSet.props, objSet.labels] = ...
		NaiveSegment(D, im, 'BackgroundThreshold', D.BT, 'TopHatRadius', D.THR, 'NoiseThreshold', D.NT, 'FillHoles', D.FH);

	%export to CSV file for classification
	SetToCSV(objSet, [	outdir filesep ...
                        expName filesep ...
						wellName filesep ...
						'naive' filesep ...
						imageNameBase imNumStr '.csv']);

	%save output
	save([	outdir filesep ...
            expName filesep...
			wellName filesep ...
			'naive' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');

	clear objSet;
	clear imNumStr;
	clear im;
    num = abs((imNum-endIndex)./frameStep)./abs((startIndex-endIndex)./frameStep);
    str = sprintf('Segmenting: %2.1f Percent Complete',num*100)
    waitbar(num,h,str)
	
end

%close waitbar
close(h)
end
