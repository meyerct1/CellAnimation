function [CO] = userGuidedCellPlot(D,H,CO,imNum)
%%Function to interactively reclassify objects and save the output into the
%%Baysian folder

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

%Find what is the current image index
currentIM = abs(startIndex-imNum)./framestep+1;
%For handles of the plotted objects
h = struct();
cnt = 1;



%To get the correct number of zeros for each image enumeration
imNumStr = sprintf('%%0%dd', digitsForEnum);
imNumStr = sprintf(imNumStr, imNum * framestep);

%Load Image name the objSet well name and image name
[im, objSet.wellName, objSet.imageName] = ...
    LoadImage([	directory filesep ...
                wellName filesep ...
                imageNameBase imNumStr fileExt]);

%Plot results on the subplot
subplot(H.subfigIM)
num = get(H.brighten,'value');
imshow(im*num,[])
hold on

if get(H.listbox_class,'value') ~=1
   %If an updated Baysian objSet exists load that one...
    if exist([	outdir filesep ...
                expName filesep...
                wellName filesep ...
                'baysian' filesep ...
                imageNameBase imNumStr '.mat'],'file')==2
            load([outdir filesep ...
                expName filesep...
                wellName filesep ...
                'baysian' filesep ...
                imageNameBase imNumStr '.mat'])

    else
        load([	outdir filesep ...
                expName filesep...
                wellName filesep ...
                'naive' filesep ...
                imageNameBase imNumStr '.mat']);
    end




%set the cell object of the current image to the loaded objSet    
CO(currentIM).objSet = objSet;

%Reference matrix for handles to the different object plots
ref = nan(length(CO(currentIM).objSet.props)); %Column is the image number

%Color codes for each type
%Produce a legend window with all the colors and instructions
col = hsv(8);


num = get(H.listbox_class,'value');
class = get(H.listbox_class,'string');
class = class(num);

%Plot all the objects
for k = 1:length(CO(currentIM).objSet.props)
   %Keep all the handle references list
    if CO(currentIM).objSet.props(k).(class)    
       h(cnt) = plot(CO(currentIM).objSet.props(k).bound(:,1),CO(currentIM).objSet.props(k).bound(:,2),'color',col(:,1));
       ref(k) = cnt; %What was the handle
       cnt = cnt+1;
    end

end

    %Get user imput on the cell to add or delete it
    while 1
        [x,y,button] = ginput(1);
        fnd = 0; %To indicate if this is a new object or an old one found
        if button ~= 1 || button ~=3 || x<0
            break;
        end

        %Figure out which cell it was
        num = CO(currentIM).objSet.labels(x,y);
        %If not a currently an object create one?
        if num ~=0
            for k = 1:length(CO(currentIM).objSet.props)
                if CO(currentIM).objSet.props.label(k) == num
                    fnd = 1;
                    if button == 1
                        CO(currentIM).objSet.props.(class)(k) = 1;
                        h(ref(k)) = plot(CO(currentIM).objSet.props.Perimeter(:,k),CO(currentIM).objSet.props.Perimeter(:,k),'red');
                    elseif button == 3
                        CO(currentIM).objSet.props.(class)(k) = 0;
                        delete(h(ref(k))); %Delete the plotted boundery
                    end
                end
            end

            if fnd == 0
                %Create new object...
                %temp = 
                %Bounding box of 200 should be enough...
            end
        end
    end

    %Save the ouput 
    %export to CSV file for classification
    SetToCSV(CO(currentIM).objSet, [outdir filesep ...
                        expName filesep ...
                        wellName filesep ...
                        'baysian' filesep ...
                        imageNameBase imNumStr '.csv']);

    %save output
    save([outdir filesep ...
            expName filesep...
            wellName filesep ...
            'baysian' filesep ...
            imageNameBase imNumStr '.mat'], C0(currentIM).objSet);

end