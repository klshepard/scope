% Load hot pixel info
load('hot_mask.mat')

%% Load Data

% Load first dataset 
load('dataset_10uA.mat');

% Average image capture
figure; imagesc(mean(fr,3).*hot_mask./1022); colorbar('jet'); axis image;

%% Increasing current stim
% Time series
tt = 0:1/40:(size(fr,3)-1)/40;

% Initialize incrementer 
nn = 0; 

% Four stimulation settings: 10uA, 25uA, 50uA, 100uA
neural_trace = zeros(4,length(tt));

for ii = [10 25 50 100]

    % Load dataset
    load(['dataset_' num2str(ii,'%0.2d') 'uA.mat']);

    % Remove hot pixel
    fr = fr.*hot_mask;

    % Calculate Delta F / F
    dF_F = (fr-median(fr,3))./median(fr,3);

    % Set values that evaluate to Inf equal to 0
    dF_F(dF_F == Inf) = 0;
    dF_F(isnan(dF_F)) = 0;

    % Region of Interest : row pixel 97 +- 4, col pixel 177 +- 4
    neural_trace(nn+1,:) = squeeze(mean(dF_F(97-4:97+4,177-4:177+4,:),[1 2]));

    % Increment
    nn = nn+1;
end

%% Synchronization of Signals

% Create time axis label vector
time_sync = tt(1:1371);

% Apply manual synchronization of time traces
neural_sync = [neural_trace(1,111-70:111+1300);
    neural_trace(2,72-70:72+1300);
    neural_trace(3,199-70:199+1300);
    neural_trace(4,154-70:154+1300)];

% Create current stim axis label vector
I_sync = [10; 25; 50; 100].*ones(1,1371);

figure;

% Plot3D
plot3(time_sync',I_sync',neural_sync','LineWidth',1,'Color','k');

% Plot attributes
view(45, 45);
set(gca,'YScale','linear');
yticks([10 25 50 100])
yticklabels({'10\muA','25\muA','50\muA','100\muA'});
xlabel('time (sec)');
ylabel('I_{stim} (\muA)');
zlabel('\DeltaF/F');
set(gca,'FontSize',14);



%% Spatial Fallout

% Initialize
nn = 0; ii = [10 25 50 100];

% Synchronize
tt = [111 72 199 154]+4;

% Plot images
for aa = 1:length(ii)

    figure;

    % Load data
    load(['dataset_' num2str(ii(aa),'%0.2d') 'uA.mat']);

    % Remove hot pixel
    fr = fr.*hot_mask;

    % Remove high variance (light leakage)
    fr = fr.*(mean(fr,3)>200);

    % Calculate Delta F over F
    dF_F = (fr-median(fr,3))./median(fr,3);

    % Set Inf to zero
    dF_F(dF_F == Inf) = 0;
    dF_F(isnan(dF_F)) = 0;

    % Imagesc plots
    imagesc(mean(dF_F(:,:,tt(aa):tt(aa)+20),3),[0 0.2]); axis image; 

    % Colormap Jet
    colormap('jet');

    % Title
    title(['I_{stim} = ' num2str(ii(aa)) '\muA']);
end


