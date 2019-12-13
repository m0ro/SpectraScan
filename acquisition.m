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
%% show the spectrum to help alignemeent of the system
mono.show_spectra_live();
%% perform the calibration
mono.start_calibration(520,700,0.1);
%% go to a wavelegnth, show the speckle at the camera, and allow the selection of a ROI
wav = mono.set_wavelength(550);
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

%% perfom the acquisition of speckles at different wavelenght
video_data = []; 
for wavelength = 550:5:570
    wav = mono.set_wavelength(wavelength);
    disp(strcat('set to wavelength ', num2str(wav)));
    pause(0.5); % we must implement a way to wait until the servo ended the move
    data = getsnapshot(PCOvid);
    datac = data(crop(2):crop(4),crop(1):crop(3));
    video_data = cat(3, video_data, datac);
end

% search for an available filename
for ii = 1:1000
    tmpst = strcat(root_folder,'data_',datestr(now,'ddmmyyyy'),'_',sprintf('%03d',ii) ,'.mat');
    if (exist(tmpst, 'file')~=2)
%         tiff_file = tmpst;
        video_mat_file = tmpst;
        break;
    end
end
if ii==1000
    error('please, empty %s',root_folder);
end

% save 
save(video_mat_file,'video_data','-v7.3');

%% perfom the acquisition of speckles at different timestamps 

%% close all and clean
delete(mono);
imaqreset;
clear all