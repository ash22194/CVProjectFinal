function [shaky_video,T] = generate_shaky_video_Affine(filename,varargin)

in = length(varargin);
if ~(in==0||1)
    fprintf('Check number of inputs\n');
    return;
end
if ischar(filename)
a = mmread(filename);
framerate = a.rate;
vid = zeros(a.height,a.width,a.nrFramesTotal);
T = zeros(a.nrFramesTotal,2);
else
vid = zeros(size(filename));   
end
fprintf('Generating shaky video : Affine\n');
for i=1:a.nrFramesTotal 
    b = rgb2gray(a.frames(i).cdata); 
    [H,W] = size(b);
    if i > 1, tx = round(rand(1)*3); else tx = 0; end;
    if i > 1, ty = round(rand(1)*3); else ty = 0; end;
    if i > 1,
        A = [1 0; 0 1] + rand(2,2)*0.1;
    else
        A = [1 0; 0 1];
    end;
           
    c = my_affine_warp(b,A);    
    d = c; d(:,:) = 0;
    d(ty+1:H,tx+1:W) = c(1:H-ty,1:W-tx);
    T(:,:,i) = [A(1,:),tx;A(2,:),ty;0 0 1];    
    vid(:,:,i) = d;
end
fprintf('Shaky video generated\n');
shaky_video = vid;
if in==1
 filename = varargin{1};
 writevideo(filename,vid/max(vid(:)),framerate);
end

end
    