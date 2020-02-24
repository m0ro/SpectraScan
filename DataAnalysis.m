set(0,'DefaultFigureWindowStyle','docked')

decorrelation = [];
contrasts = [];

for idx = 1:size(time_stamps,2)
    decorrelation = [decorrelation corr2(video_data(:,:,121), video_data(:,:,122-idx))];
    contrasts = [contrasts std2(video_data(:,:,idx)./mean2(video_data(:,:,idx)))];
end
relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));

%%
time_decorrelations = [];

for idx = 1:size(time_stamps1,2)
    time_decorrelations = [time_decorrelations corr2(video_data1(:,:,1), video_data1(:,:,idx))];
end

%%
figure('name', 'salmon decorrelation');    
plot((flip(wavelengths(1:end))), (decorrelation), 'r.-');
xlabel('wavelength(nm)');
ylabel('decorrelation');
hold on
%%
figure('name', 'salmon relative contrast');
plot(wavelengths(2:end), relative_contrast, 'm.-');
xlabel('wavelength(nm)')
ylabel('relative contrast');
hold on
%%
figure('name', 'salmon decorrelation in time');
%time_stamps_TDshifted = time_stamps1-mean(time_stamps1-time_stamps); %assuming decorrelation depends on tau = t2 - t1
plot(time_stamps1(2:end), time_decorrelations, 'b.-');
xlabel('time(s)');
ylabel('time decorrelation');
hold on

%%
spectral_decorrelation = decorrelation./time_decorrelations;
figure('name', 'salmon spectral decorrelation');
plot(wavelengths(2:end), spectral_decorrelation, 'k.-');
xlabel('wavelength(nm)');
ylabel('spectral decorrelation');

%%
correlation=correlation_function_average(video_data,wavelengths,time_stamps);
%%%method 25/07/18
X=correlation(:,2);
Y=correlation(:,1);
T=correlation(:,3);
Xfit=X(1:round(100/100*size(X,1)));
Yfit=Y(1:round(100/100*size(Y,1)));
[i1 j1]=find(Xfit==0)
[i2 j2]=find(Yfit==0)
Xfit=Xfit(max(i1)+1:2:end);
Yfit=Yfit(max(i1)+1:2:end);
[xData, yData] = prepareCurveData( Xfit, Yfit );
ft = fittype( 'abs(sinh(1)*(sqrt(1+1i/b*x))/(sinh(sqrt(1+1i/b*x))))^2', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 0.381906328703183;
[fitresult, gof] = fit( xData, yData, ft, opts );
f4=figure('position',[500 400 1000 400]);
set(gcf,'color','w')
plot( X, abs(sinh(1)*(sqrt(1+1i/fitresult.b*X))/(sinh(sqrt(1+1i/fitresult.b*X))))^2,'r' );
%set(h,'linewidth',1.5)
legend('data', '', 'fit', 'Location', 'NorthEast' );
xlabel('Detuning in nm')
ylabel('Speckle Intensity Correlation')
b=fitresult.b;
fun = @(x) ((abs(sinh(1)*(sqrt(1+1i/b*x))/(sinh(sqrt(1+1i/b*x)))))^2 - 1/2)^2;
x0 =[1];
deltalambda = abs(fminsearch(fun,x0));
hold on
figure
for ii = 1:size(X,1)
    plot(X(ii),Y(ii),'.','color',[0 T(ii)/max(T) 0])
    hold on
end

% eqn = abs(sinh(1)*(sqrt(1+1i/b*x))/(sinh(sqrt(1+1i/b*x))))^2 == 1/2; % find numercially HWHM
% deltalambda = vpasolve(eqn,x);
title(['Spectral Correlation Bandwidth \delta\lambda_m = ' num2str(deltalambda) ' nm   R² = ' num2str(gof.rsquare)])
axis([0 Xfit(end) -0.1 1.1])
ax=gca
ax.YTick = [0 0.5 1]
set(gca,'fontsize',16)