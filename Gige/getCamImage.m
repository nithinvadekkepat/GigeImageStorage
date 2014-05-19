function getCamImage()
close all;clear all;
imaqreset;
date = datestr(clock,'dd-mm-yy');
ret = exist(date,'dir');
if ~ret
    mkdir(date);
end
currentPath = pwd;
writePath = strcat(currentPath,'\',date);
logo = imread('logo_drishtiman.png');
mainFig = figure('position',[100 60 1200 650 ],'MenuBar','none','name',...
    'Gige Camera Acquisition','NumberTitle','off','Resize','off');
logoAxes = axes('Parent',mainFig,'Units', 'normalized','Position',[0.02 0.88 0.1 0.1],'Visible','on');
set(mainFig,'CurrentAxes',logoAxes)
imshow(logo)
drawnow
axis image
axis tight
axis off
uicontrol('Style','pushbutton','Parent', mainFig,'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.05 0.08 0.1 0.05],...
    'String','Start Camera',...
    'Callback', @startCamButtonCallBack);
uicontrol('Style','pushbutton','Parent', mainFig,'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.25 0.08 0.1 0.05],...
    'String','Estimate Background',...
    'Callback', @backgroundEstimationButtonCallBack);
uicontrol('Style','pushbutton','Parent', mainFig,'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.5 0.08 0.1 0.05],...
    'String','Start Process',...
    'Callback', @processButtonCallBack);
uicontrol('Style','pushbutton','Parent', mainFig,'Units','normalized',...
    'HandleVisibility','callback', ...
    'Position',[0.8 0.08 0.1 0.05],...
    'String','Exit Process',...
    'Callback', @exitButtonCallback);
camAxes =  axes('Parent',mainFig,'Units', 'normalized','Position',[0.02 0.2 0.4 0.6],'Visible','on');

acqAxes =  axes('Parent',mainFig,'Units', 'normalized','Position',[0.5 0.2 0.4 0.6],'Visible','off');
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
vid = videoinput('winvideo',2);
vid.FramesPerTrigger = 1;
vid.ReturnedColorspace = 'rgb';
triggerconfig(vid, 'manual');
vidRes = get(vid, 'VideoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);
nBands = get(vid, 'NumberOfBands');
backBuffer = 5;
background = zeros(imHeight,imWidth);
blobObj = vision.BlobAnalysis('AreaOutputPort',1,'MinimumBlobArea',1000);
set(mainFig,'CurrentAxes',camAxes)
hImage = image(zeros(imHeight, imWidth, nBands));
axis tight
axis off


    function startCamButtonCallBack(src, eventdata)
        preview(vid,hImage)
        axis image
        axis tight
        axis off
    end
    function backgroundEstimationButtonCallBack(src,eventdata)
        framegrabber = zeros(imHeight,imWidth,backBuffer);
        for i = 1:backBuffer
            framegrabber(:,:,i) = rgb2gray(getsnapshot(vid));
        end
        background = mean(framegrabber,3);
    end
    function processButtonCallBack(src,eventdata)
        setappdata(hImage,'UpdatePreviewWindowFcn',@update_get_object);
    end
    function update_get_object(obj,event,hImage)
        currentFrame = event.Data;
        background = double(background);
        currentFrame = double(rgb2gray(currentFrame));
        foreground = abs(background - currentFrame);
        binaryBackground = (foreground > 15);
        set(mainFig,'CurrentAxes',acqAxes)
        imshow(binaryBackground);
        drawnow
        area = step(blobObj,binaryBackground);
        if numel(area) > 0
            if numel(area) > 1 || area(1) > 50000
                set(mainFig,'CurrentAxes',acqAxes)
                text(256,256,'remove hand','FontSize',28,'Color',[1 0 0])
                drawnow
            else
                timestamp = datestr(clock,'HH_MM_SS');
                imwrite(uint8(currentFrame),fullfile(writePath,strcat(timestamp,'.jpg')));
            end
        end
    end
        
        function  exitButtonCallback(src, eventdata)
            stoppreview(vid)
            close all;
        end
end