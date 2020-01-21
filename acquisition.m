%% create a folder for the current day
root_folder = strcat('D:\Users\Comedia\melo\',datestr(now,'ddmmyyyy'),'\');
[status, msg, msgID] = mkdir(root_folder);
disp(msg);
% add the path of the project
addpath('D:\Users\Comedia\moro\git_code\SpectraScan\');

%% initialize the monochromator and the camera
% monochromator
mono = monochromator();
% camera

imaqreset;
PCOexp = 100;
PCOmultipleframes = 1;
PCOvid = videoinput('pcocameraadaptor_r2019b', 0, 'CameraLink');
PCOsrc = getselectedsource(PCOvid);
PCOvid.FramesPerTrigger = 1;
PCOsrc.E1ExposureTime_unit = 'ms';
PCOsrc.E2ExposureTime = PCOexp;
% pause to be sure the video adaptor has been properly loaded
pause(10);
%% Show spectrum to help calibration procedure
mono.show_spectra_live();
%% perform the calibration
mono.start_calibration(500,700,0.1)    
%% live sream from upper camera
figure()
plot(mono.output_intensity(:,1),mono.output_intensity(:,2),'-o')
Iout = mono.output_intensity(:,2);
% fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
% 
% while ishandle(fig),
%     data = getsnapshot(PCOvid);
%     imagesc(data);
%     drawnow
% end
%% go to a wavelegnth, show the speckle at the camera, and allow the selection of a ROI
wav = mono.set_wavelength(600);
fprintf('set to wavelength %.1f\n', wav);
pause(1)
data = getsnapshot(PCOvid);
figure();
imagesc(data);
pause(2)
Iy =[];
for i = 1:size(data,1)
    Iy = [Iy mean(data(i,:))];
end
figure()
hold on
plot(1:size(data,1),Iy)

[peak_intensityy, argmaxy] = max(Iy);
peak_posy = argmaxy;
[xDatay, yDatay] = prepareCurveData( 1:size(data,1), Iy );
fty = fittype( 'a2*exp(-((x-b2)/c2)^2)+d2', 'independent', 'x', 'dependent', 'y' );
optsy = fitoptions( 'Method', 'NonlinearLeastSquares' );
optsy.Display = 'Off';
peak_widthy = 500;
optsy.StartPoint = [peak_intensityy peak_posy peak_widthy 100];
[fitresulty, gof] = fit( xDatay, yDatay, fty, optsy );

plot(fitresulty)
peak_posy = fitresulty.b2;
peak_intensityy = fitresulty.a2;
peak_widthy = abs(fitresulty.c2);
off_sety = fitresulty.d2;

Ix = [];
for u = 1:size(data,2)
    Ix = [Ix mean(data(:,u))];
end
figure()
hold on
plot(1:size(data,2),Ix)

[peak_intensityx, argmaxx] = max(Ix);
peak_posx = argmaxx;
[xDatax, yDatax] = prepareCurveData( 1:size(data,2), Ix );
ftx = fittype( 'a1*exp(-((x-b1)/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
optsx = fitoptions( 'Method', 'NonlinearLeastSquares' );
optsx.Display = 'Off';
peak_widthx = 350;
optsx.StartPoint = [peak_intensityx peak_posx peak_widthx 100];
[fitresultx, gof] = fit( xDatax, yDatax, ftx, optsx );

plot(fitresultx)
peak_posx = fitresultx.b1;
peak_intensityx = fitresultx.a1;
peak_widthx = abs(fitresultx.c1);
off_setx = fitresultx.d1;
datac = data((peak_posy-(peak_widthy)):(peak_posy+(peak_widthy)),(peak_posx-(peak_widthx)):(peak_posx+(peak_widthx)));
figure()
imagesc(datac);


% h = imrect;
% crop = round(h.getPosition);
% frame_size = [crop(3),crop(4)];
% crop(3:4) = crop(3:4)+crop(1:2);
% imagesc(data(crop(2):crop(4),crop(1):crop(3)));

%% perfom the acquisition of speckles at different timestamps 
% must be donee to understand after which is the time window available to
% measure the spectral decorrelation
% here a fit with an exponential decay is performed and the decay time is
% measured

wavestart = 500;
wavestop = 700;
wavestep = 2; %at least bigger than the bandwidth

totframes = length(wavestart:wavestep:wavestop)

fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);

    video_data = []; 
    tic
    time_stamps = [toc];

    for frameno = 1:totframes
        data = getsnapshot(PCOvid);
        time_stamps = [time_stamps toc];
        %datac = data(crop(2):crop(4),crop(1):crop(3));
        datac = data((peak_posy-(peak_widthy)):(peak_posy+(peak_widthy)),(peak_posx-(peak_widthx)):(peak_posx+(peak_widthx)));
        video_data = cat(3, video_data, datac);
        imagesc(datac);
        drawnow
        pause(PCOexp/1000);
    end

    % search for an available filename and save 
    save(get_next_filename(root_folder, 'wavelength_scan') ,'video_data','time_stamps','-v7.3');

    % measure the decorrelation time
    figure('name', 'decorrelation in time');
    time_decorrelations = [];
    for frameno = 1:totframes
        time_decorrelations = [time_decorrelations corr2(video_data(:,:,1), video_data(:,:,frameno))];
    end
    plot(time_stamps(2:end), time_decorrelations);
%% perfom the acquisition of speckles at different wavelength
%  and record timestamps to correct for temporal decorrelation (done not simoultaneously)

wavestart = 500;
wavestop = 700;
wavestep = 2;

fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
video_data = []; 

time_stamps = [];
wavelengths = [];
tic

for wavelength = wavestart:wavestep:wavestop
    wav = mono.set_wavelength(wavelength);
    fprintf('set to wavelength %.1f\n', wav);
    data = getsnapshot(PCOvid);
    datac = data((peak_posy-(peak_widthy)):(peak_posy+(peak_widthy)),(peak_posx-(peak_widthx)):(peak_posx+(peak_widthx)));
    time_stamps = [time_stamps toc];
    video_data = cat(3, video_data, datac);
    wavelengths = [wavelengths wav];
    imagesc(datac);
    drawnow
    pause(PCOexp/1000);
end



% search for an available filename and save 
save(get_next_filename(root_folder, 'wavelength_scan') ,...
    'video_data','time_stamps','wavelengths','-v7.3');

% measure the spectral decorrelation and the relative contrast variation

spectral_decorrelations = [];
contrasts = [];

for idx = 1:size(wavestart:wavestep:wavestop,2)
    spectral_decorrelations = [spectral_decorrelations corr2(video_data(:,:,1), video_data(:,:,idx))];
    mmtemp = mean(video_data(:,:,idx),3);
    contrasts = [contrasts std2(mmtemp)/mean(mean(mmtemp))];
end


figure('name', 'spectral decorrelation', 'position', [400, 200, 600, 600]);    
plot(wavelengths, spectral_decorrelations);
% figure('name', 'spectral decorrelation_real', 'position', [400, 200, 600, 600]);

relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));
figure('name', 'relative contrast', 'position', [600, 200, 600, 600]);
plot(wavelengths, relative_contrast);

