function [] = Main()
%Import the images in the folder selected
% image_importGui asks user to locate the image directory where the images
% are being stored and begins segmentation
%  Create and then hide the UI as it is being constructed.
%Christian Meyer 06/06/15


%Declare structure for passing handles in GUI
H = struct();
%Declare a structure for passing data in GUI
%Set default values here
D = struct('imDir','Test_images',...
            'wellName', 'Well D02',...
            'imageNameBase', 'DsRed - Confocal - n',...
            'fileExt' , '.tif',...
            'digitsForEnum' , 6,...
            'startIndex' , 1,...
            'endIndex' , 10,...
            'framestep' , 1,...
            'outdir' , 'Results',...
            'ExpName', 'Test',...
            'funDir' , 'Functions',...
            'BT','0.2',...
            'THR','50',...
            'NT','3',...
            'FH','true');
%Cell Object structure      
CO = struct();
        
%Load in the functions in the funDir
addpath(D.funDir)

%Main figure
H.Mainfig       =   figure('Name','CellAnimation','NumberTitle','off',...
                    'Visible','on','Position',[360,500,500,500]);           
            
H.loadExp       =   uicontrol('Style','pushbutton',...
                        'string','Load Experiment','units','normalized',...
                        'position',[.1,.9,.35,.1]);
        
H.startExp      =   uicontrol('Style','pushbutton',...
                    'string','Create Experiment','units','normalized',...
                    'position',[.55,.9,.35,.1]);
        
H.SegmentImages =   uicontrol('Style','pushbutton','string','Segment Images',...
                    'units','normalized','position',[.55,.75,.35,.1]);
            
H.LoadSegmented =   uicontrol('Style','pushbutton','string','Load Segmented Images',...
                    'units','normalized','position',[.1,.75,.35,.1]);
    
H.createClass   =   uicontrol('Style','pushbutton','string','Add Baysian Classifier',...
                    'units','normalized','position',[.55,.6,.35,.1]);
                
H.loadClass 	=   uicontrol('Style','pushbutton','string','Resegment Cells with Classifier',...
                    'units','normalized','position',[.1,.6,.35,.1]);

H.ldCellTrack   =   uicontrol('Style','pushbutton','string','Load Cell Tracker',...
                    'units','normalized','position',[.1,.45,.35,.1]);
                
H.stCellTrack   =   uicontrol('Style','pushbutton','string','Start Cell Tracker',...
                    'units','normalized','position',[.55,.45,.35,.1]);

H.assaySel      =   uicontrol('Style','listbox','string', {'list of assays here' '1'},...
                    'units','normalized','position',[.1,.3,.35,.1]);
            
H.assayRun      =   uicontrol('Style','pushbutton','string','Run Assay',...
                    'units','normalized','position',[.55,.3,.35,.1]); 
            
H.helpScreen    =   uicontrol('Style','pushbutton','string','Help',...
                    'units','normalized','position',[.3,.1,.35,.1]);
            
%Set call backs for all the buttons...            
set(H.startExp,'call',@ExpCreator)
set(H.SegmentImages,'call',@SegFun)
set(H.loadExp,'call',@loadExperiment)
set(H.LoadSegmented,'call',@ldSeg)
set(H.createClass,'call',@crClass)
            
            
            
%%Load a previously set up experiment
    function [] = loadExperiment(varargin)
        str = uigetfile();
        load(str)
    end
%Load the segmented images 
    function [] = ldSeg(varargin)
        
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
        i = 1
        %export each object set as a csv file for interfacing with R
        for(imNum=startIndex:endIndex)
            %To get the correct number of zeros for each image enumeration
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep)

            %save output
            load([	outdir filesep ...
                    ExpName filesep...
                    wellName filesep ...
                    'naive' filesep ...
                    imageNameBase imNumStr '.mat'], 'objSet');

            CO(i).objSet = objSet;
            i = i+1;
        end
    end
