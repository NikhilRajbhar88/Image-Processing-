function backgroundChanger()
    % Let user choose the main image
    [file, path] = uigetfile({'*.jpg;*.png;*.jpeg'}, 'Select an Image');
    if isequal(file,0)
        disp('User cancelled');
        return;
    end

    img = imread(fullfile(path, file));
    figure('Name','Original Image');
    imshow(img);
    title('Original Image');

    % Convert to double precision for calculations
    imgd = double(img)/255;

    % Basic background estimation (mean intensity)
    gray = (imgd(:,:,1) + imgd(:,:,2) + imgd(:,:,3)) / 3;

    % Create a rough foreground mask
    threshold = mean(gray(:));
    mask = gray < threshold * 0.9 | gray > threshold * 1.1;

    % Basic smoothing without medfilt2 — manual neighborhood average
    smoothMask = zeros(size(mask));
    pad = 2; % 5x5 window equivalent
    for i = 1+pad : size(mask,1)-pad
        for j = 1+pad : size(mask,2)-pad
            window = mask(i-pad:i+pad, j-pad:j+pad);
            smoothMask(i,j) = mean(window(:)) > 0.5;
        end
    end
    mask = logical(smoothMask);

    figure('Name','Foreground Mask');
    imshow(mask);
    title('Estimated Foreground Mask');

    % Ask user to choose a new background
    [bgfile, bgpath] = uigetfile({'*.jpg;*.png;*.jpeg'}, 'Select New Background');
    if isequal(bgfile,0)
        disp('User cancelled background selection');
        return;
    end

    bg = imread(fullfile(bgpath, bgfile));
    bg = imresize(bg, [size(img,1), size(img,2)]);

    % Combine images: if mask pixel = 1 → keep original, else background
    result = uint8(zeros(size(img)));
    for c = 1:3
        result(:,:,c) = uint8(imgd(:,:,c) .* mask + double(bg(:,:,c))/255 .* (~mask)) * 255;
    end

    figure('Name','Final Image');
    imshow(result);
    title('Image with New Background');
end
