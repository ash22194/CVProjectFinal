clear;
close all hidden;
motion = 3;
% filename = '../data/aerialseq.avi';
load('../data/sylvseq.mat');
filename = frames;
 iter = 3;
if motion==1
    [shaky_vid,T_shaky] = generate_shaky_video_TranslationOnly(filename);
end
if motion==2
    [shaky_vid,T_shaky] = generate_shaky_video_Rigid(filename);
end
if motion==3
    [shaky_vid,T_shaky] = generate_shaky_video_Affine(filename);
end

shaky_vid_ = cell(1,iter+1);
shaky_vid_{1,1} = uint8(shaky_vid);
neighbourhood = [6,3,2];
for i = 1:1:iter
[smooth_vid,T_sm,T_sh] = globalMotionsmoothAffineFlow(shaky_vid_{1,i},neighbourhood(i));
shaky_vid_{1,i+1} = smooth_vid;
end
shaky_vid = uint8(shaky_vid);
% T = estimateShaky(filename,shaky_vid);
