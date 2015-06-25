function [] = Main()
%Import the images in the folder selected
% image_importGui asks user to locate the image directory where the images
% are being stored and begins segmentation
%  Create and then hide the UI as it is being constructed.
%Christian Meyer 06/06/15


%Declare structure for passing handles in GUI
H = struct()
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
        
%Load in the functions in the funDir
addpath(D.funDir)

%Main figure
H.Mainfig       =   figure('Name','CellAnimation','NumberTitle','off',...
                    'Visible','on','Position',[360,500,500,500]);           
            
H.loadExp       =   uicontrol('Style','pushbutton',...
                        'string','Load Experiment','units','normalized',...
                        'position',[.1,.9,.35,.1]);
        
H.startExp      =   uicontrol('Style','pushbuttion',...
                    'string','Start Experiment','units','normalized',...
                    'position',[.55,.9,.35,.1]);
        
H.SegmentImages =   uicontrol('Style','pushbutton','string','Segment Images',...
                    'units','normalized','position',[.1,.75,.35,.1]);
            
H.LoadSegmented =   uicontrol('Style','pushbutton','string','Load Segmented Images',...
                    'units','normalized','position',[.55,.75,.35,.1]);
    
H.createClass   =   uicontrol('Style','pushbutton','string','Create Classifier',...
                    'units','normalized','position',[.1,.6,.35,.1]);
                
H.loadClass 	=   uicontrol('Style','pushbutton','string','Load Classifier',...
                    'units','normalized','position',[.55,.6,.35,.1]);

H.ldCellTrack   =   uicontrol('Style','pushbutton','string','Load Cell Tracker',...
                    'units','normalized','position',[.1,.45,.35,.1]);
                
H.stCellTrack   =   uicontrol('Style','pushbutton','string','Start Cell Tracker',...
                    'units','normalized','position',[.55,.45,.35,.1]);

H.assaySel      =   uicontrol('Style','listbox',{'list of assays here'},...
                    'units','normalized','position',[.1,.3,.35,.1]);
            
H.assayRun      =   uicontrol('Style','pushbutton','string','Run Assay',...
                    'units','normalized','position',[.55,.3,.35,.1]); 
            
H.helpScreen    =   uicontrol('Style','pushbutton','string','Help',...
                    'units','normalized','position',[.55,.75,.35,.1]);
            
