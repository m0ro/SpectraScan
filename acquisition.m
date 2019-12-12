root_folder = strcat('D:\Users\Comedia\moro\',datestr(now,'ddmmyyyy'),'\');
[status, msg, msgID] = mkdir(root_folder);
disp(msg);

%%
mono = monochromator();
%%
mono.show_spectra_live();
%%
mono.start_calibration(530,700,0.1);
%%
wav = mono.set_wavelength(544)

%%
