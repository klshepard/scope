%% Load Data
load('dataset_01.mat')

% Time series
tt = 0:1/40:(size(fr,3)-1)/40;

% Calculate Delta F over F
dF_F = (fr-median(fr,3))./median(fr,3);

% Set Inf to zero
dF_F(dF_F == Inf) = 0;
dF_F(isnan(dF_F)) = 0;

% Pixel region of interest
row = 91;
col = 130;
inc = 2;

% Extract ROI from sensor data
neural_trace = squeeze(mean(dF_F(row-inc:row+inc,col-inc:col+inc,:),[1 2]));

% Remove stimulation artifacts
neural_trace([402:404 806:808 1210:1212 1614:1616 2018:2020 2422:2424 2826:2828 3230:3232 3634:3636]) = NaN;

% Plot time trace data
figure;
plot(tt,neural_trace,'LineWidth',0.1,'Color','k'); hold on;

% Red rectangular shape to show stimulation time frames
area(tt(401:405),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(805:809),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(1209:1213),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(1613:1617),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(2017:2021),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(2421:2425),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(2825:2829),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(3229:3233),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);
area(tt(3633:3637),0.5.*ones(1,5),-0.2,'FaceColor','r','FaceAlpha',0.5);

% Plot settings
xlim([5 95]);
ylim([-0.1 0.3]);
xlabel('time (s)'); 
ylabel('\DeltaF/F');
set(gca,'FontSize',14);


%% Show overlapping stimulus pulses

% Region of Interest
row = 91;
col = 130;
inc = 2;

% Time series
tt = 0:1/40:(size(fr,3)-1)/40;

% Red LED stimulation pulse time points
idx = 404*[1:9]+1;

% Initialize vector
neural_trace = [];
for ii = 1:length(idx)
    
    % Extract ROI
    tmp = fr(row-inc:row+inc,col-inc:col+inc,[idx(ii)-30:idx(ii)+80]);

    % Remove stimulation artifacts
    tmp(:,:,28:30) = NaN;

    % Add to vector
    neural_trace = cat(2,neural_trace,squeeze(mean(tmp,[1 2])));
end

% Calculate Delta F over F
dF_F = (neural_trace-median(neural_trace,1,'omitnan'))./median(neural_trace,1,'omitnan');

figure;

% Plot overlaid time series
for ii=1:length(idx)
    p3 = patchline([1:length(neural_trace)]'.*0.04,dF_F(:,ii),'edgecolor',[0.4 0.4 0.4],'linewidth',2,'edgealpha',0.2); hold on;
end

% Red rectangular shape to show stimulation time frames
area([27:31]'.*0.04,0.15.*ones(1,5),-0.1,'FaceColor','r','FaceAlpha',0.5);

% Plot mean stimulus response
plot([1:length(neural_trace)]'.*0.04,mean(dF_F,2),'LineWidth',2,'Color','k'); hold on;

% Plot parameters
xlim([0 4.2]);
ylim([-0.05 0.1]);
ylabel('\DeltaF/F'); 
xlabel('time (s)');
set(gca,'FontSize',14);


%% Image captures
load('dataset_01.mat')

% Initialize vector
idx = [1:size(fr,3)];

% Stimulation pulse time frames
red_idx = [402:404 806:808 1210:1212 1614:1616 2018:2020 2422:2424 2826:2828 3230:3232 3634:3636 4038:4040];
idx(red_idx) = [];
valid_idx = 1:4010;
idx = idx(valid_idx);

% Calculate Delta F over F
fr_new = (fr(:,:,idx) - movmean(fr(:,:,idx),100,3))./movmean(fr(:,:,idx),100,3);

% Remove high variance pixels due to light leakage
var_fr_new = var(fr_new,[],3) < 0.01;
fr_tmp = fr_new.*var_fr_new;
nt = size(fr_new,3);

% Spatial binning for visualization
nbin = 4;
nr = 192/nbin;
nc = 256/nbin;
npix = nr*nc;

frBin = ibis_binning(fr_tmp,nbin);

% Crop to region of interest
snip = rot90(frBin(32/nbin:160/nbin,64/nbin:208/nbin,:),2);

% Stimulation indices
idx_p = [402:401:4010];

% Mean frame before stimulus
figure; imagesc(mean(snip(:,:,idx_p-1),3),[0 0.2]); colormap(jet); axis image;

% Mean frame post stimulus
figure; imagesc(mean(snip(:,:,idx_p),3),[0 0.2]); colormap(jet); axis image;

