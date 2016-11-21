function F = computeFpt(frame,frame2)
neighborPixels = [1,1;-1,-1;-1,1;1,-1;1,0;-1,0;0,1;0,-1];
FFlow = estimate_flow_interface(frame,frame2);
wSum = zeros(size(frame,1),size(frame,2));
F = zeros(size(frame,1),size(frame,2),2);
EPSILON = 0.001;
%% TODO, I should make sure that the pixels are not missing when computing ItPrime
for i=[1:size(neighborPixels,1)]
    % align flow at q with p
    Fq = circshift(FFlow,[-neighborPixels(i,1) -neighborPixels(i,2)]);
    F1 = Fq(:,:,1);F2 = Fq(:,:,2);
    [gradientF1x,gradientF1y] = gradient(F1);
    [gradientF2x,gradientF2y] = gradient(F2);
    Fpq1 = F1 + gradientF1x.*(-neighborPixels(i,1)) + gradientF1y.*(-neighborPixels(i,2));
    Fpq2 = F2 + gradientF2x.*(-neighborPixels(i,1)) + gradientF2y.*(-neighborPixels(i,2));
    Fpq12(:,:,1) = Fpq1;
    Fpq12(:,:,2) = Fpq2;
    Fpq = Fq + Fpq12;

    %% geometric distance
    g = 1./pdist([0,0;neighborPixels(i,1),neighborPixels(i,2)]);
    
    %% pseudosimilarity 
    [x,y] = meshgrid ([1:size(frame,2)],[1:size(frame,1)]);
    x = round(x + Fq(:,:,1));
    y = round(y + Fq(:,:,2));
    
    x(x > size(frame,2) | y > size(frame,1) | ...
        x <= 0 | y <= 0 ) = 1;
    y(x > size(frame,2) | y > size(frame,1) | ...
        x <= 0 | y <= 0 ) = 1;
    
    indices = sub2ind([size(frame,2),size(frame,1)], x , y);
    ItPrimeQPp_q = frame2(indices);
    
    [x,y] = meshgrid ([1:size(frame,2)],[1:size(frame,1)]);
    x = x + neighborPixels(i,1);
    x = round(x + Fq(:,:,1));
    y = y + neighborPixels(i,2);
    y = round(y + Fq(:,:,2));
    
    x(x > size(frame,2) | y > size(frame,1) | ...
        x <= 0 | y <= 0 ) = 1;
    y(x > size(frame,2) | y > size(frame,1) | ...
        x <= 0 | y <= 0 ) = 1;
    
    indices = sub2ind([size(frame,2),size(frame,1)], x , y);
    ItPrimeQP = frame2(indices);
    
    c = 1./( sqrt((ItPrimeQPp_q-ItPrimeQP).^2)+ EPSILON);
    w = g.*c;
    F(:,:,1) = F(:,:,1) + w.*Fpq(:,:,1);
    F(:,:,2) = F(:,:,2) + w.*Fpq(:,:,2);
    wSum = wSum + w;
end
F(:,:,1) = F(:,:,1)./wSum;
F(:,:,2) = F(:,:,2)./wSum;
end