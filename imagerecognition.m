
clc; 
clear; 
close all;

[filename, pathname] = uigetfile({'*.jpg;*.png;*.jpeg'}, 'Select an Image');
if isequal(filename,0)
    disp('No image selected.');
    return;
end

img = imread(fullfile(pathname, filename));
figure, imshow(img), title('Original Image');


img = im2double(img);


resizeFactor = input('Enter resize percentage (e.g. 50 for 50%): ');
if isempty(resizeFactor), resizeFactor = 100; end
resizedImg = imresize(img, resizeFactor/100);


brightnessFactor = input('Enter brightness factor (1 = normal): ');
if isempty(brightnessFactor), brightnessFactor = 1; end
contrastFactor = input('Enter contrast factor (1 = normal): ');
if isempty(contrastFactor), contrastFactor = 1; end


meanVal = mean(resizedImg(:));
enhancedImg = (resizedImg - meanVal) * contrastFactor + meanVal; 
enhancedImg = enhancedImg * brightnessFactor;
enhancedImg = min(max(enhancedImg, 0), 1); 

figure, imshow(enhancedImg), title('Brightness & Contrast Adjusted');


disp('Available Filters:');
disp('1. None');
disp('2. Grayscale');
disp('3. Sepia');
disp('4. Invert');
disp('5. Blur');
disp('6. Sharpen');
filterChoice = input('Select filter (1-6): ');

switch filterChoice
    case 2 
        filteredImg = mean(enhancedImg, 3);
    case 3 
        sepiaMatrix = [0.272 0.534 0.131; 0.349 0.686 0.168; 0.393 0.769 0.189];
        filteredImg = zeros(size(enhancedImg));
        for i = 1:size(enhancedImg,1)
            for j = 1:size(enhancedImg,2)
                filteredImg(i,j,:) = sepiaMatrix * squeeze(enhancedImg(i,j,:));
            end
        end
        filteredImg = min(filteredImg,1);
    case 4 
        filteredImg = 1 - enhancedImg;
    case 5 
        kernel = ones(3,3)/9;
        filteredImg = zeros(size(enhancedImg));
        for c = 1:size(enhancedImg,3)
            filteredImg(:,:,c) = conv2(enhancedImg(:,:,c), kernel, 'same');
        end
    case 6 % Sharpen (unsharp mask style)
        kernel = [-1 -1 -1; -1 9 -1; -1 -1 -1];
        filteredImg = zeros(size(enhancedImg));
        for c = 1:size(enhancedImg,3)
            filteredImg(:,:,c) = conv2(enhancedImg(:,:,c), kernel, 'same');
        end
        filteredImg = min(max(filteredImg,0),1);
    otherwise
        filteredImg = enhancedImg;
end

figure, imshow(filteredImg), title('Processed Image');


quality = input('Enter JPEG quality (1-100): ');
if isempty(quality), quality = 90; end
outputFile = fullfile(pathname, 'processed_image.jpg');
imwrite(filteredImg, outputFile, 'jpg', 'Quality', quality);
fprintf('Processed image saved at: %s\n', outputFile);