%Create an experiment
    function [] = ExpCreator(varargin)
        H.figExpCreator = figure('Name','Create an Experiment','numbertitle', 'off',...
                                'Position',[500,500,500,500]);
                            
        % Construct the components for cell segementation.
        uicontrol('style','text','string','Select Directory',...
                  'units','normalized','position',[.05,.9,.3,.1],'horizontalalignment','left')
        
        H.imDir   =   uicontrol('Style','pushbutton',...
                        'string',D.imDir,'Units','normalized',...
                        'Position',[.05,.85,.4,.1]);
                    
        H.wellName  =   uicontrol('style','listbox',...
                        'string',['Select Well' D.wellName],'units','normalized',...
                        'position',[.5,.85,.4,.1]);
                    
        uicontrol('style','text','string','Image Base Name',...
                    'units','normalized','position',[.05,.7,.3,.1],'horizontalalignment','left')

        H.imageNameBase = uicontrol('style','edit',...
                            'string',D.imageNameBase,'units','normalized',...
                            'position',[.05,.65,.3,.1]);

        uicontrol('style','text','string','file extension',...
                    'units','normalized','position',[.4,.7,.2,.1],'horizontalalignment','left')

        H.fileExt = uicontrol('style','edit',...
                            'string','.tif','units','normalized',...
                            'position',[.4,.65,.2,.1]);
                        
        uicontrol('style','text','string','Start Index/End Index',...
                    'units','normalized','position',[.3,.5,.4,.1],'horizontalalignment','left')

        H.startIndex = uicontrol('style','edit',...
                            'string',D.startIndex,'units','normalized',...
                            'position',[.3,.45,.1,.1]);
                        
        H.endIndex = uicontrol('style','edit',...
                            'string',D.endIndex,'units','normalized',...
                            'position',[.5,.45,.1,.1]);
                        
        uicontrol('style','text','string','frame step','units',...
                'normalized','position',[.05,.5,.2,.1],'horizontalalignment','left');
                        
        H.framestep = uicontrol('style','edit',...
                            'string','1','units','normalized',...
                            'position',[.05,.45,.2,.1]);
                        

        uicontrol('style','text','string',...
            'Number of Digits (eg n00001 = 6)',...
            'units','normalized','position',[.65,.72,.35,.1],'horizontalalignment','left')
        
        H.digitsForEnum = uicontrol('style','edit',...
                            'string','6','units','normalized',...
                            'position',[.65,.65,.1,.1]);
  
        uicontrol('style','text','string','Experiment Name',...
            'units','normalized','position',[.05,.3,.3,.1],'horizontalalignment','left')

        H.ExpName   =       uicontrol('style','edit',...
                            'string','Test','units','normalized',...
                            'position',[.05,.25,.3,.1]);
                        
        uicontrol('style','text','string','Select Output Directory',...
            'units','normalized','position',[.4,.3,.4,.1],'horizontalalignment','left')

                        
        H.outdir   =   uicontrol('Style','pushbutton',...
                        'string',D.imDir,'Units','normalized',...
                        'Position',[.4,.25,.4,.1]);
                    

                    
        H.closeWin = uicontrol('style','pushbutton','string','Create',...
                                'units','normalized','position',[.4,.05,.2,.1])
                            
        set(H.imDir,'call',@filFinder);
        set(H.outdir,'call',@filFinder2);
        set(H.closeWin,'call',@closeFun);
    %Wait until the current figure is closed to proceed
        uiwait()

        
        %Nested Function to get directory        
        function [] = filFinder(varargin)
            str = uigetdir();
            set(H.imDir,'string',str)
            str2 = dir(str)
            %Give list box options of well names in experiment
            set(H.wellName,'string',{str2.name})
        end
        %Function to get the name
        function [] = filFinder2(varargin)
                str = uigetfile();
                set(H.outDir,'string',str)
        end
            
        function [] = closeFun(varargin)
            D.imDir = get(H.imDir,'string');
            D.wellName = get(H.wellName,'string');
            D.imageNameBase = get(H.imageNameBase,'string');
            D.startIndex = str2num(get(H.startIndex,'string'));
            D.endIndex = str2num(get(H.endIndex,'string'));
            D.fileExt = get(H.imageNameBase,'string');
            D.digitsForEnum = str2num(get(H.digitsForEnum,'string'));
            D.framestep = str2num(get(H.framestep,'string'));
            D.outdir = get(H.outdir,'string');
            D.ExpName = get(H.ExpName,'string');
            save([D.outdir filesep D.ExpName], '-struct', 'D');
            close(H.figExpCreator)
        end
    end
