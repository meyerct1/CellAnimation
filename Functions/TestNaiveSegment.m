function [p,l] = TestNaiveSegment(H, im, varargin)

% 	% Defaults
% 	radius              = 50;  
% 	% Filter out background bigger than 50 pixel areas
% 	backgroundThreshold = 0.2; 
% 	% 20% below normalized is off, 80% is real.
% 	fillholes           = 1;   
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
				radius = v{1};
			case 'NoiseThreshold'
				v=varargin(2*a);
				noiseThreshold = v{1};
			case 'BackgroundThreshold'
				v=varargin(2*a);
				backgroundThreshold=v{1};
			case 'FillHoles'
				if ~strcmpi(varargin(2*a), 'true')
					fillholes = 0;
				end
			otherwise
				error('Improper Argument in Call to NaiveSegment');
		end
    end
    
    %On the subplot of the current figure defined by H
    
    subplot(H.testOrg)
    imshow(im*2, [min(min(im)) max(max(im))]);
    title('Original')
    
    % Added on 26MAR14; works only for 3 x 3 montage
    % Subtract background
    background_im = imread([directory filesep ...
					wellName filesep 'DsRed - Confocal - Background.tif']);
    im = imsubtract(im, background_im);
    
    % Subtract background, in pixel radius (default 50) tophat filter
    i	= imtophat(im2double(im), strel('disk', radius));
	j	= i; 
  
	% maps the intensity values such that 1% of data is saturated 
	% at low and high intensities 
	i	= imadjust(i);
    
	% To Binary Image 
	i	= im2bw(i, backgroundThreshold);

	% Remove Noise
	if noiseThreshold > 0.0
		noise = imtophat(i, strel('disk', noiseThreshold));
		i = i - noise;
	end
  
	% Fill Holes
	if fillholes
		i = imfill(i, 'holes');
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
	[bounds,L,N] = bwboundaries(i);

    subplot(H.testFin)
    imshow(i)
    hold on
    
    for k = 1:size(bounds,1)
        boundary = bounds{k};
         if(k > N)
           plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
         else
           plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
         end
    end
    str = sprintf('Red = Segmented Cells\nGreen = Holes')
    title(str)
    hold off
    
end % NaiveSegment
