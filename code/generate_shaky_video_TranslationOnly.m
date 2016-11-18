function [shaky_video,T] = generate_shaky_video_TranslationOnly(filename,varargin)

in = length(varargin);
if ~(in==0||1)
    fprintf('Check number of inputs\n');
    return;
end
if ischar(filename)
    a = mmread(filename);
    framerate = a.rate;
    vid = zeros(a.height,a.width,a.nrFramesTotal);
    T = zeros(3,3,a.nrFramesTotal);
    fprintf('Generating shaky video : Translation only\n');
for i=1:a.nrFramesTotal 
    b = rgb2gray(a.frames(i).cdata); 
    [H,W] = size(b);
    if i > 1, tx = round(rand(1)*8); else tx = 0; end;
    if i > 1, ty = round(rand(1)*8); else ty = 0; end;

    d = b; d(:,:) = 0;
    d(ty+1:H,tx+1:W) = b(1:H-ty,1:W-tx);
    T(:,:,i) = eye(3);
    T(1,3,i) = tx;
    T(2,3,i) = ty;
    vid(:,:,i) = d;
end
else
    vid = zeros(size(filename));
    T = zeros(3,3,size(filename,3));
    fprintf('Generating shaky video : Translation only\n');
for i=1:size(filename,3) 
    b = (filename(:,:,i)); 
    [H,W] = size(b);
    if i > 1, tx = round(rand(1)*8); else tx = 0; end;
    if i > 1, ty = round(rand(1)*8); else ty = 0; end;

    d = b; d(:,:) = 0;
    d(ty+1:H,tx+1:W) = b(1:H-ty,1:W-tx);
    T(:,:,i) = eye(3);
    T(1,3,i) = tx;
    T(2,3,i) = ty;
    vid(:,:,i) = d;
end
end
fprintf('Shaky video generated\n');
shaky_video = vid;
if in==1
 filename = varargin{1};
 writevideo(filename,vid/max(vid(:)),framerate);
end
end



    