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
mono.start_calibration(480,700,0.1)    
%% Intensity distribution
figure()
plot(mono.output_intensity(:,1),mono.output_intensity(:,2),'-o')
Iout = mono.output_intensity(:,2);
%% move the sample to study different regions
PCOsrc.E2ExposureTime = 400;
T=0;
sample_explorer = figure();
wav = mono.set_wavelength(700)

while ishandle(sample_explorer)
    imagesc(getsnapshot(PCOvid)); daspect([1 1 1])
    colorbar
    pause(0.01)
      datatry = getsnapshot(PCOvid);
      Iy =[];
      pause(0.05)
      for i = 1:size(datatry,1)
        Iy = [Iy mean(datatry(i,:))];
      end
      
      [peak_intensityy, argmaxy] = max(Iy);
        peak_posy = argmaxy;
        [xDatay, yDatay] = prepareCurveData( 1:size(datatry,1), Iy );
        fty = fittype( 'a2*exp(-0.5*((x-b2)/c2)^2)+d2', 'independent', 'x', 'dependent', 'y' );
        optsy = fitoptions( 'Method', 'NonlinearLeastSquares' );
        optsy.Display = 'Off';
        peak_widthy = 500;
        optsy.StartPoint = [peak_intensityy peak_posy peak_widthy 100];
        [fitresulty, gof] = fit( xDatay, yDatay, fty, optsy );

        
        peak_posy = fitresulty.b2;
        peak_intensityy = fitresulty.a2;
        peak_widthy = 2.35482*abs(fitresulty.c2);
        off_sety = fitresulty.d2;

        Ix = [];
        for u = 1:size(datatry,2)
            Ix = [Ix mean(datatry(:,u))];
        end

        [peak_intensityx, argmaxx] = max(Ix);
        peak_posx = argmaxx;
        [xDatax, yDatax] = prepareCurveData( 1:size(datatry,2), Ix );
        ftx = fittype( 'a1*exp(-0.5*((x-b1)/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
        optsx = fitoptions( 'Method', 'NonlinearLeastSquares' );
        optsx.Display = 'Off';
        peak_widthx = 350;
        optsx.StartPoint = [peak_intensityx peak_posx peak_widthx 100];
        [fitresultx, gof] = fit( xDatax, yDatax, ftx, optsx );

        
        peak_posx = fitresultx.b1;
        peak_intensityx = fitresultx.a1;
        peak_widthx = 2.35482*abs(fitresultx.c1);
        off_setx = fitresultx.d1;
        datacropped = datatry((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
        pause(0.05)
        imagesc(datatry); daspect([1 1 1])
        colorbar
        contrasts =  std2(datacropped)/mean(mean(datacropped))
 end
%% go to a wavelength, show the speckle at the camera, and allow the selection of a ROI
wav = mono.set_wavelength(460);
fprintf('set to wavelength %.1f\n', wav);
pause(2)
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
fty = fittype( 'a2*exp(-0.5*((x-b2)/c2)^2)+d2', 'independent', 'x', 'dependent', 'y' );
optsy = fitoptions( 'Method', 'NonlinearLeastSquares' );
optsy.Display = 'Off';
peak_widthy = 500;
optsy.StartPoint = [peak_intensityy peak_posy peak_widthy 100];
[fitresulty, gof] = fit( xDatay, yDatay, fty, optsy );

plot(fitresulty)
peak_posy = fitresulty.b2;
peak_intensityy = fitresulty.a2;
peak_widthy = 2.35482*abs(fitresulty.c2);
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
ftx = fittype( 'a1*exp(-0.5*((x-b1)/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
optsx = fitoptions( 'Method', 'NonlinearLeastSquares' );
optsx.Display = 'Off';
peak_widthx = 350;
optsx.StartPoint = [peak_intensityx peak_posx peak_widthx 100];
[fitresultx, gof] = fit( xDatax, yDatax, ftx, optsx );

plot(fitresultx)
peak_posx = fitresultx.b1;
peak_intensityx = fitresultx.a1;
peak_widthx = 2.35482*abs(fitresultx.c1);
off_setx = fitresultx.d1;
datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
figure()
imagesc(datac);
%% acquisition of speckles at different wavelength and timestamps + correction

% measure the Corr(wav,t) and contrast
PCOsrc.E2ExposureTime = 400;
wavestart = 460;
wavestop = 700;
wavestep = 2;

wavelength_speckle_evolution = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);

while ishandle(wavelength_speckle_evolution)
    video_data = []; 

    time_stamps = [];
    wavelengths = [];
    I = [];
    II =[];
    III = [];
    
    k = 1;
    for wavelength = wavestart:wavestep:wavestop
        wav = mono.set_wavelength(wavelength);
        fprintf('set to wavelength %.1f\n', wav);
        pause(0.5)
        data = getsnapshot(PCOvid);
        datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
        I = [I mean2(datac)];
        II = [II mono.peak_intensity];
        III = [III mono.peak_intensity/mean2(datac)];
    end

    expo_vector = [];
    IIII = [];
    tic
    for wavelength = wavestart:wavestep:wavestop
        wav = mono.set_wavelength(wavelength);
        fprintf('set to wavelength %.1f\n', wav);
        PCOsrc.E2ExposureTime = 400.*(max(I)./I(k));
        expo_vector = [expo_vector PCOsrc.E2ExposureTime];
        fprintf('exposure time %.1f\n', PCOsrc.E2ExposureTime);
        data = getsnapshot(PCOvid);
        datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
        time_stamps = [time_stamps toc];
        video_data = cat(3, video_data, datac);
        wavelengths = [wavelengths wav];
        IIII = [IIII mean2(datac)]
        imagesc(datac); daspect([1 1 1])
        colorbar
        drawnow
        pause(PCOexp/1000);
        k = k + 1;
    end
    close(wavelength_speckle_evolution)
end

% search for an available filename and save 
save(get_next_filename(root_folder, 'W-Butter') ,...
    'video_data','time_stamps','wavelengths','-v7.3');

spectral_decorrelations = [];
contrasts = [];

for idx = 1:size(wavestart:wavestep:wavestop,2)
    spectral_decorrelations = [spectral_decorrelations corr2(video_data(:,:,1), video_data(:,:,idx))];
%     Inorm = mean2(video_data(:,:,idx))./II(idx);
    contrasts = [contrasts std2(video_data(:,:,idx)./mean2(video_data(:,:,idx)))];
end

figure('name', 'spectral decorrelation', 'position', [400, 200, 600, 600]);    
plot(wavelengths, spectral_decorrelations, 'r.');

% measure Corr(t)

wav = mono.set_wavelength(700)
PCOsrc.E2ExposureTime = 400;
pause(3)

time_speckle_evolution = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
while ishandle(time_speckle_evolution)
    time_stamps1 = [];
    video_data1 = [];

    t2 = 0;
        tic
        k = 1;
        while t2 < (time_stamps(1,end) + 2)
            pause(0.1)
            t2 = toc
            if t2 > time_stamps(1,k)
                data1 = getsnapshot(PCOvid);
                datac1 = data1((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
                time_stamps1 = [time_stamps1 toc];
                video_data1 = cat(3, video_data1, datac1);
                imagesc(datac1); daspect([1 1 1])
                colorbar
                drawnow
                pause(PCOexp/1000);
                if k < length(time_stamps)
                    k = k + 1;
                else
                    break
                end
            end
        end
        close(time_speckle_evolution)
end

% search for an available filename and save 
save(get_next_filename(root_folder, 'T-Butter') ,'video_data1','time_stamps1','wav','-v7.3');

time_decorrelations = [];

for idx = 1:size(time_stamps1,2)
    time_decorrelations = [time_decorrelations corr2(video_data1(:,:,1), video_data1(:,:,idx))];
end

figure('name', 'decorrelation in time');
time_stamps2 = time_stamps1-mean(time_stamps1-time_stamps); %assuming decorrelation depends on tau = t2 - t1
plot(time_stamps2(1:end), time_decorrelations, 'b.');

%deduce Corr(wav)

spectral_decorrelation_real = spectral_decorrelations./time_decorrelations;
figure('name', 'spectral decorrelation_real', 'position', [400, 200, 600, 600]);
plot(wavelengths, spectral_decorrelation_real, 'k.');

relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));
figure('name', 'relative contrast', 'position', [600, 200, 600, 600]);
plot(wavelengths, relative_contrast, 'g.');

figure()
plot(wavelengths,IIII,'.')
%% close all and clean
delete(mono);
imaqreset;
clear all

%% Just to go far in time without saving
% wav = mono.set_wavelength(700)
% pause(3)
% 
% time_stamps1 = [];
% video_data1 = [];
% figX = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
% t2 = 1;
%     tic
%     k = 1;
%     while ishandle(figX)
%         pause(0.3)
%         t2 = toc
% 
%             data1 = getsnapshot(PCOvid);
%             datac1 = data1((peak_posy-(peak_widthy)):(peak_posy+(peak_widthy)),(peak_posx-(peak_widthx)):(peak_posx+(peak_widthx)));
%             time_stamps1 = [time_stamps1 toc];
%             video_data1 = cat(3, video_data1, datac1);
%             imagesc(datac1);
%             drawnow
%             pause(PCOexp/1000);
%         end
%    
% 
% 
% 
% 
% time_decorrelations = [];
% 
% for idx = 1:size(time_stamps1,2)
%     time_decorrelations = [time_decorrelations corr2(video_data1(:,:,1), video_data1(:,:,idx))];
% end
% figure('name', 'decorrelation in time');
% 
% plot(time_stamps1(1:end), time_decorrelations, 'b.');