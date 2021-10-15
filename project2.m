clear all;
close all;
clc;
clear('cam')

%%
%Setting up webcam%
cam_list = webcamlist;
cam_name = cam_list{2};
cam = webcam(cam_name);

%%
%Gathering inital data needed%
imbg = imread('background_4.jpg');
[heightbg, widthbg, depthbg] = size(imbg);

Gamestate.bg_img = imbg;

imorig = snapshot(cam);
[height, width, depth] = size(imorig);
figure();
imshow(imorig);
title('Current Image');
%%
%Background Subtraction%
Gamestate.curr_img = imorig;
img_bgsub = imbg - imorig;
figure();
imshow(img_bgsub);
title('Background Subtraction');

Gamestate.bg_sub = img_bgsub;
%%
%Getting grayscale image%
imgray = rgb2gray(img_bgsub);
figure();
imshow(imgray);
title('Grayscale: Before Correction');

%Correcting grayscale image
%Issue comes from yellow shapes, background subtraction causes their color
%to change to a dark blue. This dark blue will then be treated as part of
%the background. To help with this, we will find any blue pixels and
%convert their grayscale counter part to white.
for(i=1 : height)
    for(j=1 : width)
        if(img_bgsub(i, j, 1) < 50 && img_bgsub(i, j, 2) < 50 && img_bgsub(i, j, 3) > 50)
            imgray(i, j) = 255;
        end
    end
end

figure();
imshow(imgray);
title('Grayscale: After Correction');

%%
%Getting binary image%
imbin = im2bw(imgray);
figure();
imshow(imbin);
title('Binary Image');

%Erode image
SE = strel('disk', 2);

Image_Erode = imerode(imbin, SE);
figure();
imshow(Image_Erode);
title('Binary Image Erosion');

Gamestate.detected_objects = Image_Erode;
%%
%Getting image stats and plotting the findings%
STATS = regionprops(Image_Erode, 'Area', 'Centroid', 'BoundingBox', 'Eccentricity', 'Circularity');

figure();
imshow(imorig);
hold on;
title('Original Image with Centroid Dots');

items = size(STATS);

for i=1:items
    coords = [int16(STATS(i).Centroid(2)), int16(STATS(i).Centroid(1))];
    RGB_Cent = [imorig(coords(1), coords(2), 1), imorig(coords(1), coords(2), 2), imorig(coords(1), coords(2), 3)];
    [max_val, index] = max(RGB_Cent);
    %Based off of empirical data, these values of circularity are
    %consistently correct
    if(STATS(i).Circularity >= .9)
        shape = "Circle";
        marker = "o";
    elseif(STATS(i).Circularity >= .71)
        shape = "Square";
        marker = "s";
    else
        shape = "Triangle";
        marker = "^";
    end
    %First we check for yellow as its R and G channel will both be high,
    %then we can simply check to see where the max value is in the RGB to
    %determine if it is Red, Dark Green, or Blue
    if(RGB_Cent(1) > 150 && RGB_Cent(2) > 150)
        string_build = sprintf("  ID:  %d\n  Color: Yellow\n  Shape: %s\n  Coords: [%i, %i]", i, shape, coords(2), coords(1));
        plot(STATS(i).Centroid(1),STATS(i).Centroid(2),"y"+marker,'MarkerFaceColor','k');
    elseif(index == 1)
        string_build = sprintf("  ID:  %d\n  Color: Red\n  Shape: %s\n  Coords: [%i, %i]", i, shape, coords(2), coords(1));
        plot(STATS(i).Centroid(1),STATS(i).Centroid(2),"r"+marker,'MarkerFaceColor','k');
    elseif(index == 2)
        string_build = sprintf("  ID:  %d\n  Color: Dark Green\n  Shape: %s\n  Coords: [%i, %i]", i, shape, coords(2), coords(1));
        plot(STATS(i).Centroid(1),STATS(i).Centroid(2),"g"+marker,'MarkerFaceColor','k');
    elseif(index == 3)
        string_build = sprintf("  ID:  %d\n  Color: Blue\n  Shape: %s\n  Coords: [%i, %i]", i, shape, coords(2), coords(1));
        plot(STATS(i).Centroid(1),STATS(i).Centroid(2),"b"+marker,'MarkerFaceColor','k');
    else
        string_build = sprintf("  ID:  %d\n  Color: Unkown\n  Shape: %s\n  Coords: [%i, %i]", i, shape, coords(2), coords(1));
        plot(STATS(i).Centroid(1),STATS(i).Centroid(2),'k*','MarkerFaceColor','k');
    end

    text(STATS(i).Centroid(1),STATS(i).Centroid(2), string_build, 'FontSize', 10);
end