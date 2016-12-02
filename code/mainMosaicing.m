% Local Motion estimation

% load('../results/Translation_8.mat')
EPSILON = 0.3;
THRESHOLD = 0.1;
BOUNDARY = 30;
addpath(genpath('Inpaint_nans (1)'));
addpath(genpath('inpainting_criminisi2004'));

addpath(genpath('inpaintn'));
addpath(genpath('optical_flow'));
addpath(genpath('affine_flow'));
% load('matlab.mat') 
load('../smooth_data/aerialseq.mat') %% this file has output of global motion part cars_affine_632
% smoothedFrames = im2double(smooth_vid);
% shakyFrames = im2double(shaky_vid);
frames = im2double(shaky_vid_{4});
[sizeX,sizeY,n_fr] = size(shaky_vid_{4});
neighbourhood = 6;
neighbors = [-neighbourhood:1:neighbourhood];
figure
mosaicVid = [];
inpaintVid = [];
%% mosaicing with consistency constraints
STEP = 10;

for t=[1:STEP:size(frames,3)-1]
    TNeighbors = zeros(3,3,size(neighbors,2));
    medianFrame = zeros(size(frames,1),size(frames,2),size(frames,3),size(neighbors,2));
    meanFrame = zeros(size(frames));
    varFrame = zeros(size(frames));
    count = 0;    
    startN = 0;
    endN = 0;
    for n = neighbors
        if (t+n > 0 && t+n < size(frames,3)+1)
            
%             T = LucasKanadeAffine(frames(:,:,t),frames(:,:,t+n));
            T_flow = affine_flow('image1',frames(:,:,t),'image2',frames(:,:,t+n), ...
            'sigmaXY',4,'sampleStep',8);
            T_flow_s = T_flow.findFlow;
            T_w = affine_flow.warp(T_flow_s.flowStruct);
            T_www = maketform('affine',T_w);
            T = (T_www.tdata.T)';            
            
            frame = im2double(warpH(frames(:,:,t+n),T,[sizeX,sizeY]));
            meanFrame(:,:,t) = meanFrame(:,:,t) + frame;
            medianFrame(:,:,t,n+neighbourhood+1) = frame;
            count = count + 1;
            if startN == 0
                startN = n+neighbourhood+1;
            end
            endN = n+neighbourhood+1;
        end
    end
    meanFrame(:,:,t) = meanFrame(:,:,t)/count;
    count = 0;
    for n = neighbors
        if (t+n > 0 && t+n < size(frames,3)+1)
            
            T_flow = affine_flow('image1',frames(:,:,t),'image2',frames(:,:,t+n), ...
            'sigmaXY',4,'sampleStep',8);
            T_flow_s = T_flow.findFlow;
            T_w = affine_flow.warp(T_flow_s.flowStruct);
            T_www = maketform('affine',T_w);
            T = (T_www.tdata.T)';   
            
%             T = LucasKanadeAffine(frames(:,:,t),frames(:,:,t+n));
                      
            frame = im2double(warpH(frames(:,:,t+n),T,[sizeX,sizeY]));
            varFrame(:,:,t) = varFrame(:,:,t) + (frame - meanFrame(:,:,t)).^2;
            count = count + 1;
%             uvo = estimate_flow_interface(shakyFrames(:,:,t), frames_sh(:,:,tPrime));
        end        
    end
    medianFrameAll = median(medianFrame(:,:,t,startN:endN),4);
    varFrame(:,:,t) = varFrame(:,:,t)/(count - 1);
    indices = varFrame(:,:,t) < THRESHOLD & frames(:,:,t) == 0;   
    
%     tempF = frames(:,:,t);
    
    subplot 121
    imshow(frames(:,:,t))
    temp = frames(:,:,t);
    temp(indices) = medianFrameAll(indices);
    frames(:,:,t) = temp(:,:,1);
    subplot 122
    imshow(frames(:,:,t))
    
    mosaicVid(:,:,t) = frames(:,:,t);
    
    tempF = mosaicVid(:,:,t);
    tempImage = zeros(size(tempF,1),size(tempF,2));
    boundaryPixels = zeros(size(tempF,1),size(tempF,2));
    boundaryPixels(1:BOUNDARY,:) = 1; boundaryPixels(:,1:BOUNDARY) = 1; 
    boundaryPixels(size(boundaryPixels,1)-BOUNDARY:size(boundaryPixels,1),:) = 1; 
    boundaryPixels(:,size(boundaryPixels,2)-BOUNDARY:size(boundaryPixels,2)) = 1;
    tempImage(tempF < EPSILON & boundaryPixels) = 1;
    
    
    
    
%     tempF(tempF < EPSILON & boundaryPixels) = NaN;
    
%     ffffff=inpaintn(tempF);
    
%     ffffff=inpaint_nans(tempF*255,3);

    [ffffff,C,D,fillMovie] = inpainting(repmat(tempF,1,1,3),tempImage,29);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     close all
    subplot 121
    imshow(frames(:,:,t))
    subplot 122
    imshow((im2double(ffffff)))
%     imshow(uint8(im2double(ffffff)))
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    inpaintVid(:,:,t) = im2double(ffffff(:,:,1));
    t    
end

for t=[1:size(inpaintVid,3)]
    imshow(im2double(inpaintVid(:,:,t)))
    pause(1) 
end

for t=[1:size(mosaicVid,3)]
    imshow(mosaicVid(:,:,t))
end

% T_flow = affine_flow('image1',frames(:,:,t),'image2',frames(:,:,t+n), ...
%             'sigmaXY',4,'sampleStep',8);
%             T_flow_s = T_flow.findFlow;
%             T_w = affine_flow.warp(T_flow_s.flowStruct);
%             T_www = maketform('affine',T_w);
%             T = T_www.tdata.T;