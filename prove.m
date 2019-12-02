stage_y = servo_thorlabs(83843405);
% servo_monochromator = servo_thorlabs(83847443);
%%
spectrometer = spectrometer();
%%
stage_y.move_abs(0);
%%
delete(stage_y);