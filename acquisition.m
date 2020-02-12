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
PCOexp = 400;
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
%% camera preview
PCOsrc.E2ExposureTime = 200;
preview(PCOvid);
%% camera picture
PCOsrc.E2ExposureTime = 2000;
data = getsnapshot(PCOvid);
figure();
imagesc(data);
%% perform the calibration
mono.start_calibration(480,700,0.05);
%% plot peak intensity of the laser over the wavelength readed by spectrometer
figure()
plot(mono.output_intensity(:,1),mono.output_intensity(:,2))
% Iout = mono.output_intensity(:,2); %% seems that this variable is not
% used after. if so, remove
%% move the sample to study different regions
PCOsrc.E2ExposureTime = 400;
pause(0.5)
sample_explorer_fig = figure();
% set a good wavelength where the SNR at the camera is higher
% (compromise between the laser power, the scattering/adsorption of the
% sample, and the QE of the camera)
wav = mono.set_wavelength(500); % must be measured

while ishandle(sample_explorer_fig)
    %imagesc(getsnapshot(PCOvid)); daspect([1 1 1])
    colorbar
pause(0.01)
    datatry = getsnapshot(PCOvid);
    
    % take a1d gaussian fit for the two axis
    % ( can be implemented with a single 2d gaussian)
    
    % first axis
    % equivalent to mean(datatry,1)
    Iy =[];
    pause(0.05)
    for i = 1:size(datatry,1)
        Iy = [Iy mean(datatry(i,:))];
    end

    % fit the background gaussian to find the central part of the speckles
    [peak_intensityy, argmaxy] = max(Iy);
    peak_posy = argmaxy;
    [xDatay, yDatay] = prepareCurveData( 1:size(datatry,1), Iy );
    fty = fittype( 'a2*exp(-0.5*((x-b2)/c2)^2)+d2', 'independent', 'x', 'dependent', 'y' );
    optsy = fitoptions( 'Method', 'NonlinearLeastSquares' );
    optsy.Display = 'Off';
    
    peak_widthy = 500; % must be estimate automatically
    optsy.StartPoint = [peak_intensityy peak_posy peak_widthy 100];
    [fitresulty, gof] = fit( xDatay, yDatay, fty, optsy );
    peak_posy = fitresulty.b2;
    peak_intensityy = fitresulty.a2;
    peak_widthy = 2.35482*abs(fitresulty.c2);
    off_sety = fitresulty.d2;

    % second axis
    %equivalent to mean(datatry,2)
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
    % end of the fit
    
    %datacropped = datatry((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
    %databackground = datatry((1:size(datacropped,1)),(1:size(datacropped,2)));
    pause(0.05)
    imagesc(datatry); daspect([1 1 1])
    colorbar
    %contrasts = std2(datacropped)/mean2(datacropped)
 end
%% go to a wavelength, show the speckle at the camera, and allow the selection of a ROI
% same as the section before, but without live stream and with data storage (the
% two section can be merged)
wav = mono.set_wavelength(700)
pause(2)
fprintf('set to wavelength %.1f\n', wav);
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
datac = (data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2))-(off_setx+off_sety)/2);
figure()
imagesc(datac);

%% measure the speckles at every step

% define a variable which set or not the intensity/esxposure correction
% (eventually, could be set all to the max exposure)
% or better: smaller steps in the spectral window where time decorr doesn't
% change

% measure the intensity at different wavelentghs in order to try to obtain always similar SNRs
min_exposure = 100;
max_exposure = 2000;
% measure the Corr(wav,t) and contrast
PCOsrc.E2ExposureTime = min_exposure;
wavestart = 490;
wavestop = 700;
wavestep = 2;

wavelength_speckle_evolution_fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
while ishandle(wavelength_speckle_evolution_fig)
    video_data = []; 
    time_stamps = [];
    
    normalized_intensities = [];
    transmitted_light = [];
    
    I = [];
    II = [];
    III = [];
    
    for wavelength = wavestart:wavestep:wavestop
        wav = mono.set_wavelength(wavelength);
        fprintf('set to wavelength %.1f\n', wav);
        pause(1)
        data = getsnapshot(PCOvid);
        datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2))-(off_setx+off_sety)/2;
        spp = speckle_processing(size(datac));
        spp.prepare_donut();
        datac = spp.apply_donut(datac);
        imagesc(datac); daspect([1 1 1])
        colorbar
        drawnow
        
        I = [I mean2(datac)];
        II = [II mono.peak_intensity];
        III = [III mono.peak_intensity/mean2(datac)];
        normalized_intensities = [normalized_intensities mean2(datac)/mono.peak_intensity];
        transmitted_light = [transmitted_light mean2(datac)];
    end

