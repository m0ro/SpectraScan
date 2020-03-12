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

%% plotting the decorrelation and contrast
close all
D = [];
W = [];
C = [];
RC = [];
for ii = 5:7
    load(['data_28022020_W-FirstSlice150_00' num2str(ii) '.mat']);
    video_data_D = mycrop(video_data_D);
    figure()
    imagesc(video_data_D(:,:,end));
    
    
    decorrelation = [];
    contrasts = [];
    r2 = [];
    for idx = 1:size(time_stamps_D,2)
        decorrelation = [decorrelation corr2(video_data_D(:,:,1), video_data_D(:,:,idx))];
        contrasts = [contrasts std2(video_data_D(:,:,idx)./mean2(video_data_D(:,:,idx)))];
    end
    W = [W; wavelengths];
    D = [D; decorrelation];
    C = [C; contrasts];
    relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));
    RC = [RC; relative_contrast];
    
    figure(144)
    plot((wavelengths),(decorrelation),'LineWidth',1);
    title('Decorrelation curves of 500um thick mouse cerebellum')
    xlabel('Wavelength (nm)')
    ylabel('Decorrelation');
    legend('100ms at 17.13h',...
    '10ms at 17.30h',...
    '50ms first realization at 17.48h',...
    '50ms second realization at 18.02h',...
    '50ms third realization at 18.15h ',...
    '50ms in another point at 18.43h ')
    hold on
    figure(145)
    plot(wavelengths, contrasts ,'LineWidth',1);
    title('Contrast curves of 500um thick mouse cerebellum')
    legend('100ms at 17.13h',...
    '10ms at 17.30h',...
    '50ms first realization at 17.48h',...
    '50ms second realization at 18.02h',...
    '50ms third realization at 18.15h ',...
    '50ms in another point at 18.43h ')
    xlabel('Wavelength (nm)')
    ylabel('Contrast');
    hold on
    figure(146)
    plot(wavelengths, relative_contrast ,'LineWidth',1);
    title('Relative contrast curves of 500um thick mouse cerebellum')
    legend('100ms at 17.13h',...
    '10ms at 17.30h',...
    '50ms first realization at 17.48h',...
    '50ms second realization at 18.02h',...
    '50ms third realization at 18.15h ',...
    '50ms in another point at 18.43h ')
    xlabel('Wavelength (nm)')
    ylabel('(C-mean(C))/mean(C)');
    hold on
end

%% plotting the relative contrast
figure('name', 'brain500 relative contrast');
RC = [];
W = [];
for ii = 5:10
    load(['data_28022020_W-FirstSlice150_00' num2str(ii) '.mat']);
    video_data_D = mycrop(video_data_D);
    contrasts = [];
    for idx = 1:size(video_data_D,3)
        contrasts = [contrasts std2(video_data_D(:,:,idx)./mean2(video_data_D(:,:,idx)))];
    end
    relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));
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

legend('100ms at 17.13h - fit',...
    '10ms at 17.30h - fit',...
    '50ms first realization at 17.48h - fit',...
    '50ms second realization at 18.02h - fit',...
    '50ms third realization at 18.15h - fit',...
    '50ms in another point at 18.43h - fit')
title(['Relative contrast curves of 500um thick mouse cerebellum and linear fit with R² = ' num2str(gof.rsquare)])
xlabel('Wavelength (nm)')
ylabel('Relative contrast');

%% plotting fixed time decorrelation curve
close all
figure()
TT = [];
TD = [];

for ii = 4:9
    load(['data_28022020_T-FirstSlice150_00' num2str(ii) '.mat']);
    video_data_TD = mycrop(video_data_TD);
             time_decorrelations = [];
             for idx = 1:size(video_data_TD,3)
                time_decorrelations = [time_decorrelations corr2(video_data_TD(:,:,1),video_data_TD(:,:,idx))]
             end
    TD = [TD; time_decorrelations];
    TT = [TT; time_stamps_TD(1:end)-time_stamps_TD(1)];
    plot(time_stamps_TD(1:end)-time_stamps_TD(1), time_decorrelations, 'LineWidth', 1);
    hold on
