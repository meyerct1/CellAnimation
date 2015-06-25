function [] = Main()
%Import the images in the folder selected
% asks user to locate the image directory where the images
% are being stored and begins segmentation
%  Create and then hide the UI as it is being constructed.
%Christian Meyer 06/22/15


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
            'assayDir','Assays',...
            'BT','0.2',...
            'THR','50',...
            'NT','3',...
            'FH','true',...
            'CIDRE','1');
%Cell Object structure      
CO = struct();
        
%Load in the functions in the funDir directory
addpath(D.funDir)
%Load the assays in the assayDir directory
addpath(D.assayDir)


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
                
H.loadClass 	=   uicontrol('Style','pushbutton','string','Segment with Classifier',...
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

%%Load the segmented images 
    function [] = ldSeg(varargin)
        
        %Keep the variable names in the structure unchanged and assign to
        %local variables
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
        i = 1 %for counting the number of images
        
        %export each object set as a csv file for interfacing with R
        for(imNum=startIndex:endIndex)
            %To get the correct number of zeros for each image enumeration
            imNumStr = sprintf('%%0%dd', digitsForEnum);
            imNumStr = sprintf(imNumStr, imNum * framestep)

            %Load the objSet for each image from the output directory
            %Allow loading from both naive and baysian folders
            load([	outdir filesep ...
                    ExpName filesep...
                    wellName filesep ...
                    'naive' filesep ...
                    imageNameBase imNumStr '.mat'], 'objSet');

            CO(i).objSet = objSet;
            i = i+1;
        end
    end

%%Create an experiment
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
            'units','normalized','position',[.65,.72,.35,.1],'horizontalalignment','left');
        
        H.digitsForEnum = uicontrol('style','edit',...
                            'string','6','units','normalized',...
                            'position',[.65,.65,.1,.1]);
  
        uicontrol('style','text','string','Experiment Name (include .mat)',...
            'units','normalized','position',[.05,.3,.3,.1],'horizontalalignment','left');

        H.ExpName   =       uicontrol('style','edit',...
                            'string','Test','units','normalized',...
                            'position',[.05,.22,.3,.1]);
                        
        uicontrol('style','text','string','Select Output Directory',...
            'units','normalized','position',[.4,.3,.4,.1],'horizontalalignment','left');

                        
        H.outdir   =   uicontrol('Style','pushbutton',...
                        'string',D.outdir,'Units','normalized',...
                        'Position',[.4,.22,.4,.1]);
                    

                    
        H.closeWin = uicontrol('style','pushbutton','string','Create',...
                                'units','normalized','position',[.6,.05,.2,.1]);
                            
        H.CIDRE = uicontrol('style','checkbox','string','Run Image Correction CIDRE','units','normalized',...
                            'position',[.05,.05,.5,.1],'value',D.CIDRE);
                            
        set(H.imDir,'call',@filFinder);
        set(H.outdir,'call',@filFinder2);
        set(H.closeWin,'call',@closeFun);

        
        %Wait until the current figure is closed to proceed
        uiwait()

        
        %Nested Function to get directory        
        function [] = filFinder(varargin)
            str = uigetdir();
            set(H.imDir,'string',str)
            str2 = dir(str);
            %Give list box options of well names in experiment
            set(H.wellName,'string',{str2.name})
        end
        
        %Function to get the name
        function [] = filFinder2(varargin)
                str = uigetdir();
                set(H.outDir,'string',str)
        end
            
        function [] = closeFun(varargin)
            %Place all the values in the structure and then save the
            %structure
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
            D.CIDRE = get(H.CIDRE,'value');
            
            %Make Directories to hold the results...
            mkdir([D.outdir filesep D.ExpName filesep wellName filesep 'Naive Segmentation'])
            mkdir([D.outdir filesep D.ExpName filesep wellName filesep 'Baysian Segmentation'])
            save([D.outdir filesep D.ExpName], 'D');
            
            %Run if CIDRE checkbox is marked
            if(get(H.CIDRE,'value')==1)
                %Now run cidre to generate the model
                mkdir([D.outdir filesep D.ExpName 'CIDRE_Model'])

                filNM = [D.imDir filesep ...
                                D.wellName filesep ...
                                '*' fileExt];
                cidreModelOutput = [D.outdir filesep D.ExpName 'CIDRE_Model' filesep]
                %Add in error messages for the cidre imaging            
                try          
                    CIDREmodel = cidre(filNM,'correction_mode',1);
                    catch ME
                        %if not monochromatic then do...
                end

                save([cidreModelOutput D.ExpName '_cidreModel.mat'],CIDREmodel)
            end
            
            close(H.figExpCreator)
        end
    end

