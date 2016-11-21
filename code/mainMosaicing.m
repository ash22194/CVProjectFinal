% Local Motion estimation

% load('../results/Translation_8.mat')
THRESHOLD = 0.05;
addpath(genpath('optical_flow'));
load('matlab.mat')
smoothedFrames = im2double(smooth_vid);
shakyFrames = im2double(shaky_vid);
frames = smoothedFrames;
[sizeX,sizeY,n_fr] = size(shakyFrames);
neighbourhood = 6;
neighbors = [-neighbourhood:1:neighbourhood];
figure
%% mosaicing with consistency constraints
for t=[1:size(frames,3)-1]
    TNeighbors = zeros(3,3,size(neighbors,2));
    medianFrame = zeros(size(frames,1),size(frames,2),size(frames,3),size(neighbors,2));
    meanFrame = zeros(size(frames));
    varFrame = zeros(size(frames));
    count = 0;    
    startN = 0;
    endN = 0;
    for n = neighbors
        if (t+n > 0 && t+n < size(frames,3)+1)
            T = LucasKanadeAffine(frames(:,:,t),frames(:,:,t+n));
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
            
            T = LucasKanadeAffine(frames(:,:,t),frames(:,:,t+n));
            frame = im2double(warpH(frames(:,:,t+n),T,[sizeX,sizeY]));
            varFrame(:,:,t) = varFrame(:,:,t) + (frame - meanFrame(:,:,t)).^2;
            count = count + 1;
%             uvo = estimate_flow_interface(shakyFrames(:,:,t), frames_sh(:,:,tPrime));
        end        
    end
    medianFrameAll = median(medianFrame(:,:,t,startN:endN),4);
    varFrame(:,:,t) = varFrame(:,:,t)/(count - 1);
    indices = varFrame(:,:,t) < THRESHOLD & frames(:,:,t) == 0;   
    
    subplot 121
    imshow(frames(:,:,t))
    temp = frames(:,:,t);
    temp(indices) = medianFrameAll(indices);
    frames(:,:,t) = temp(:,:,1);
    subplot 122
    imshow(frames(:,:,t))
    t
end
