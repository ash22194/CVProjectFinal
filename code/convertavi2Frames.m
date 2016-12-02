function y = convertavi2Frames(filename)
a = mmread(filename);
vid = zeros(a.height,a.width,a.nrFramesTotal);
    for i=1:a.nrFramesTotal 
        vid(:,:,i) = rgb2gray(a.frames(i).cdata);
    end
y = vid;
end