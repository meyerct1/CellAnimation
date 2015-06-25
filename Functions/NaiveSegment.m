function [p,l] = NaiveSegment(D, image, varargin)

directory		= D.imDir;
wellName		= D.wellName;
imageNameBase 	= D.imageNameBase;
fileExt			= D.fileExt;
digitsForEnum	= D.digitsForEnum;
startIndex		= D.startIndex;
endIndex		= D.endIndex;
framestep		= D.framestep;
outdir			= D.outdir;
expName         = D.ExpName;

% 	% Defaults
% 	radius              = 50;  
% 	% Filter out background bigger than 50 pixel areas
% 	backgroundThreshold = 0.2; 
% 	% 20% below normalized is off, 80% is real.
 	fillholes           = 1;   
% 	% Please fill holes
% 	noiseThreshold      = 3;   
% 	% 3 pixel circles 
	nargs = size(varargin,2);
  
    %Make sure the arguments come in an even number
	if ~ (2*floor(nargs/2) == nargs)
		error('Improper Call to NaiveSegment');
	end
  
	nargs = floor(size(varargin,2)/2);
  
	% Decode arguments
	for a=1:nargs
		switch varargin{2*a-1}
			case 'TopHatRadius'
				v=varargin(2*a);
				radius = str2num(v{1});
			case 'NoiseThreshold'
				v=varargin(2*a);
				noiseThreshold = str2num(v{1});
			case 'BackgroundThreshold'
				v=varargin(2*a);
				backgroundThreshold=str2num(v{1});
			case 'FillHoles'
				if ~strcmpi(varargin(2*a), 'true')
					fillholes = 0;
				end
			otherwise
				error('Improper Argument in Call to NaiveSegment');
		end
    end
    
    % Added on 26MAR14; works only for 3 x 3 montage
    % Subtract background
    background_im = imread([directory filesep ...
					wellName filesep 'DsRed - Confocal - Background.tif']);
    image = imsubtract(image, background_im);
    
    % Subtract background, in pixel radius (default 50) tophat filter
    %Use only if CIDRE hasn't been run on the image
    if D.CIDRE~=1 
        i	= imtophat(im2double(image), strel('disk', radius));
        j	= i; 
    else
        i = im2double(image);
    end
  
	% maps the intensity values such that 1% of data is saturated 
	% at low and high intensities 
	i	= imadjust(i);
    % i = imadjust(i,[],[]);
    % i = imadjust(i,[;],[]);
    
	% To Binary Image 
	i	= im2bw(i, backgroundThreshold);

	% Remove Noise
	if noiseThreshold > 0.0
		noise = imtophat(i, strel('disk', noiseThreshold));
		i = i - noise;
	end
  
	% Fill Holes
	if fillholes
		i	= imfill(i, 'holes');
	end
  
	l	= bwlabel(i);
  
	% Segment properties (with holes filled)
	p	= regionprops(l,...
					'Area',				'Centroid',			...
					'MajorAxisLength',	'MinorAxisLength',	...
					'Eccentricity', 	'ConvexArea',		...
					'FilledArea',		'EulerNumber',  	...
					'EquivDiameter',	'Solidity',			...
					'Perimeter',		'PixelIdxList',		...
					'PixelList',		'BoundingBox',		...
					'Orientation');
   
	% Compute intensities from background adjusted image
	bounds = bwboundaries(i);
	for obj=1:size(p,1)
		
		p(obj).label = obj;    

		p(obj).Intensity =  sum(j(p(obj).PixelIdxList));
    
		p(obj).bound = bounds{obj};
    
		p(obj).edge    = 0;
		if find(p(obj).PixelList(:,1) == 1)
			p(obj).edge = 1;
		end

		if find(p(obj).PixelList(:,2) == 1)
			p(obj).edge = 1;
		end

		if find(p(obj).PixelList(:,1) == size(i,2) )
			p(obj).edge = 1;
		end

		if find(p(obj).PixelList(:,2) == size(i,1) )
			p(obj).edge = 1;
		end

	end
  
	p = ClassifyFirstPass(p);
  
	clear i;
	clear j;
	clear bounds;
	clear noise;
 
end % NaiveSegment
