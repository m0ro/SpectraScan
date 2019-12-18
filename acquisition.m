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
%% perform the calibration
mono.start_calibration(530,700,0.1)    
%% live sream from upper camera
fig = figure('name', 'PCO.edge', 'position', [200, 200, 600, 600]);

while ishandle(fig),
    data = getsnapshot(PCOvid);
    imagesc(data);
    drawnow
end
%% go to a wavelegnth, show the speckle at the camera, and allow the selection of a ROI
wav = mono.set_wavelength(630);
disp(strcat('set to wavelength ', num2str(wav)));
pause(1)
data = getsnapshot(PCOvid);
figure();
imagesc(data);
h = imrect;
crop = round(h.getPosition);
frame_size = [crop(3),crop(4)];
crop(3:4) = crop(3:4)+crop(1:2);
imagesc(data(crop(2):crop(4),crop(1):crop(3)));

%% perfom the acquisition of speckles at different timestamps 
% must be donee to understand after which is the time window available to
% measure the spectral decorrelation
% here a fit with an exponential decay is performed and the decay time is
% measured




%% perfom the acquisition of speckles at different wavelenght
%  and record timestamps to correct for temporal decorrelation (to be
%  implemented)

video_data = []; 
for wavelength = 550:5:570
    wav = mono.set_wavelength(wavelength);
    disp(strcat('set to wavelength ', num2str(wav)));
    pause(0.5); % we must implement a way to wait until the servo ended the move
    data = getsnapshot(PCOvid);
    datac = data(crop(2):crop(4),crop(1):crop(3));
    video_data = cat(3, video_data, datac);
end

% search for an available filename and save 
save(get_next_filename(root_folder, 'wavelength_scan') ,'video_data','-v7.3');
%% close all and clean
delete(mono);
imaqreset;
clear all