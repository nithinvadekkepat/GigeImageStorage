function getCamImage()
mainFig = figure('position',[100 60 1200 650 ],'MenuBar','none','name',...
    'Gige Camera Acquisition','NumberTitle','off','Resize','off');
logoAxes = axes('Parent',mainFig,'Units', 'normalized','Position',[0.02 0.88 0.1 0.1],'Visible','on');
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
camAxes =  axes('Parent',mainFig,'Units', 'normalized','Position',[0.02 0.2 0.4 0.6],'Visible','on');

acqAxes =  axes('Parent',mainFig,'Units', 'normalized','Position',[0.5 0.2 0.4 0.6],'Visible','on');
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
vid = videoinput('winvideo',1);
vid.FramesPerTrigger = 1;
vid.ReturnedColorspace = 'rgb';
triggerconfig(vid, 'manual');
vidRes = get(vid, 'VideoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);
nBands = get(vid, 'NumberOfBands');
backBuffer = 5;
background = zeros(imHeight,imWidth);
blobObj = vision.BlobAnalysis('AreaOutputPort','True','MaximumBlobArea',1000);



    function startCamButtonCallBack(src, eventdata)
        set(mainFig,'CurrentAxes',camAxes)
        hImage = image(zeros(imHeight, imWidth, nBands));
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
        foreground = abs(background - currentFrame);
        binaryBackground = im2bw(foreground);
        area = step(blobObj,binaryBackground);
        area
        
    end
end