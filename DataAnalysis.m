%%calculating decorrelation and relative contrast

set(0,'DefaultFigureWindowStyle','docked')

decorrelation = [];
contrasts = [];

for idx = 1:size(time_stamps_D,2)
    decorrelation = [decorrelation corr2(video_data_D(:,:,1), video_data_D(:,:,idx))];
    contrasts = [contrasts std2(video_data_D(:,:,idx)./mean2(video_data_D(:,:,idx)))];
end
relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));

%% calculating time decorrelation
time_decorrelations = [];

for idx = 1:size(time_stamps_TD,2)
    time_decorrelations = [time_decorrelations corr2(video_data_TD(:,:,1), video_data_TD(:,:,idx))];
end

%% plotting the decorrelation
figure('name', 'brain500 decorrelation');  
D = [];
W = [];
for ii = 5:10
    load(['data_28022020_W-FirstSlice150_00' num2str(ii) '.mat']);
    D = [D; decorrelation];
    W = [W; wavelengths];
    plot(wavelengths,decorrelation,'LineWidth',1);
    hold on
end

legend('100ms at 17.13h',...
    '10ms at 17.30h',...
    '50ms first realization at 17.48h',...
    '50ms second realization at 18.02h',...
    '50ms third realization at 18.15h ',...
    '50ms in another point at 18.43h ')
title('Decorrelation curves of 500um thick cerebral mouse cortex')
xlabel('Wavelength(nm)')
ylabel('Decorrelation');

%% plotting the relative contrast
figure('name', 'brain500 relative contrast');
RC = [];
W = [];
for ii = 5:10
    load(['data_28022020_W-FirstSlice150_00' num2str(ii) '.mat']);
    RC = [RC; relative_contrast];
    W = [W; wavelengths];
    plot(wavelengths, relative_contrast, 'LineWidth',1);
    hold on
end

[xData, yData] = prepareCurveData( W, RC );

% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Normalize = 'on';
opts.Robust = 'Bisquare';

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

h = plot(fitresult,'k');
h.LineWidth = 1;

legend('100ms at 17.13h',...
    '10ms at 17.30h',...
    '50ms first realization at 17.48h',...
    '50ms second realization at 18.02h',...
    '50ms third realization at 18.15h ',...
    '50ms in another point at 18.43h ',...
    '0.3802*x-0.0001734')
title(['Relative contrast curves of 500um thick cerebral mouse cortex and linear fit with R² = ' num2str(gof.rsquare)])
xlabel('Wavelength(nm)')
ylabel('Relative contrast');

%% plotting fixed time decorrelation curve
figure()
TT = [];
TD = [];

for ii = 6:8
    load(['data_28022020_T-FirstSlice150_00' num2str(ii) '.mat']);
    TD = [TD; time_decorrelations];
    TT = [TT; time_stamps_TD(1:end)-time_stamps_TD(1)];
    plot(time_stamps_TD(1:end)-time_stamps_TD(1), time_decorrelations, '.');
    hold on
end

[xData, yData] = prepareCurveData( TT, TD );

% Set up fittype and options.
ft = fittype( '(1-d1)*exp(-(x*sqrt(log(2))/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
excludedPoints = excludedata( xData, yData, 'Indices', [1 2 3] );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [10 0.228976968716819];
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );


h = plot(fitresult, 'k')
h.LineWidth = 1;
% legend('100ms at 17.18h',...
%     '10ms at 17.54h',...
%     '50ms first realization at 17.52h',...
%     '50ms second realization at 18.05h',...
%     '50ms third realization at 18.18h ',...
%     '50ms in another point at 18.50h ')
legend('50ms first realization at 17.52h',...
    '50ms second realization at 18.05h',...
    '50ms third realization at 18.18h ',...
    ' 0.7064*exp(-(t*sqrt(log(2))/\delta_t)^2)+0.2936')
title(['Temporal decorrelation curves of 500um thick cerebral mouse cortex at fixed instants and gaussian fit with \delta_t = '...
    num2str(fitresult.c1)])
xlabel('Time(s)');
ylabel('Time decorrelation');
axis([0 300 0 1])

%% nonsense
spectral_decorrelation = -decorrelation+time_decorrelations;
figure('name', 'salmon spectral decorrelation');
plot(wavelengths(1:end), spectral_decorrelation, 'k.-');
xlabel('wavelength(nm)');
ylabel('spectral decorrelation');

%% calculating detuning
XX = [];
YY = [];
TEMPO = [];

for ii = 5:10
load(['data_28022020_W-FirstSlice150_00' num2str(ii) '.mat']);
correlation = correlation_function_average(video_data_D,wavelengths,time_stamps_D);
%%%method 25/07/18
X = [];
Y = [];
T = [];
XX = [XX [X correlation(:,2)]];
YY = [YY [Y correlation(:,1)]];
TEMPO = [TEMPO [T correlation(:,3)]];
end
%% calculating the fit
YY(1:121,1:size(YY,2)) = 1;
[xData, yData] = prepareCurveData( XX, YY );

% Set up fittype and options.
ft = fittype( 'a*exp(-x/b)+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'LAR';
opts.StartPoint = [0.0057488004427404 0.827092844217338 0.27032445355846];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
b = fitresult.b
c = fitresult.c
a = fitresult.a

% fun = @(x) a*exp(-x/b)+c;
% x0 =[1];
% deltalambda = abs(fminsearch(fun,x0));

%% plotting detuning and fit
figure()
plot(XX,YY,'.')
hold on
h = plot(fitresult,'k-')
h.LineWidth = 2;
xlabel('Detuning(nm)')
ylabel('Correlation')
legend('First Realization at 50ms exposure time',...
    'Second Realization at 50ms exposure time','Third Realization at 50ms exposure time',...
    'Realization in another point', '10ms exposure time','100ms exposure time',...
    '0.7548*exp(-\lambda/\delta\lambda)+0.2452')
title(['Spectral Correlation Bandwidth \delta\lambda = ' num2str(fitresult.b) ' nm   R² = ' num2str(gof.rsquare)])

%% plotting the detuning with colorbar
figure()
for k =1:6
    for ii = 1:size(XX,1)
        if XX(ii,k) < 500
        plot(XX(ii,k),YY(ii,k),'.','color',[0 TEMPO(ii,k)/max(TEMPO(:,k)) 0])
        hold on  
        end
    end
end

%% plotting free time decorrelation curves (can't put all the data in a matrix because dimension inconsistent)
 figure()
for ii = 3:8
    load(['data_28022020_T_free-FirstSlice150_00' num2str(ii) '.mat']); 
    plot(free_time_stamps(1:end)-free_time_stamps(1), free_time_decorrelations);
    r.LineWidth = 1;
    hold on
end
legend('100ms at 17.22h',...
    '10ms at 17.38h',...
    '50ms first realization at 17.55h',...
    '50ms second realization at 18.08h',...
    '50ms third realization at 18.22h ',...
    '50ms in another point at 18.53h ')
title('Temporal decorrelation curves of 500um thick cerebral mouse cortex')
xlabel('Time(s)');
ylabel('Time decorrelation');
axis([0 300 0 1])    