%Segment the cells including testing
    function [] = SegFun(varargin)
        H.segFig = figure('Name','CellAnimation Segmenter', 'numbertitle', 'off','position',[100 100 1000 700]);
        
        uicontrol('Style','text',...
                'String',{'BackgroundThreshold Percent'},...
                'Units','normalized',...
                'Position',[.05,.85,.4,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'TopHatRadius'},...
                'Units','normalized',...
                'Position',[.05,.65,.4,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'NoiseThreshold'},...
                'Units','normalized',...
                'Position',[.05,.45,.4,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'FillHoles'},...
                'Units','normalized',...
                'Position',[.05,.25,.4,.1],'horizontalalignment','left');
            
        H.txt1      =   uicontrol('Style', 'edit','units','normalized',...
                        'string', num2str(D.BT),'position',[.4,.8,.1,.1]);
                    
        H.BTval     =   uicontrol('Style','slide',...
                        'Units','normalized',...
                        'Position',[.05,.8,.35,.1],...
                        'min',0,'max',1,'val',D.BT);
                    
        H.THRval     =  uicontrol('Style','edit',...
                        'string','50',...
                        'Units','normalized',...
                        'Position',[.05,.6,.2,.1]);
                    
        H.NTval     =   uicontrol('Style','edit',...
                        'string','3',...
                        'Units','normalized',...
                        'Position',[.05,.4,.2,.1]);
                    
        H.FHval     =   uicontrol('Style','listbox',...
                        'string',{'true','false'},...
                        'Units','normalized',...
                        'Position',[.05,.2,.2,.1]);
                    
        H.testSeg   =   uicontrol('style','pushbutton','string','Test Parameters',...
                        'units','normalized','position',[.05,.05,.2,.1]);
                    
        H.segIm     =   uicontrol('Style','pushbutton',...
                        'String','Naive Segment','Units','normalized',...
                        'Position',[.30,.05,.2,.1]);
            
            
        set(H.segIm,'call',{@segIm})
        set(H.BTval,'call',{@setVal})
        set(H.testSeg,'call',{@testSeg})
        
        uiwait()

        %Nested functions for segmentation gui
        %Function to update the text box next to the slider with the current value    
        function [] = setVal(varargin)
            set(H.txt1,'string',num2str(get(H.BTval,'val')))
        end

        function[] = testSeg(varargin)
            D.BT = get(H.BTval,'val')
            D.THR = str2num(get(H.THRval,'string'))
            D.NT = str2num(get(H.NTval,'string'))
            D.FH = get(H.NTval,'string')

            %Copied code from LocalNaiveSegment.m
            directory		= D.imDir;
            wellName		= D.wellName;
            imageNameBase 	= D.imageNameBase;
            fileExt			= D.fileExt;
            digitsForEnum	= D.digitsForEnum;
            startIndex		= D.startIndex;
            endIndex		= D.endIndex;
            framestep		= D.framestep;
            outdir			= D.outdir;
            imNum = D.startIndex  %Just pick the first image
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep)

            %Load Image name the objSet well name and image name
            [im, objSet.wellName, objSet.imageName] = ...
                LoadImage([	directory filesep ...
                            wellName filesep ...
                            imageNameBase imNumStr fileExt]);

            %segment
            [objSet.props, objSet.labels] = ...
                TestNaiveSegment(H, im, 'BackgroundThreshold', D.BT, 'TopHatRadius', D.THR, 'NoiseThreshold', D.NT, 'FillHoles', D.FH);
            
            clearvars -except D H
        end


        function [] = SegIm(varargin)
            D.imDir = get(H.imDir,'string');
            D.wellName = get(H.wellName,'string');
            D.imageNameBase = get(H.imageNameBase,'string');
            D.startIndex = get(H.startIndex,'string');
            D.endIndex = get(H.endIndex,'string');
            D.BT = str2num(get(H.BTval,'string'))
            D.THR = str2num(get(H.THRval,'string'))
            D.NT = str2num(get(H.NTval,'string'))
            D.FH = get(H.NTval,'string')

            %Open gui to work with local naive segment...
            LocalNaiveSegment(D)
            
            close(H.segFig)
        end
    end

    function [] = crClass(varargin)
        H.figClass = figure('name','Segment Review','numbertitle','off','position',[500,500,800,500])
          
        %Set up GUI elements
        H.listbox_class = uicontrol('style','listbox','string',...
                        {'Select Object to Classify','Debris','Nucleus','Pre-Division','Post Division','Apoptotic','Oversegmented','Undersegmented','Newborn'},...
                        'units','normalized','value',2,'position',[0,.72,.2,.25]);
        H.brighten = uicontrol('style','slider','min',0,'max',3,'val',1,'units','normalized','position',[0,.57,.2,.1]);
        H.brightentxt = uicontrol('style','text','string','Brighten Image','units','normalized','position',[0,.67,.2,.05]);

        H.numFound = uicontrol('style','text','string','0','units','normalized','position',[0,.4,.2,.1]);
        H.numFoundtxt = uicontrol('style','text','string','Number Identified','units','normalized','position',[0,.5,.2,.05]);
        H.nextIm = uicontrol('style','pushbutton','string','Next Image','units','normalized','position',[0,.3,.1,.1]);
        H.firstIm = uicontrol('style','pushbutton','string','First Image','units','normalized','position',[0.1,.3,.1,.1]);
        H.saveCl = uicontrol('style','pushbutton','string','Save','units','normalized','position',[.05,.1,.1,.1]);
        
        H.subfigIM = subplot(1,2,2)
        set(gca,'visible','off')
        set(H.subfigIM,'units','normalized')
        set(H.subfigIM,'position',[.2,0,1,1])
        
        set(H.nextIm,'call',@nextImage)
        set(H.brighten,'call',@bright)
        set(H.firstIm,'call',@firstImage)
        set(H.saveCl,'call',@saveClass)
        set(H.listbox_class,'call',@lbclass)
        
        %Run through the first image
        mkdir([outdir filesep ExpName filesep wellName filesep 'baysian']);

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
        currentIM = startIndex;  %
        
        imNum = currentIM;
        %To get the correct number of zeros for each image enumeration
        imNumStr = sprintf('%%0%dd', digitsForEnum);
        imNumStr = sprintf(imNumStr, imNum * framestep)

        %Load Image name the objSet well name and image name
        [im, objSet.wellName, objSet.imageName] = ...
            LoadImage([	directory filesep ...
                        wellName filesep ...
                        imageNameBase imNumStr fileExt]);


        imshow(im,[])
        hold on
        load([	outdir filesep ...
                expName filesep...
                wellName filesep ...
                'naive' filesep ...
                imageNameBase imNumStr '.mat']);
        CO(1).objSet = objSet;
        for k = 1:length(CO(1).objSet.props)
            if CO(1).objSet.props.debris(k)
               plot(CO(1).objSet.props.Perimeter(:,1),CO(1).objSet.props.Perimeter(:,2),'red')
            end
        end
        
        while 1
            [x,y,button] = ginput(1)
            num = CO(1).objSet.labels(x,y)
            
            
        

        uiwait()
        
        %Function to brighten the image displayed
        function [] = bright(varargin)
            imNum = currentIM;
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep)

            %Load Image name the objSet well name and image name
            [im, objSet.wellName, objSet.imageName] = ...
                LoadImage([	directory filesep ...
                            wellName filesep ...
                            imageNameBase imNumStr fileExt]);
                        
            subplot(H.subfigIM)
            hold on
            num = get(H.brighten,'value')
            imshow(im*num,[])
            
            if get(H.listbox_class,'value') ~=1
            %Fill in with plotting the current object classified
            end
            hold off
        end
        
        function [] = lbclass(varargin)
            imNum = currentIM;
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep)

            
            load([	outdir filesep ...
                    expName filesep...
                    wellName filesep ...
                    'naive' filesep ...
                    imageNameBase imNumStr '.mat']);
                
                num = get(H.listbox_class,'value')
                %Print out current classifiers
            switch
                case 2
                    print(1)
                case 2
                case 3
                case 4
                case 5
                case 6
                    
            
        end
        
        function [] = firstImage(varargin)
            imNum = 1;
            
            %To get the correct number of zeros for each image enumeration
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep)

            %Load Image name the objSet well name and image name
            [im, objSet.wellName, objSet.imageName] = ...
                LoadImage([	directory filesep ...
                            wellName filesep ...
                            imageNameBase imNumStr fileExt]);
                        
        end
        
        
        function [] = nextImage(varargin)
            imNum = i+1;
            
            %To get the correct number of zeros for each image enumeration
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep)

            %Load Image name the objSet well name and image name
            [im, objSet.wellName, objSet.imageName] = ...
                LoadImage([	directory filesep ...
                            wellName filesep ...
                            imageNameBase imNumStr fileExt]);

            %save output
            load([	outdir filesep ...
                    expName filesep...
                    wellName filesep ...
                    'naive' filesep ...
                    imageNameBase imNumStr '.mat']);
            
            CO(i).objSet = objSet;
            %Write gui for actually storing the object names...
            subplot(H.subfigIM)
            num = get(H.brighten,'value')
            imshow(im*num,[])
            clear objSet
            i = i+1;
        end
        
        function [] = saveCl(varargin)
        	SetToCSV(objSet, [	outdir filesep ...
                        expName filesep ...
						wellName filesep ...
						'naive' filesep ...
						imageNameBase imNumStr '.csv']);

            %save output
            save([	outdir filesep ...
                    expName filesep...
                    wellName filesep ...
                    'baysian' filesep ...
                    imageNameBase imNumStr '.mat'], 'objSet');
        end
        
    end
        

        
        
        


end
