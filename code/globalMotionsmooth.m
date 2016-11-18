function [frames_smooth,T_sm,T_sh] = globalMotionsmooth(frames,neighbourhood,varargin)

sigma = neighbourhood;
if length(varargin) > 1
    fprintf('Check number of arguments!\n');
    return;
end
if length(varargin)==1
    sigma = varargin{1};
end
x = [-neighbourhood:1:-1,1:1:neighbourhood];
g = exp(-x.^2/sigma^2)/(sigma*sqrt(2*pi));
g = g/sum(g);
T_sm = zeros(3,3,size(frames,3));
T_sh = zeros(3,3,size(frames,3)-1);
[m,n,n_fr] = size(frames);
frames_smooth = uint8(zeros(m,n,n_fr));
fprintf('Computing local tranforms\n');
    for i = 1:1:neighbourhood
        neighbours = x((x+i)>0);
        g_ = g((x+i)>0); 
        g_ = g_/sum(g_);
        T = zeros(3,3);
        for j = 1:1:length(neighbours)
           M = LucasKanadeAffine(frames(:,:,i),frames(:,:,i+neighbours(j)));
           if j==1
              T_sh(:,:,i) = M;
           end
           T = T + g_(j)*M;
        end
        T_sm(:,:,i) = T;
        frames_smooth(:,:,i) = warpH(frames(:,:,i),T,[m,n]);
        i
    end
    for i = neighbourhood+1:1:n_fr-neighbourhood
        neighbours = (x+i);
        T = zeros(3,3);
        for j = 1:1:length(neighbours)
            M = LucasKanadeAffine(frames(:,:,i),frames(:,:,neighbours(j)));
            if j==1
              T_sh(:,:,i) = M;
            end
            T = T + M*g(j);
        end
        T_sm(:,:,i) = T;
        frames_smooth(:,:,i) = warpH(frames(:,:,i),T,[m,n]);
        i
    end
    for i = n_fr-neighbourhood+1:1:n_fr
        neighbours = x((x+i)<n_fr);
        g_ = g((x+i)<n_fr); 
        g_ = g_/sum(g_);
        T = zeros(3,3);
        for j = 1:1:length(neighbours)
           M = LucasKanadeAffine(frames(:,:,i),frames(:,:,i+neighbours(j)));
           if j==1
              T_sh(:,:,i) = M;
           end
           T = T + g_(j)*M;
        end
        T_sm(:,:,i) = T;
        frames_smooth(:,:,i) = warpH(frames(:,:,i),T,[m,n]);
        i
    end
    fprintf('Smoothing complete\n');
end