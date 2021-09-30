imorig = imread('Test_One.jpg');
[height, width, depth] = size(imorig);
imbg = imread('Background.jpg');
[heightbg, widthbg, depthbg] = size(imbg);

figure();
imshow(imorig);
title('Original Image');

img_bgsub = imbg - imorig;
figure();
imshow(img_bgsub);
title('Subtracted');

imgray = rgb2gray(img_bgsub);
figure();
imshow(imgray);
title('Grayscale');

for(i=1 : height)
    for(j=1 : width)
        if(imgray(i, j) < 100)
            img_bgsub(i, j, :) = [0,0,0];
        end
    end
end

imbin = im2bw(img_bgsub);
figure();
imshow(imbin);
title('Binary Image');

STATS = regionprops(imbin);

figure();
imshow(imorig);
hold on;

items = size(STATS);
for i = 1:items
    plot(STATS(i).Centroid(1),STATS(i).Centroid(2),'kO','MarkerFaceColor','k');
end
title('Original Image with Centroid Dots');