function T = estimateShaky(filename,shaky_vid)

a = mmread(filename);
T = zeros(3,3,a.nrFramesTotal);

for i=1:1:a.nrFramesTotal
    T(:,:,i) = LucasKanadeAffine(rgb2gray(a.frames(i).cdata),shaky_vid(:,:,i));
end

end