%Segment the cells
%Allow for testing of preliminary segmentation parameters
    function [] = SegFun(varargin)
        H.segFig = figure('Name','CellAnimation Segmenter', 'numbertitle', 'off','position',[100 100 1000 700]);
        
        uicontrol('Style','text',...
                'String',{'BackgroundThreshold Percent'},...
                'Units','normalized',...
                'Position',[.01,.9,.19,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'TopHatRadius'},...
                'Units','normalized',...
                'Position',[.01,.7,.19,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'NoiseThreshold'},...
                'Units','normalized',...
                'Position',[.01,.5,.19,.1],'horizontalalignment','left');
            
        uicontrol('Style','text',...
                'String',{'FillHoles'},...
                'Units','normalized',...
                'Position',[.01,.33,.19,.1],'horizontalalignment','left');
            
        H.txt1      =   uicontrol('Style', 'edit','units','normalized',...
                        'string', num2str(D.BT),'position',[.15,.85,.05,.1]);
                    
        H.BTval     =   uicontrol('Style','slide',...
                        'Units','normalized',...
                        'Position',[.01,.85,.15,.1],...
                        'min',0,'max',1,'val',D.BT);
                    
        H.THRval     =  uicontrol('Style','edit',...
                        'string','50',...
                        'Units','normalized',...
                        'Position',[.01,.65,.2,.1]);
                    
        H.NTval     =   uicontrol('Style','edit',...
                        'string','3',...
                        'Units','normalized',...
                        'Position',[.01,.45,.2,.1]);
                    
        H.FHval     =   uicontrol('Style','listbox',...
                        'string',{'true','false'},...
                        'Units','normalized',...
                        'Position',[.01,.28,.2,.1]);
                    
        H.testSeg   =   uicontrol('style','pushbutton','string','Test Parameters',...
                        'units','normalized','position',[.01,.17,.2,.1]);
                    
        H.testOrg = subplot(2,2,2)
        set(gca,'visible','off')
        set(H.testOrg,'units','normalized')
        set(H.testOrg,'position',[.2,.5,.8,.5])
        H.testFin = subplot(2,2,4)
        set(gca,'visible','off')
        set(H.testFin,'units','normalized')
        set(H.testFin,'position',[.2,0,.8,.5])
                    
        H.segIm     =   uicontrol('Style','pushbutton',...
                        'String','Naive Segment','Units','normalized',...
                        'Position',[.01,0.05,.2,.1]);
            
            
        set(H.segIm,'call',{@segIm})
        set(H.BTval,'call',{@setVal})
        set(H.testSeg,'call',{@testSeg})
        
        uiwait()

        %Nested functions for segmentation gui
        %Function to update the text box next to the slider with the current value    
        function [] = setVal(varargin)
            set(H.txt1,'string',num2str(get(H.BTval,'val')))
        end
        
        %Function for opening up a gui to allow testing of the current
        %segmentation on the first image
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
            
            %Correct with CIDRE model           
            if D.CIDRE == 1
                load([D.outdir filesep D.ExpName 'CIDRE_Model' filesep  D.ExpName '_cidreModel.mat']
                im = (im-uint16(CIDREmodel.z)./(uint16(CIDREmodel.v)));
            end
            
            %Send to a test naive segmentation
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
            D.BT = str2num(get(H.BTval,'string'));
            D.THR = str2num(get(H.THRval,'string'));
            D.NT = str2num(get(H.NTval,'string'));
            D.FH = get(H.NTval,'string');

            %Open gui to work with local naive segment...
            LocalNaiveSegment(D)
            
            close(H.segFig)
        end
    end

%%Function to create a classifier
    function [] = crClass(varargin)
        H.figClass = figure('name','Segment Review','numbertitle','off','position',[500,500,800,500]);
          
        %Set up GUI elements
        H.listbox_class = uicontrol('style','listbox','string',...
                        {'Select Object to Classify','debris','nucleus','predivision','postdivision','apoptotic','over','under','newborn'},...
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
        
        imNum = D.startIndex;
        %Call the cell plotting function with the first image
        CO = userGuidedCellPlot(D,H,CO,imNum);

        uiwait()
        
        
        
        %Function to brighten the image displayed
        function [] = bright(varargin)
            CO = userGuidedCellPlot(D,H,CO,imNum);
        end
        
         function [] = lbclass(varargin)
            CO = userGuidedCellPlot(D,H,CO,imNum);
         end
       
        
        function [] = firstImage(varargin)
            imNum = D.startIndex;
            CO = userGuidedCellPlot(D,H,CO,imNum);
        end
        
        
        function [] = nextImage(varargin)
            imNum = imNum + D.framestep;
            CO = userGuidedCellPlot(D,H,CO,imNum);            
        end
        
        function [] = saveCl(varargin) 
            %Run boosting tree on all objSets
            %Build table configuration
            for i = 1:size(CO,1)
                if i == 1
                    master = struct2table(CO(i).objSet.props);
                else
                    temp = struct2table(CO(i).objSet.props);
                    master = vertcat(master,temp);
                end
            end
            
            master_class = cell(size(master,1),1);
            %Go through each instance and assign a product
            for i = 1:length(master)
                if master(
                master_class{i} = 
                temp(:,{'Centroid','BoundingBox','Orientation','PixelIdxList','PixelList','label','bound','debris','nucleus','over','under','predivision','postdivision','apoptotic','newborn'}) = [];
                
                    
                Area + MajorAxisLength + 
								MinorAxisLength + Eccentricity + 
								ConvexArea + FilledArea + 
								EulerNumber + EquivDiameter + 
								Solidity + Perimeter + 
								Intensity + MeanIntensity
            %Resegment based on boosting tree
            %Save everything
        end
        
    end

%%Function to load classifier
    function [] = ldClass(varargin)
    end

%%
        

        
        
        


end
