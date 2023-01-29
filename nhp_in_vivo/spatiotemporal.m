load('dataset_01.mat')
load('led_mask.mat');

% Synchronize to peak speed
testpeaks = [750 821 875 940 1016 1087 1154 1229 1301 1380 1446 1522 1637 1706 1779 1849 1919 ];

% Extract temporal window of +- 20 samples
win = 20;

% Initialize vector
data_all = [];
for ii = 1:length(testpeaks)

    % Append data to vector
    seed = testpeaks(ii);
    data_all(:,:,:,ii) = fr(:,:,seed-win:seed+win);

end

figure;

% Time series vector
fs = 40;
tt = -win./fs:1/fs:(win-1)./fs;

% Average the response over all reaches
avg_all = mean(data_all,4);

% Plot the spatial response versus time
for ii = 1:2*win

    subplot(5,8,ii)

    % Binned sensor pixels by 4x4
    implot = flipud(ibis_binning(avg_all(:,:,ii),4));

    % Normalize by the sensor mean
    implot = implot - mean(implot,[1 2]);

    % Plot imagesc
    imagesc(implot.*flipud(led_mask),[-0.3 0.3]);

    % Label for current time point
    text(2,2,[num2str(tt(ii),'%5.3f') 's'])

    % Plot parameters
    colormap(jet)
    axis image;
    
end



