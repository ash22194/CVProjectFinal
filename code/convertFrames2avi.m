function convertFrames2avi(frames,filename)

for i=1:1:size(frames,3)
    F(i) = im2frame(frames(:,:,i),gray(256));
end
movie2avi(F,filename);
end