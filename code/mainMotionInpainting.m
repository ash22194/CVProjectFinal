% Local Motion estimation

% load('../results/Translation_8.mat')
THRESHOLD = 0.1;
EPSILON = 0.3;
BOUNDARY = 30;
neighbourhood = 6;
numOfPasses = 5;

addpath(genpath('optical_flow'));
addpath(genpath('affine_flow'));
addpath(genpath('inpainting_criminisi2004'));

load('../smooth_data/aerialseq.mat') %% this file has output of global motion part
% smoothedFrames = im2double(smooth_vid);
% shakyFrames = im2double(shaky_vid);
load('videos.mat')
frames = im2double(mosaicVid); %% inpaintVid
[sizeX,sizeY,n_fr] = size(frames);

neighbors = [-neighbourhood:1:neighbourhood];
figure

for lll=[1:17]
    imshow(frames(:,:,lll));
    pause(4.0)  
end
%% motion inpainting
mask = []; 
motionInpaint = [];
% for m = [1:numOfPasses]
for t=[1:size(frames,3)-1]
for k = [1:numOfPasses]
        error = [];
        frame = [];
        sortedNeighbors = [];
        count = 1;
        %% compute error and pick the neighor with min error
        for n = neighbors
            if (t+n > 0 && t+n < size(frames,3)+1)

                T_flow = affine_flow('image1',frames(:,:,t),'image2',frames(:,:,t+n), ...
                'sigmaXY',4,'sampleStep',8);
                T_flow_s = T_flow.findFlow;
                T_w = affine_flow.warp(T_flow_s.flowStruct);
                T_www = maketform('affine',T_w);
                T = (T_www.tdata.T)';              

                frame(:,:,t+n) = im2double(warpH(frames(:,:,t+n),T,[sizeX,sizeY]));
                error(count) = sum(sum(abs(frames(:,:,t)-frame(:,:,t+n))));   
                sortedNeighbors(count) = t+n;
                count = count + 1;
            end        
        end
        [minE,minIndex] = sort(error(error ~= 0));
        minIndex = minIndex + sum(error == 0);

    for j=[1:size(minIndex,1)]
        minnI = minIndex(j);
        F = computeFpt(frames(:,:,t),frames(:,:,sortedNeighbors(minnI)));
        nextFrame = frames(:,:,sortedNeighbors(minnI));

        [x,y] = meshgrid ([1:size(frames(:,:,t),2)],[1:size(frames(:,:,t),1)]);    
        x = sign(x + F(:,:,1)).*min(abs(ceil(x + F(:,:,1))),abs(floor(x + F(:,:,1)))); 
        y = sign(y + F(:,:,2)).*min(abs(ceil(y + F(:,:,2))),abs(floor(y + F(:,:,2))));
%         x = round(x + F(:,:,1)); 
%         y = round(y + F(:,:,2));

        x(x > size(frame,2) | y > size(frame,1) | ...
            x <= 0 | y <= 0 ) = 1;
        y(x > size(frame,2) | y > size(frame,1) | ...
            x <= 0 | y <= 0 ) = 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        boundaryPixels = zeros(size(frame,1),size(frame,2));
        boundaryPixels(1:BOUNDARY,:) = 1; boundaryPixels(:,1:BOUNDARY) = 1; 
        boundaryPixels(size(boundaryPixels,1)-BOUNDARY:size(boundaryPixels,1),:) = 1; 
        boundaryPixels(:,size(boundaryPixels,2)-BOUNDARY:size(boundaryPixels,2)) = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        indices = sub2ind([size(frame,1),size(frame,2)], y,x);
        nextFrameI = nextFrame(indices);    
        newFrame = frames(:,:,t);
        
        if isempty(mask) || size(mask,3) == t-1
            mask(:,:,t) = frames(:,:,t) < EPSILON  & boundaryPixels;
        end
        newFrame(frames(:,:,t) < EPSILON  & boundaryPixels & x ~= 1 & y~= 1) = nextFrameI(frames(:,:,t)  < EPSILON & boundaryPixels & x ~= 1 & y~= 1);

        subplot 121
        imshow((frames(:,:,t)))
        subplot 122
        imshow((newFrame))
        frames(:,:,t) = newFrame;
    end
end  
    %%%%%%%%%%% apply inpainting (intensity)
    
    % compute mask
    motionInpaint(:,:,t) = frames(:,:,t);
    maskIntensity = zeros(size(motionInpaint(:,:,t),1),size(motionInpaint(:,:,t),2));
    boundaryPixels = zeros(size(motionInpaint(:,:,t),1),size(motionInpaint(:,:,t),2));
    boundaryPixels(1:BOUNDARY,:) = 1; boundaryPixels(:,1:BOUNDARY) = 1; 
    boundaryPixels(size(boundaryPixels,1)-BOUNDARY:size(boundaryPixels,1),:) = 1; 
    boundaryPixels(:,size(boundaryPixels,2)-BOUNDARY:size(boundaryPixels,2)) = 1;
    maskIntensity(motionInpaint(:,:,t) < EPSILON & boundaryPixels) = 1;

    [intensityInpaint,C,D,fillMovie] = inpainting(repmat(motionInpaint(:,:,t),1,1,3),maskIntensity,29);    
    
    subplot 121
    imshow((frames(:,:,t)))
    subplot 122
    imshow((intensityInpaint))
    frames(:,:,t) = intensityInpaint(:,:,1);
    t
    if t == 30
        disp('30')
    end
end
save('inpaintedFrames_50Passes_18Frames.mat','frames','mask','motionInpaint'); %% strcat(strcat('inpaintedFrames_',num2str(m)),'.mat')
% end