%% test video

BOUNDARY = 10;
boundaryPixels = zeros(size(frame,1),size(frame,2));
boundaryPixels(1:BOUNDARY,:) = 1; boundaryPixels(:,1:BOUNDARY) = 1; 
boundaryPixels(size(boundaryPixels,1)-BOUNDARY:size(boundaryPixels,1),:) = 1; 
boundaryPixels(:,size(boundaryPixels,2)-BOUNDARY:size(boundaryPixels,2)) = 1;
maskConstant = boundaryPixels;
for lll=[1:size(frames,3)-1]    
    subplot 121
    imshow(motionInpaint(:,:,lll));
    subplot 122
    frame = frames(:,:,lll);
    newFrame = imgaussfilt(frame,1);%%wiener2(frame,[2 2],0.025);    
    frame(logical(maskConstant)) = newFrame(logical(maskConstant));
    imshow((frame))
    pause(0.1) 
end

