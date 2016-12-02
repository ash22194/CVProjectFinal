%% test video
fileName_prefix = '../Inpainting/videos_';
fileName_postfix = '_inpainted.jpg';
load('videos.mat')
nfiles = length(imagefiles);    % Number of files found
startFrame = 1;
stepFrame = 10;
for ii=startFrame:nfiles
    image = imread(strcat(strcat(fileName_prefix,num2str((ii-1)*stepFrame+1)),fileName_postfix));
    subplot 121
    imshow(image)
    subplot 122
    imshow(inpaintVid(:,:,(ii-1)*stepFrame+1))
end