end

% [xData, yData] = prepareCurveData( TT, TD );
% 
% % Set up fittype and options.
% ft = fittype( '(1-d1)*exp(-(x*sqrt(log(2))/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
% excludedPoints = excludedata( xData, yData, 'Indices', [1 2 3] );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% opts.StartPoint = [10 0.228976968716819];
% opts.Exclude = excludedPoints;
% 
% % Fit model to data.
% [fitresult, gof] = fit( xData, yData, ft, opts );
% 
% 
% h = plot(fitresult, 'k')
% h.LineWidth = 1;
legend('100ms at 17.18h',...
    '10ms at 17.54h',...
    '50ms first realization at 17.52h',...
    '50ms second realization at 18.05h',...
    '50ms third realization at 18.18h ',...
    '50ms in another point at 18.50h ')
% legend('50ms first realization at 17.52h',...
%     '50ms second realization at 18.05h',...
%     '50ms third realization at 18.18h ',...
%     ' 0.7064*exp(-(t*sqrt(log(2))/\delta_t)^2)+0.2936')
% title(['Temporal decorrelation curves of 500um thick mouse cerebellum at fixed instants and gaussian fit with \delta_t = '...
%     num2str(fitresult.c1) 'and R² =' num2str(gof.rsquare)])
xlabel('Time(s)');
ylabel('Time decorrelation');
title('Time decorrelation curves of 500um thick mouse cerebellum at fixed instants')
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
bandwidth = 58;

for ii = 7:9
load(['data_28022020_W-FirstSlice150_00' num2str(ii) '.mat']);
video_data_D = mycrop(video_data_D);
correlation = correlation_function_average(video_data_D,wavelengths,time_stamps_D,bandwidth);
%%%method 25/07/18
X = [];
Y = [];
T = [];
XX = [XX [X correlation(:,2)]];
YY = [YY [Y correlation(:,1)]];
TEMPO = [TEMPO [T correlation(:,3)]];

end

% calculating the fit

[xData, yData] = prepareCurveData( XX(XX~=0), YY(YY~=0) );

% Set up fittype and options.
ft = fittype( '(1-a)*exp(-x/b)+a', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
% opts.Robust = 'LAR';

opts.Lower = [0 0];
opts.StartPoint = [0.2 1];
opts.Upper = [1 10];



% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
b = fitresult.b;
% c = fitresult.c;
a = fitresult.a;

% fun = @(x) a*exp(-x/b)+c;
% x0 =[1];
% deltalambda = abs(fminsearch(fun,x0))

% plotting detuning and fit
figure()
plot(XX,YY,'.')
hold on
% for k = 1:size(ii)
%     for iii = 1:size(XX,1)
%         if TEMPO(iii,k) < 58
%             plot(XX(iii,k),YY(iii,k),'.','color',[0 TEMPO(iii,k)/max(TEMPO(:,k)) TEMPO(iii,k)/max(TEMPO(:,k))])
%             hold on  
%         end
%     end
% end
h = plot(fitresult,'k-');
h.LineWidth = 2;
xlabel('Detuning (nm)')
ylabel('Correlation')
% legend('First Realization at 50ms exposure time',...
%     'Second Realization at 50ms exposure time','Third Realization at 50ms exposure time',[num2str(1-fitresult.a) '*exp(-\lambda/\delta\lambda)+' num2str(fitresult.a)])
legend('First Realization at 50ms exposure time',...
    'Second Realization at 50ms exposure time','Third Realization at 50ms exposure time',...
    [num2str(1-fitresult.a) '*exp(-\lambda/\delta\lambda)+' num2str(fitresult.a)])
%     'Realization in another point', '10ms exposure time','100ms exposure time',...
   
title(['Spectral Correlation Bandwidth \delta\lambda = ' num2str(fitresult.b) ' nm   R² = ' num2str(gof.rsquare)])

%% plotting the detuning with colorbar
figure()
for k = 1:size(ii)
    for iii = 1:size(XX,1)
        if TEMPO(iii,k) < 50
        plot(XX(iii,k),YY(iii,k),'.','color',[0 TEMPO(iii,k)/max(TEMPO(:,k)) 0])
        hold on
        end
    end
end

%% plotting free time decorrelation curves (can't put all the data in a matrix because dimension inconsistent)
 figure()
for ii = 3:8
    load(['data_28022020_T_free-FirstSlice150_00' num2str(ii) '.mat']); 
    free_video_data = mycrop(free_video_data);
             free_time_decorrelations = [];
             for idx = 1:size(free_video_data,3)
                free_time_decorrelations = [free_time_decorrelations corr2(free_video_data(:,:,1),free_video_data(:,:,idx))]
             end
    plot(free_time_stamps(1:end)-free_time_stamps(1), free_time_decorrelations,'LineWidth', 1);
    
    hold on
end
legend('100ms at 17.22h',...
    '10ms at 17.38h',...
    '50ms first realization at 17.55h',...
    '50ms second realization at 18.08h',...
    '50ms third realization at 18.22h ',...
    '50ms in another point at 18.53h ')
title('Temporal decorrelation curves of 500um thick mouse cerebellum')
xlabel('Time(s)');
ylabel('Time decorrelation');
axis([0 200 0 1])

%% analogous to the detuning but enabling us to have the variation of delta lambda as increasing lambda

figure()
delta_lambda_total = [];
r2_total = [];
bandwidth = 58;

for ii = 7:9
    load(['data_28022020_W-FirstSlice150_00' num2str(ii) '.mat']);
    video_data_D = mycrop(video_data_D);
    
    MCF = zeros(size(time_stamps_D,2),size(time_stamps_D,2));
    delta_lambda = [];
    r2 = [];
    
    for n = 1:size(time_stamps_D,2)
        
        
        for k = 1:size(time_stamps_D,2)
            if abs(time_stamps_D(k)-time_stamps_D(n)) < bandwidth 
                MCF(n,k) = corr2(video_data_D(:,:,n),video_data_D(:,:,k));
            end
        end
        
%         plot(wavelengths(n), MCF(n,:))
%         title('Decorrelation curves for different starting points')
%         xlabel('\lambda (nm)')
%         ylabel('Decorrelation')
%         legend(['Starting correlating at ' num2str(wavelengths(n)) ' nm'])
%         hold on
        
        [xData, yData] = prepareCurveData( wavelengths , MCF(n,:) ); 

        %Set up fittype and options.
      
        ft = fittype( '(1-a)*exp(-(abs(x-b))/c)+a', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.Lower = [0 460 0];
        opts.StartPoint = [0.05 wavelengths(n) 1];
        opts.Upper = [1 705 10];
        opts.Exclude = MCF(n,:) == 0;
        
        %Fit model to data.
        [fitresult, gof] = fit( xData, yData, ft, opts );
%         plot(fitresult)
%         hold on
        if gof.rsquare > 0.8
            delta_lambda = [delta_lambda; fitresult.c];
            r2 = [r2; gof.rsquare];
            %plot(wavelengths(n), fitresult.c,'bo')
            %plot(wavelengths(n), gof.rsquare,'ro')
            %hold on
        end
    end
    delta_lambda_total = [delta_lambda_total delta_lambda];
    r2_total = [r2_total r2];
    
end
mean_delta_lambda_total = mean(mean(delta_lambda_total)) 
mean_r2_total = mean(mean(r2_total)) 
figure()
plot(wavelengths,delta_lambda_total)
legend('50ms first realization at 17.48h',...
    '50ms second realization at 18.02h',...
    '50ms third realization at 18.15h ')
% legend('100ms at 17.13h',...
%     '10ms at 17.30h')
title('Decay constant as a function of \lambda')
xlabel('\lambda (nm)')
ylabel('\delta\lambda (nm)')
%%

for k = length(time_stamps_D):-1:1
    for q = length(time_stamps_D)-k-1:-1:1 % loop on the different steps between different omegas 
        i=i+1; 
        x = abs(time_stamps_D(k)-time_stamps_D(k-q));
    end
end
            