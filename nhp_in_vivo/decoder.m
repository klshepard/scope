%% NHP decoder

% Example training and testing data
trainmask = 1100:1500;
testmask = 1150:1350;

% Load training dataset
load('dataset_01.mat');

% Extract sensor locations corresponding to M1 brain region
fr = flipud(fr);
sptm = reshape(fr(25:48,1:32,:),[24*32 2001]);

% Extract training feature (position)
trainposfeat = posx(trainmask)';

% Extract training feature (speed)
trainvelfeat = smooth(abs(posx(2:end)'-posx(1:end-1)'),10);
trainvelfeat = trainvelfeat(trainmask)./max(trainvelfeat(:));

% Extract training data, synchronize, and remove zeros indices (LED blocks and hot pixel)
traindata = sptm(:,trainmask-lag)';
traindata(:,~any(traindata)) = [];

% Optional sensor mean normalization flag
% traindata = traindata-mean(traindata,2);

% Load testing dataset
load('dataset_02.mat')

% Extract sensor locations corresponding to M1 brain region
fr = flipud(fr);
sptm = reshape(fr(25:48,1:32,:),[24*32 2001]);

% Extract testing feature (position)
testposfeat = posx(testmask)';

% Extract training feature (speed)
testvelfeat = smooth(abs(posx(2:end)'-posx(1:end-1)'),10);
testvelfeat = testvelfeat(testmask)./max(testvelfeat(:));


% Extract testing data, synchronize, and remove zeros indices (LED blocks and hot pixel)
testdata = sptm(:,testmask-lag)';
testdata(:,~any(testdata)) = [];

% Optional sensor mean normalization flag
% testdata = testdata-mean(testdata,2);

% Sweep 'k' parameter to optimize correlation
k = [1:100:1000]; clear cc_vel cc_pos
nK = length(k);
for iK = 1:nK
    b = ridge(trainposfeat,traindata,k(iK),0);
    pospred = b(1) + testdata*b(2:end);
    x = corrcoef(testposfeat,pospred);
    cc_pos(iK) = x(1,2);

    b = ridge(trainvelfeat,traindata,k(iK),0);
    velpred = b(1) + testdata*b(2:end);
    x = corrcoef(testvelfeat,velpred);
    cc_vel(iK) = x(1,2);
end

% Find max 'k' parameter index
[~,idx] = max(cc_vel);

% Ridge regression
b = ridge(trainvelfeat,traindata,k(idx),0); 

% Linear speed prediction
velpred = b(1) + testdata*b(2:end); 

figure;

% Plot training dataset
subplot(131);
imagesc(traindata'); colormap(jet); title('Training Data'); set(gca,'YDir','normal') 
hold on;

% Plot testing speed feature
plot(trainvelfeat'*size(traindata,2),'LineWidth',2);
legend('Training Speed');

% Plot parameters
xlim([0 400]);
xticks([0:80:400])
xticklabels([0:80:400]./40);
xlabel('Time (s)');
ylabel('Pixels');
set(gca,'FontSize',14);

% Plot testing dataset
subplot(132);
imagesc(testdata'); title('Test Data'); set(gca,'YDir','normal') 
hold on;

% Plot testing speed feature
plot(testvelfeat'*size(traindata,2),'LineWidth',2);
legend('Testing Speed')

% Plot parameters
xlim([0 200]);
xticks([0:40:200])
xticklabels([0:40:200]./40);
xlabel('Time (s)');
ylabel('Pixels');
set(gca,'FontSize',14);

% Plot ground truth testing speed versus predicted speed
subplot(133);
plot(testvelfeat,'LineWidth',2); 
hold on; 
plot(velpred,'LineWidth',2); 
title('Prediction');
legend('Testing Speed','Predicted Speed')
text(2,2,['Correlation ' num2str(cc_vel,'%5.3f')]);

% Plot parameters
xlim([0 200]);
xticks([0:40:200])
xticklabels([0:40:200]./40);
xlabel('Time (s)');
ylabel('Speed (a.u.)');
set(gca,'FontSize',14);


