% Load hot pixel info
load('hot_mask.mat')

%% Load Data

% Load first dataset for time series info
load('IBIS3_Estim_B2.45V_10uA.mat');

% Time series
tt = 0:1/40:(size(fr,3)-1)/40;

% Initialize incrementer 
nn = 0; 

% Four stimulation settings: 10uA, 25uA, 50uA, 100uA
neural_trace = zeros(4,length(tt));

for ii = [10 25 50 100]

    % Load dataset
    load(['IBIS3_Estim_B2.45V_' num2str(ii,'%0.2d') 'uA.mat']);

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






