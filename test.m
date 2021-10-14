clear all;
clc;

imorig = imread('test3_6.jpg');
[height, width, depth] = size(imorig);
imbg = imread('background_3.jpg');
[heightbg, widthbg, depthbg] = size(imbg);

figure();
imshow(imorig);
title('Original Image');

img_bgsub = imbg - imorig;
%figure();
% imshow(img_bgsub);
% title('Subtracted-before');
% 
% %Filtering by percent difference to brighten colors getting lost to
% %background
% for(i=1: heightbg)
%     for(j=1: widthbg)
%         RGB = [imorig(i,j,1), imorig(i,j,2), imorig(i,j,3)];
%         [max_val, index] = max(RGB);
%         if(max_val == 0)
%             break
%         end
%         %Get percent difference
%         percent_diff = [0,0];
%         l = 1;
%         for(k=1: 3)
%             if(k ~= index)
%                 percent_diff(l) = double((double(max_val) - double(RGB(k)))/double(max_val));
%                 l = l + 1;
%             end
%         end
%         if(max(percent_diff) > .45)
%             img_bgsub(i, j, :) = [255,255,255];
%         end
%     end
% end

figure();
imshow(img_bgsub);
title('Subtracted-after');

imgray = rgb2gray(img_bgsub);

for(i=1: heightbg)
    for(j=1: widthbg)
        if(imgray(i, j) > 210)
            break
        end
        RGB = [imorig(i,j,1), imorig(i,j,2), imorig(i,j,3)];
        [max_val, index] = max(RGB);
        if(max_val == 0)
            break
        end
        %Get percent difference
        percent_diff = [0,0];
        l = 1;
        for(k=1: 3)
            if(k ~= index)
                percent_diff(l) = double((double(max_val) - double(RGB(k)))/double(max_val));
                l = l + 1;
            end
        end
        if(max(percent_diff) > .45)
            imgray(i, j) = 255;
        end
    end
end

figure();
imshow(imgray);
title('Grayscale');

imbin = im2bw(imgray);
figure();
imshow(imbin);
title('Binary Image');

%Erode image
SE = strel('disk', 3);

Image_Erode = imerode(imbin, SE);
figure();
imshow(Image_Erode);
title('Binary Image Erosion');

STATS = regionprops(Image_Erode, 'Area', 'Centroid', 'BoundingBox', 'Eccentricity', 'Circularity');

figure();
imshow(imorig);
hold on;

items = size(STATS);
for i = 1:items
    plot(STATS(i).Centroid(1),STATS(i).Centroid(2),'kO','MarkerFaceColor','k');
end
title('Original Image with Centroid Dots');

for i=1:items
    coords = [int16(STATS(i).Centroid(2)), int16(STATS(i).Centroid(1))];
    RGB_Cent = [imorig(coords(1), coords(2), 1), imorig(coords(1), coords(2), 2), imorig(coords(1), coords(2), 3)];
    [max_val, index] = max(RGB_Cent);
    if(STATS(i).Circularity >= .9)
        shape = "Circle";
    elseif(STATS(i).Circularity >= .7)
        shape = "Square";
    else
        shape = "Triangle";
    end
    if(RGB_Cent(1) > 200 && RGB_Cent(2) > 200)
        fprintf("Yellow %s found at [%i, %i]\n", shape, coords(2), coords(1));
    elseif(index == 1)
        fprintf("Red %s found at [%i, %i]\n", shape, coords(2), coords(1));
    elseif(index == 2)
        fprintf("Dark Green %s found at [%i, %i]\n", shape, coords(2), coords(1));
    elseif(index == 3)
        fprintf("Blue %s found at [%i, %i]\n", shape, coords(2), coords(1));
    else
        fprintf("Unkown color %s found at [%i, %i]\n", shape, coords(2), coords(1));
    end
end