%% variation of crontrast with z movement
PCOsrc.E2ExposureTime = 100;
T=0;
fig = figure()

% while ishandle(fig)
%     imagesc(getsnapshot(PCOvid)); daspect([1 1 1])
%     colorbar
%     pause(0.01)
%       datatry = getsnapshot(PCOvid);
%       Iy =[];
%       pause(0.05)
%       for i = 1:size(datatry,1)
%         Iy = [Iy mean(datatry(i,:))];
%       end
%       
%       [peak_intensityy, argmaxy] = max(Iy);
%         peak_posy = argmaxy;
%         [xDatay, yDatay] = prepareCurveData( 1:size(datatry,1), Iy );
%         fty = fittype( 'a2*exp(-((x-b2)/c2)^2)+d2', 'independent', 'x', 'dependent', 'y' );
%         optsy = fitoptions( 'Method', 'NonlinearLeastSquares' );
%         optsy.Display = 'Off';
%         peak_widthy = 500;
%         optsy.StartPoint = [peak_intensityy peak_posy peak_widthy 100];
%         [fitresulty, gof] = fit( xDatay, yDatay, fty, optsy );
% 
%         
%         peak_posy = fitresulty.b2;
%         peak_intensityy = fitresulty.a2;
%         peak_widthy = abs(fitresulty.c2);
%         off_sety = fitresulty.d2;
% 
%         Ix = [];
%         for u = 1:size(datatry,2)
%             Ix = [Ix mean(datatry(:,u))];
%         end
% 
%         [peak_intensityx, argmaxx] = max(Ix);
%         peak_posx = argmaxx;
%         [xDatax, yDatax] = prepareCurveData( 1:size(datatry,2), Ix );
%         ftx = fittype( 'a1*exp(-((x-b1)/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
%         optsx = fitoptions( 'Method', 'NonlinearLeastSquares' );
%         optsx.Display = 'Off';
%         peak_widthx = 350;
%         optsx.StartPoint = [peak_intensityx peak_posx peak_widthx 100];
%         [fitresultx, gof] = fit( xDatax, yDatax, ftx, optsx );
% 
%         
%         peak_posx = fitresultx.b1;
%         peak_intensityx = fitresultx.a1;
%         peak_widthx = abs(fitresultx.c1);
%         off_setx = fitresultx.d1;
%         datacropped = datatry((peak_posy-(peak_widthy/2)):(peak_posy+(peak_widthy/2)),(peak_posx-(peak_widthx/2)):(peak_posx+(peak_widthx/2)));
%         pause(0.05)
%         imagesc(datatry); daspect([1 1 1])
%         colorbar
%         contrasts =  std2(datacropped)/mean(mean(datacropped))
%  end
%% close all and clean
delete(mono);
imaqreset;
clear all