close(wavelength_speckle_evolution_fig)
end
%% 
min_exposure = 100;
max_exposure = 2000;
% measure the Corr(wav,t) and contrast
PCOsrc.E2ExposureTime = min_exposure;
wavestart = 490;
wavestop = 700;
wavestep = 2;

wavelength_speckle_evolution_fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
while ishandle(wavelength_speckle_evolution_fig)
    % IIII � l'intensit� alla camera al secondo ciclo, quando cambio il tempo di esposizione
    %   � quella che vorrei avere costante per ogni lambda cambiando il rapporto alla riga 185
    wavelengths = [];
    expo_vector = [];
    video_data = []; 
    time_stamps = [];
    IIII = [];
    k = 1;
    % the dark frame neab value could be estimated taking the average of
    % the pixels outside the 3 sigma of the gaussian, as estimanted in the
    % previous block
%     dark_frame_mean = 100;
    
    tic
    for wavelength = wavestart:wavestep:wavestop
        wav = mono.set_wavelength(wavelength);
        pause(0.2)
        fprintf('set to wavelength %.1f\n', wav);
%         tmp_exp = min_exposure*(max(normalized_intensities)/normalized_intensities(k));
        tmp_exp = min_exposure*max(transmitted_light)/(transmitted_light(k));
        if (tmp_exp > max_exposure)
            disp("max exposure reached, set to 2000ms");
            tmp_exp = max_exposure;
        end
        k = k + 1;
%         PCOsrc.E2ExposureTime = min_exposure.*(max(I)./I(k));
        PCOsrc.E2ExposureTime = tmp_exp;
        % keep track of exposures used
        expo_vector = [expo_vector tmp_exp];
        fprintf('exposure time %.1f\n', PCOsrc.E2ExposureTime);
        data = getsnapshot(PCOvid);
        %pause(tmp_exp/1000);
        datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2))-(off_setx+off_sety)/2;
        time_stamps = [time_stamps toc];
        spp = speckle_processing(size(datac));
        spp.prepare_donut();
        data_filtered = spp.apply_donut(datac);
        video_data = cat(3, video_data, datac);
        wavelengths = [wavelengths wav];
        IIII = [IIII mean2(datac)];
        
        imagesc(datac); daspect([1 1 1])
        colorbar
        drawnow

    end
    close(wavelength_speckle_evolution_fig)
end

% search for an available filename and save 
save(get_next_filename(root_folder, 'W-Brain') ,...
    'video_data','time_stamps','wavelengths','-v7.3');

decorrelations = [];
contrasts = [];

for idx = 1:size(wavestart:wavestep:wavestop,2)
    decorrelations = [decorrelations corr2(video_data(:,:,1), video_data(:,:,idx))];
%     Inorm = mean2(video_data(:,:,idx))./II(idx);
    contrasts = [contrasts std2(video_data(:,:,idx)./mean2(video_data(:,:,idx)))];
end

figure('name', 'decorrelation', 'position', [400, 200, 600, 600]);    
plot(wavelengths, decorrelations, 'r.');


%% measure Corr(t)
wav = mono.set_wavelength(700)
PCOsrc.E2ExposureTime = min_exposure;
pause(3)

time_speckle_evolution = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
while ishandle(time_speckle_evolution)
    time_stamps1 = [];
    video_data1 = [];

    t2 = 0;
        tic
        k = 1;
        while t2 < (time_stamps(1,end) + 2)
            %pause(0.001)
            t2 = toc
            if t2 > time_stamps(1,k)
                data1 = getsnapshot(PCOvid);
                datac1 = data1((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2))-(off_setx+off_sety)/2;
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
% "butter 'cause we like it, even if is not butter anymore
save(get_next_filename(root_folder, 'T-brain') ,...
    'video_data1','time_stamps1','wav','-v7.3');

time_decorrelations = [];

for idx = 1:size(time_stamps1,2)
    time_decorrelations = [time_decorrelations corr2(video_data1(:,:,1), video_data1(:,:,idx))];
end

figure('name', 'decorrelation in time');
time_stamps2 = time_stamps1-mean(time_stamps1-time_stamps); %assuming decorrelation depends on tau = t2 - t1
plot(time_stamps2(1:end), time_decorrelations, 'b');

%deduce Corr(wav)

spectral_decorrelation_real = decorrelations./time_decorrelations;
figure('name', 'spectral decorrelation_real', 'position', [400, 200, 600, 600]);
plot(wavelengths, spectral_decorrelation_real, 'k');

relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));
figure('name', 'relative contrast', 'position', [600, 200, 600, 600]);
plot(wavelengths, relative_contrast, 'g');

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