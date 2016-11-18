clear;
close all hidden;
motion = 2;
filename = '../data/aerialseq.avi';
if motion==1
    [shaky_vid,T_shaky] = generate_shaky_video_TranslationOnly(filename);
end
if motion==2
    [shaky_vid,T_shaky] = generate_shaky_video_Rigid(filename);
end
if motion==3
    [shaky_vid,T_shaky] = generate_shaky_video_Affine(filename);
end

neighbourhood = 6;
[smooth_vid,T_sm,T_sh] = globalMotionsmooth(shaky_vid,neighbourhood);
shaky_vid = uint8(shaky_vid);

T = estimateShaky(filename,shaky_vid);
