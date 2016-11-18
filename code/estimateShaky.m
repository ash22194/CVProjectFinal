function T = estimateShaky(filename,shaky_vid)

if ischar(filename)
a = mmread(filename);
T = zeros(3,3,a.nrFramesTotal);
for i=1:1:a.nrFramesTotal
    T(:,:,i) = LucasKanadeAffine(rgb2gray(a.frames(i).cdata),shaky_vid(:,:,i));
end
else
    T = zeros(3,3,size(filename,3));
    for i=1:1:size(filename,3);
    T(:,:,i) = LucasKanadeAffine(filename(:,:,i),shaky_vid(:,:,i));
    end
end


end