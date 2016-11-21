% Local Motion estimation

% load('../results/Translation_8.mat')
THRESHOLD = 0.1;
addpath(genpath('optical_flow'));
load('matlab.mat') %% this file has output of global motion part
smoothedFrames = im2double(smooth_vid);
shakyFrames = im2double(shaky_vid);
frames = smoothedFrames;
[sizeX,sizeY,n_fr] = size(shakyFrames);
neighbourhood = 6;
neighbors = [-neighbourhood:1:neighbourhood];
figure

%% motion inpainting
for t=[1:size(frames,3)-1]
    error = [];
    frame = [];
    sortedNeighbors = [];
    count = 1;
    %% compute error and pick the neighor with min error
    for n = neighbors
        if (t+n > 0 && t+n < size(frames,3)+1)
            T = LucasKanadeAffine(frames(:,:,t),frames(:,:,t+n));
            frame(:,:,t+n) = im2double(warpH(frames(:,:,t+n),T,[sizeX,sizeY]));
            error(count) = sum(sum(abs(frames(:,:,t)-frame(:,:,t+n))));   
            sortedNeighbors(count) = t+n;
            count = count + 1;
        end        
    end
    [minE,minIndex] = sort(error(error ~= 0));
    minIndex = minIndex + sum(error == 0);
   
% for j=minIndex
    F = computeFpt(frames(:,:,t),frames(:,:,sortedNeighbors(minIndex(1))));
    nextFrame = frames(:,:,sortedNeighbors(minIndex(1)));
    
    [x,y] = meshgrid ([1:size(frames(:,:,t),2)],[1:size(frames(:,:,t),1)]);    
    x = round(x + F(:,:,1)); % fix this
    y = round(y + F(:,:,2));
    
    x(x > size(frame,2) | y > size(frame,1) | ...
        x <= 0 | y <= 0 ) = 1;
    y(x > size(frame,2) | y > size(frame,1) | ...
        x <= 0 | y <= 0 ) = 1;
    
    indices = sub2ind([size(frame,2),size(frame,1)], x , y);
    nextFrame = nextFrame(indices);    
    newFrame = frames(:,:,t);
    newFrame(frames(:,:,t) == 0 & x ~= 1 & y~= 1) = nextFrame(frames(:,:,t) == 0 & x ~= 1 & y~= 1);
    
    subplot 121
    imshow(frames(:,:,t))
    subplot 122
    imshow(newFrame)
end