% read in image
img = imread('diamonds2.png');
[M, N, ~] = size(img);

% determine scale factor to scale to 256x256 image
num_bytes = 256*256;
scale_factor = sqrt(num_bytes) / max(M, N);

% downsample each channel separately, then vectorize
img_scaled = imresize(img, scale_factor);
img_scaled = reshape(img_scaled, [numel(img_scaled) 1]);
img_scaled = imresize(img_scaled, [num_bytes 1]);

% discretize range to fit in QR code
qr_max_bytes = 2953; % 177x177 grid with minimum error correction level

% each RGB pixel captures the range


% make my own QR code output with squares
qr_code = 255*ones([256 256 3]);

% step 1: box outline - width 4
qr_code(1:4,:,:) = 0;
qr_code(:,1:4,:) = 0;
qr_code(end-4:end,:,:) = 0;
qr_code(:,end-4:end,:) = 0;

% step 2: orientation box - 32x32 box
% outline - black
qr_code(5:36,5:36,:) = 0;
% ring 1 - white
qr_code(6:35,6:7,:) = 255;
qr_code(6:35,34:35,:) = 255;
qr_code(6:7,6:35,:) = 255;
qr_code(34:35,6:35,:) = 255;
% ring 2 - red
qr_code(9:32,9:10,1) = 255;
qr_code(9:32,31:32,1) = 255;
qr_code(9:10,9:32,1) = 255;
qr_code(31:32,9:32,1) = 255;
% ring 3 - green
qr_code(12:29,12:13,2) = 255;
qr_code(12:29,28:29,2) = 255;
qr_code(12:13,12:29,2) = 255;
qr_code(28:29,12:29,2) = 255;
% ring 4 - blue
qr_code(15:26,15:16,3) = 255;
qr_code(15:26,25:26,3) = 255;
qr_code(15:16,15:26,3) = 255;
qr_code(25:26,15:26,3) = 255;
% inner box - white
qr_code(17:24,17:24,:) = 255;

% step 3: data boxes
data = img_scaled;

data_index = 1;
for i = 5:4:252
    for j = 5:4:252
        % check if position is not inside orientation box
        % if available, insert data
        if (i > 36) || (j > 36)
            qr_code(i:i+4,j:j+4,1) = data(data_index);
            qr_code(i:i+4,j:j+4,2) = data(data_index+1);
            qr_code(i:i+4,j:j+4,3) = data(data_index+2);
            data_index = data_index + 3;
        end
    end
end

imshow(qr_code);