%% create a folder for the current day
root_folder = strcat('D:\Users\Comedia\melo\',datestr(now,'ddmmyyyy'),'\');
[status, msg, msgID] = mkdir(root_folder);
disp(msg);
% add the path of the project
addpath('D:\Users\Comedia\moro\git_code\SpectraScan\');
sample_name = 'ChickenAfterPSFandIntensityimprovementChangingExposure';
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
%% camera preview (to see if we are on the sample)
PCOsrc.E2ExposureTime = 400;
preview(PCOvid);
%% Show spectrum to help calibration procedure
% mono.spectrometer.setintegrationTime(100000)
mono.integrationTime = 10000;
mono.show_spectra_live();
%% perform the calibration
mono.start_calibration(480,700,0.1)    
%% Intensity distribution seen by the spectrometer (should follow the profile of the supercontinuum)
Intensity_distribution_out_ot_the_spectrometer = figure();
plot(mono.output_intensity(:,1),mono.output_intensity(:,2),'o-');
%% show the speckle with continuos update to allow user to select the proper region

PCOsrc.E2ExposureTime = 100;
sample_explorer_fig = figure();
wav = mono.set_wavelength(700); %set a good wavelength that allows a good compromise between SNR
                               %on the camera, output intensity on the
                               %supercontinuum and properties of the medium
                               %that can affect the pattern

while ishandle(sample_explorer_fig)
    pause(0.01)
      datatry = getsnapshot(PCOvid);
      Iy =[];
      pause(0.05)
      
      %now I do a fit on the intensity distribution on x and y axis of
      %datatry in order to have a cropped region and a preview of the
      %contrast in that region. A 2d fancy fit can also be implemented.
      
      % first axis
      
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
        peak_widthy = 500;
        optsy.StartPoint = [peak_intensityy peak_posy peak_widthy 100];
        [fitresulty, gof] = fit( xDatay, yDatay, fty, optsy );

        
        peak_posy = fitresulty.b2;
        peak_intensityy = fitresulty.a2;
        peak_widthy = 2.35482*abs(fitresulty.c2);
        off_sety = fitresulty.d2;

        %second axis
        
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
        %end of the fit
        
        datacropped = datatry((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2))-(off_setx+off_sety)/2;
        pause(0.05)
        imagesc(datatry); daspect([1 1 1])
        colorbar
        
        %this last line can eventually crash if the intensity is too low
        %and the fit result is bad, comment if needed
        
        contrasts =  std2(datacropped)/mean(mean(datacropped))
 end
%% go to a chosen wavelength and automatically select the ROI

%same as before but now we see the cropped region, we select this ROI and
%we preview it as it will be used in the entire code. This section can be
%actually merged with the previous one but helped me a lot of time to work
%separately.

% fit 2d gaussian code adapted from:
% https://fr.mathworks.com/matlabcentral/fileexchange/37087-fit-2d-gaussian-function-to-data

wav = mono.set_wavelength(700);
fprintf('set to wavelength %.1f\n', wav);
pause(2)
data = getsnapshot(PCOvid);
figure();
imagesc(data);
pause(0.2)

%%% new code
% subsampling = 20;
% [rows, columns] = size(data);
% numOutputRows = round(rows/subsampling);
% numOutputColumns = round(columns/subsampling);
% subdata = imresize(data, [numOutputRows, numOutputColumns]);
% 
% %Inital guess parameters: amplitude, x0, y0, sigma, offset
% [ys, xs] = size(subdata);
% x0 = double([max(subdata(:))-min(subdata(:)),...
%     sum(mean(subdata,1)*1:xs)/xs, ...
%     sum(mean(subdata,1)*1:ys)/ys, ...
%     xs/2, min(subdata(:))]); 
% 
% 
% [X,Y] = meshgrid(1:xs, 1:ys);
% xdata = zeros(size(X,1),size(Y,2),2);
% xdata(:,:,1) = X; xdata(:,:,2) = Y;
% [p,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction, x0, xdata, double(subdata));

%%% end new code

%first axis

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

%second axis

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
%end of the fit


% datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2))-(off_setx+off_sety)/2;
% remove the offset gives not correct contrast!
% peak_posx = int16(p(2)*subsampling);
% peak_posy = int16(p(3)*subsampling);
% peak_width =int16(abs(p(4)*subsampling));

datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),...
             (peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
figure()
imagesc(datac);
%% acquisition of speckles at different wavelength and timestamps + correction

%measure the Corr(wav,t) and contrast

<<<<<<< HEAD
PCOsrc.E2ExposureTime = 200;
wavestart = 460;
=======
PCOsrc.E2ExposureTime = 100;
wavestart = 490;
>>>>>>> master
wavestop = 700;
wavestep = 2;


wavelength_speckle_evolution_fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);

while ishandle(wavelength_speckle_evolution_fig)

    %this following cycle is used just to store the profile of the
    %intensity at the camera, it's given by the
    %spectrum of the supercontinuum and by the properties of the scattering
    %medium.
    
%     transmitted_light = [];
% 
%     for wavelength = wavestart:wavestep:wavestop
%         wav = mono.set_wavelength(wavelength);
%         fprintf('set to wavelength %.1f\n', wav);
%         pause(0.5)
%         data = getsnapshot(PCOvid);
% 
%         datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),...
%              (peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
%         transmitted_light = [transmitted_light mean2(datac)];
%     end
%     plot(transmitted_light)
    
    %if there's an intensity unbalance, the following cycle tries to
    %compensate changing the exposure time for each frame, setting the
    %intensity to the maximum one. This should also maximaze the SNR and
    %kill shot noise.
    
    min_exposure = 100;
    max_exposure = 2000;
    PCOsrc.E2ExposureTime = min_exposure;
    
    %variables to be stored
    
    video_data_D = []; 
    time_stamps_D = [];
    wavelengths = [];
    exposure_times_vector = []; %tracking of the exposure times
    transmitted_light_after_correction = [];
    k = 1;

    tic
    for wavelength = wavestart:wavestep:wavestop
        wav = mono.set_wavelength(wavelength);
        fprintf('set to wavelength %.1f\n', wav);
%         tmp_exp = min_exposure*max(transmitted_light)/(transmitted_light(k));
%         if (tmp_exp > max_exposure)
%             disp("max exposure reached, set to 2000ms");
%             tmp_exp = max_exposure;
%         end
%         
%         PCOsrc.E2ExposureTime = tmp_exp;
%         exposure_times_vector = [exposure_times_vector tmp_exp];
%         fprintf('exposure time %.1f\n', PCOsrc.E2ExposureTime);
        data = getsnapshot(PCOvid);

        datac = data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),...
             (peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
        time_stamps_D = [time_stamps_D toc];
        
        spp = speckle_processing(size(datac)); % applying a filter on the 
                                               %image just for a better
                                               %visualization...not applied
                                               %on the stored data.
        spp.prepare_donut();
        data_filtered = spp.apply_donut(datac);
        
        video_data_D = cat(3, video_data_D, datac);
        wavelengths = [wavelengths wav];
        transmitted_light_after_correction = [transmitted_light_after_correction mean2(datac)];
        
        imagesc(datac); daspect([1 1 1])
        colorbar
        drawnow
        
        pause(min_exposure/1000);
        k = k + 1;
    end
    close(wavelength_speckle_evolution_fig)
end


decorrelation = [];
contrasts = [];

for idx = 1:size(wavestart:wavestep:wavestop,2)
    decorrelation = [decorrelation corr2(video_data_D(:,:,1), video_data_D(:,:,idx))];
    contrasts = [contrasts std2(video_data_D(:,:,idx)./mean2(video_data_D(:,:,idx)))];
end
relative_contrast = (contrasts - mean(contrasts).*ones(1,length(contrasts)))./(mean(contrasts));

% search for an available filename and save 
save(get_next_filename(root_folder, strcat('W-',sample_name)) ,...
    'video_data_D','time_stamps_D','wavelengths',...
    'wavestart','wavestep','wavestop','exposure_times_vector','decorrelation',...
    'relative_contrast','-v7.3');

figure('name', 'decorrelation');    
plot(wavelengths, decorrelation, 'r.-');

figure('name', 'relative contrast');
plot(wavelengths, relative_contrast, 'm.-');

%% measure Corr(t)

%we set a good wavelength in order to avoid shot noise (so the last one is
%fine) and also to have a good 

wav = mono.set_wavelength(700)
PCOsrc.E2ExposureTime = min_exposure;
pause(3)

time_speckle_evolution_fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);
while ishandle(time_speckle_evolution_fig)
    
    time_stamps_TD = [];
    video_data_TD = [];

    t2 = 0;
        tic
        k = 1;
        while t2 < (time_stamps_D(1,end) + 2)
            pause(0.1)
            t2 = toc
            if t2 > time_stamps_D(1,k)
                dataTD = getsnapshot(PCOvid);
                
                datacTD = dataTD((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),...
                    (peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
                time_stamps_TD = [time_stamps_TD toc];
                video_data_TD = cat(3, video_data_TD, datacTD);
                imagesc(datacTD); daspect([1 1 1])
                colorbar
                drawnow
                pause(min_exposure/1000);
                if k < length(time_stamps_D)
                    k = k + 1;
                else
                    break
                end
            end
        end
        close(time_speckle_evolution_fig)
end


time_decorrelations = [];

for idx = 1:size(time_stamps_TD,2)
    time_decorrelations = [time_decorrelations corr2(video_data_TD(:,:,1), video_data_TD(:,:,idx))];
end

% search for an available filename and save 
save(get_next_filename(root_folder,strcat('T-', sample_name)) ,'video_data_TD','time_stamps_TD','time_decorrelations','wav','-v7.3');

%I shift the time instant to match or at least be close to the initial one
%of the Corr(wav,t) measurement

figure('name', 'decorrelation in time');
time_stamps_TDshifted = time_stamps_TD-mean(time_stamps_TD-time_stamps_D); %assuming decorrelation depends on tau = t2 - t1
plot(time_stamps_TD, time_decorrelations, 'b.-');

%% deduce Corr(wav)

spectral_decorrelation = decorrelation./time_decorrelations;
figure('name', 'spectral decorrelation');
plot(wavelengths, spectral_decorrelation, 'k.-');

figure()
plot(wavelengths,transmitted_light_after_correction,'.-')

%% Simple temporal decorrelation (not at fixed instants)
%Even this part of the code can be merged with the previous one just making
%an if loop and a trigger that decide the path if it's on or off. The idea
%here is to measure just temporal decorrelation without fixing
%instants. This part cannot be used to estract the spectral decorrelation
%if I doesn't select the right time instant.




    
    wav = mono.set_wavelength(700)
    PCOsrc.E2ExposureTime = min_exposure;
    pause(3)

    free_time_stamps = [];
    free_video_data = [];

    temporal_decorrelation_free = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);

    tic
    while ishandle(temporal_decorrelation_free)
        pause(0.3)

        free_data = getsnapshot(PCOvid);
        free_datac = free_data((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),(peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2));
        free_time_stamps = [free_time_stamps toc];
        free_video_data = cat(3, free_video_data, free_datac);
        imagesc(free_datac);
        drawnow
        pause(min_exposure/1000);
        if toc > 120
            break
        end
     end

    free_time_decorrelations = [];

    for idx = 1:size(free_time_stamps,2)
        free_time_decorrelations = [free_time_decorrelations corr2(free_video_data(:,:,1), free_video_data(:,:,idx))];
    end
    figure()
    plot(free_time_stamps(1:end), free_time_decorrelations, 'b.-');
    hold on
    
    free_time_decorrelations_set = [];
    free_time_decorrelations_set = [free_time_decorrelations_set; free_time_decorrelations]

% search for an available filename and save 
save(get_next_filename(root_folder,strcat('T_free-',sample_name)) ,'free_video_data',...
    'free_time_stamps','free_time_decorrelations','wav','-v7.3');

%% close all and clean
delete(mono);
imaqreset;
clear all