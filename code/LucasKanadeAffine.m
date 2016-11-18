function M = LucasKanadeAffine(It, It1)

% input - image at time t, image at t+1 
% output - M affine transformation matrix
[m,n,~]=size(It1);
x = 1:1:n;
y = 1:1:m;
[X,Y] = meshgrid(x,y);
X = X(:);
Y = Y(:);
locs = [X,Y,ones(m*n,1)];
M = diag(ones(3,1));
delta_M = ones(3,3);
tol = 10^-4;
[Ix,Iy] = gradient(double(It));
Ix_ = Ix(:);
Iy_ = Iy(:);
Ixx_ = Ix_.*locs(:,1); 
Ixy_ = Ix_.*locs(:,2);
Iyx_ = Iy_.*locs(:,1);
Iyy_ = Iy_.*locs(:,2);

IterMax = 10;
i=0;
while (norm(delta_M) > tol & i<IterMax)
    i = i+1;
    locs_warped = (M*locs')';
    mask = not(locs_warped(:,1)>n | locs_warped(:,1)<1 | locs_warped(:,2)>m | locs_warped(:,2)<1);
    t = [Ixx_(mask,1),Iyx_(mask,1),Ixy_(mask,1),Iyy_(mask,1),Ix_(mask,1),Iy_(mask,1)];
    H = t'*t;
    c = t'*(interp2(double(It1),locs_warped(mask,1),locs_warped(mask,2)) - interp2(double(It),locs(mask,1),locs(mask,2)));
    delta_M = H\c;
    delta = [reshape(delta_M,2,3);0 0 1];
    delta(1,1) = delta(1,1) + 1;
    delta(2,2) = delta(2,2) + 1;
    M = M*(delta)^(-1);

end

end