%Set call backs for all the buttons...            
set(H.startExp,'call',@ExpCreator)

            
            
            
%%Gui for the setting up of an experiment
    function [] = ExpCreator()
        H.figExpCreator = figure('Name','Create an Experiment','numbertitle', 'off',...
                                'Position',[500,500,500,500]);
                            
        % Construct the components for cell segementation.
        uicontrol('style','text','string','Select Directory',...
                  'units','normalized','position',[.05,1,.2,.1])
        
        H.imDir   =   uicontrol('Style','pushbutton',...
                        'string',D.imDir,'Units','normalized',...
                        'Position',[.05,.9,.4,.1]);
                    
        H.wellName  =   uicontrol('style','listbox',...
                        'string',['Select Well' D.wellName],'units','normalized',...
                        'position',[.5,.9,.4,.1]);
                    
        uicontrol('style','text','string','Image Base Name',...
                    'units','normalized','position',[.05,.8,.2,.1])

        H.imageNameBase = uicontrol('style','edit',...
                            'string',D.imageNameBase,'units','normalized',...
                            'position',[.05,.7,.3,.1]);

        uicontrol('style','text','string','file extension',...
                    'units','normalized','position',[.4,.8,.2,.1])

        H.fileExt = uicontrol('style','edit',...
                            'string','.tif','units','normalized',...
                            'position',[.4,.7,.2,.1]);
                        
        uicontrol('style','text','string','Start Index/End Index',...
                    'units','normalized','position',[.75,.8,.25,.1])

        H.startIndex = uicontrol('style','edit',...
                            'string',D.startIndex,'units','normalized',...
                            'position',[.75,.7,.1,.1]);
                        
        H.endIndex = uicontrol('style','edit',...
                            'string',D.endIndex,'units','normalized',...
                            'position',[.9,.7,.1,.1]);
                        
        uicontrol('style','text','string','frame step','units',...
                'normalized','position',[.05,.55,.,2.1])
                        
        H.framestep = uicontrol('style','edit',...
                            'string','1','units','normalized',...
                            'position',[.25,.55,.1,.1]);
                        

        uicontrol('style','text','string',...
            'Number of Digits in image name (eg n00001 = 6)',...
            'units','normalized','position',[.4,.6,.3,.2])
        
        H.digitsForEnum = uicontrol('style','edit',...
                            'string','6','units','normalized',...
                            'position',[.6,.6,.1,.2]);
  
        uicontrol('style','text','string','Experiment Name',...
            'units','normalized','position',[.05,.4,.2,.1])

        H.ExpName   =       uicontrol('style','edit',...
                            'string','Test','units','normalized',...
                            'position',[.05,.3,.2,.1]);
                        
        uicontrol('style','text','string','Select Output Directory',...
            'units','normalized','position',[.3,.4,.2,.1])

                        
        H.outdir   =   uicontrol('Style','pushbutton',...
                        'string',D.imDir,'Units','normalized',...
                        'Position',[.3,.3,.2,.1]);
                    

                    
        H.closeWin = uicontrol('style','pushbutton','string','Create',...
                                'units','normalized','position',[.4,.05,.2,.1])
                            
        set(H.imDir,'call',@filFinder);
        set(H.outdir,'call',@filFinder2);
        set(H.closeWin,'call',@closeFun);
    %Wait until the current figure is closed to proceed
        uiwait()

        
        %Nested Function to get directory        
        function [] = filFinder()
            str = uigetdir();
            set(H.imDir,'string',str)
            str2 = dir(str)
            %Give list box options of well names in experiment
            set(H.wellName,'string',{str2.name})
        end
        %Function to get the name
        function [] = filFinder2()
                str = uigetfile();
                set(H.outDir,'string',str)
        end
            
        function [] = closeFun()
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
            save([D.outdir filesep D.ExpName] '-struct', 'D');
            close(H.figExpCreator)
        end
    end


    function [] = SegFun()
        H.segFig = figure('Name','CellAnimation Segmenter', 'umbertitle', 'off','position',[500 500 500 500]);
        
        uicontrol('Style','text',...
                'String',{'BackgroundThreshold Percent'},...
                'Units','normalized',...
                'Position',[.05,1,.4,.1]);
            
        uicontrol('Style','text',...
                'String',{'TopHatRadius'},...
                'Units','normalized',...
                'Position',[.05,.8,.4,.1]);
            
        uicontrol('Style','text',...
                'String',{'NoiseThreshold'},...
                'Units','normalized',...
                'Position',[.05,.6,.4,.1]);
            
        uicontrol('Style','text',...
                'String',{'FillHoles'},...
                'Units','normalized',...
                'Position',[.05,.4,.4,.1]);
            
        H.txt1      =   uicontrol('Style', 'edit','units','normalized',...
                        'string', num2str(D.BT),'position',[.4,.9,.1,.1]);
                    
        H.BTval     =   uicontrol('Style','slide',...
                        'Units','normalized',...
                        'Position',[.05,.9,.35,.1],...
                        'min',0,'max',1,'val',str2num(D.BT));
                    
        H.THRval     =  uicontrol('Style','edit',...
                        'string','50',...
                        'Units','normalized',...
                        'Position',[.05,.7,.2,.1]);
                    
        H.NTval     =   uicontrol('Style','edit',...
                        'string','3',...
                        'Units','normalized',...
                        'Position',[.05,.5,.2,.1]);
                    
        H.FHval     =   uicontrol('Style','listbox',...
                        'string',{'true','false'},...
                        'Units','normalized',...
                        'Position',[.05,.3,.2,.1]);
                    
        H.testSeg   =   uicontrol('style','pushbutton','string','Test Parameters',...
                        'units','normalized','position',[.05,.1,.1,.1]);
                    
        H.segIm     =   uicontrol('Style','pushbutton',...
                        'String','Naive Segment','Units','normalized',...
                        'Position',[.30,.1,.1,.1]);
            
            
        set(H.segIm,'call',{@load_Im})
        set(H.BTval,'call',{@setVal})
        set(H.testSeg,'call',{@testSeg})
        
        uiwait()

        %Nested functions for segmentation gui
        %Function to update the text box next to the slider with the current value    
        function [] = setVal()
            set(H.txt1,'string',num2str(get(H.BTval,'val')))
        end

        function[] = testSeg()
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

            if H.segfig == 0
                H.segfig = figure('Name','Test Segmenter','NumberTitle', 'off')
            end

            %segment
            [objSet.props, objSet.labels] = ...
                TestNaiveSegment(H,im, 'BackgroundThreshold', D.BT, 'TopHatRadius', D.THR, 'NoiseThreshold', D.NT, 'FillHoles', D.FH);

        end


        function [] = load_Im()
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
        end
    end
end
