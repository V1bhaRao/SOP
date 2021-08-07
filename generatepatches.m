function [imdb] = generatepatches

addpath('utilities');
batchSize     = 8;        % batch size
global CurTask
if strcmpi(CurTask, 'Denoising')
    folder    = 'Train_Set';  %
    folder2 ='Train2';    %m
%     folder    = 'BSD300';
    stride    = 130;
    scales  = [1]; % scale the image to augment the training data
else
    folder = 'Train_Set';
    folder2 ='Train2';   %m
    stride = 100;
    scales  = [1]; % scale the image to augment the training data

end
nchannel      = 1;           % number of channels
patchsize     = 160;

step1         = randi(stride)-1;
step2         = randi(stride)-1;
count         = 0;
count2=0; %m
ext           =  {'*.jpg','*.png','*.bmp','*.jpeg'};
filepaths     =  [];
filepaths2= []; %m
for i = 1 : length(ext)
    filepaths = cat(1,filepaths, dir(fullfile(folder, ext{i})));
end

for i = 1 : length(ext) %m
    filepaths2 = cat(1,filepaths2, dir(fullfile(folder2, ext{i}))); %m
end %m

% count the number of extracted patches
for i = 1 : length(filepaths)
    
    image = imread(fullfile(folder,filepaths(i).name)); % uint8
    if size(image,3)==3
        if strcmpi(CurTask, 'Denoising')
            image = rgb2gray(image);  %
        else
            image = rgb2ycbcr(image);
            image = image(:,:,1);
        end
    end
    %[~, name, exte] = fileparts(filepaths(i).name);
    if mod(i,100)==0
        disp([i,length(filepaths)]);
    end
    for s = 1:length(scales)
        image = imresize(image,scales(s),'bicubic');
        [hei,wid,~] = size(image);
        for x = 1+step1 : stride : (hei-patchsize+1)
            for y = 1+step2 :stride : (wid-patchsize+1)
                count = count+1;
            end
        end
    end
end

%..........m

for i = 1 : length(filepaths2)
    
    image = imread(fullfile(folder2,filepaths2(i).name)); % uint8
    if size(image,3)==3
        if strcmpi(CurTask, 'Denoising')
            image = rgb2gray(image);  %
        else
            image = rgb2ycbcr(image);
            image = image(:,:,1);
        end
    end
    %[~, name, exte] = fileparts(filepaths2(i).name);
    if mod(i,100)==0
        disp([i,length(filepaths2)]);
    end
    for s = 1:length(scales)
        image = imresize(image,scales(s),'bicubic');
        [hei,wid,~] = size(image);
        for x = 1+step1 : stride : (hei-patchsize+1)
            for y = 1+step2 :stride : (wid-patchsize+1)
                count2 = count2+1;
            end
        end
    end
end


%.........m


numPatches  = ceil(count/batchSize)*batchSize;
diffPatches = numPatches - count;
disp([int2str(numPatches),' = ',int2str(numPatches/batchSize),' X ', int2str(batchSize)]);


%............m
numPatches2  = ceil(count2/batchSize)*batchSize;
diffPatches2 = numPatches2 - count2;
disp([int2str(numPatches2),' = ',int2str(numPatches2/batchSize),' X ', int2str(batchSize)]);


%............m


count = 0;
imdb.labels  = zeros(patchsize, patchsize, nchannel, numPatches,'single');
imdb.labels2  = zeros(patchsize, patchsize, nchannel, numPatches2,'single');    %m

for i = 1 : length(filepaths)
    
    image = imread(fullfile(folder,filepaths(i).name)); % uint8
    %[~, name, exte] = fileparts(filepaths(i).name);
    if size(image,3)==3
        if strcmpi(CurTask, 'Denoising')
            image = rgb2gray(image);  %
        else
            image = rgb2ycbcr(image);
            image = image(:,:,1);
        end
    end
    if mod(i,100)==0
        disp([i,length(filepaths)]);
    end
    for s = 1:length(scales)
        image = imresize(image,scales(s),'bicubic');
        for j = 1:1
            image_aug   = data_augmentation(image, j);  % augment data
            im_label    = im2single(image_aug);         % single
            [hei,wid,~] = size(im_label);
            
            for x = 1+step1 : stride : (hei-patchsize+1)
                for y = 1+step2 :stride : (wid-patchsize+1)
                    count       = count+1;
                    imdb.labels(:, :, :, count)   = im_label(x : x+patchsize-1, y : y+patchsize-1,:);
                    if count<=diffPatches
                        imdb.labels(:, :, :, end-count+1)   = im_label(x : x+patchsize-1, y : y+patchsize-1,:);
                    end
                end
            end
        end
    end
end



%.........m
count2=0;
for i = 1 : length(filepaths2)
    
    image = imread(fullfile(folder2,filepaths2(i).name)); % uint8
    %[~, name, exte] = fileparts(filepaths2(i).name);
    if size(image,3)==3
        if strcmpi(CurTask, 'Denoising')
            image = rgb2gray(image);  %
        else
            image = rgb2ycbcr(image);
            image = image(:,:,1);
        end
    end
    if mod(i,100)==0
        disp([i,length(filepaths2)]);
    end
    for s = 1:length(scales)
        image = imresize(image,scales(s),'bicubic');
        for j = 1:1
            image_aug   = data_augmentation(image, j);  % augment data
            im_label    = im2single(image_aug);         % single
            [hei,wid,~] = size(im_label);
            
            for x = 1+step1 : stride : (hei-patchsize+1)
                for y = 1+step2 :stride : (wid-patchsize+1)
                    count2       = count2+1;
                    imdb.labels2(:, :, :, count2)   = im_label(x : x+patchsize-1, y : y+patchsize-1,:);
                    if count2<=diffPatches
                        imdb.labels2(:, :, :, end-count2+1)   = im_label(x : x+patchsize-1, y : y+patchsize-1,:);
                    end
                end
            end
        end
    end
end

%.........m
imdb.set    = uint8(ones(1,size(imdb.labels,4)));

