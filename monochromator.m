classdef monochromator < handle
    
    properties (Dependent)
        bandwidth
        ideal_exit_slit
    end
    
    properties
        wavelength
    end
    
    properties (Hidden)
        diffraction_order = 1
        grooves_density
        entrance_arm
        exit_arm
        entrance_slit
        exit_slit
        angle_between_rays
%         entrance_angle
%         exit_angle
    end
    
    properties (Access = private)
        min_servo_position = 0;
        max_servo_position = 25;
        spectral_lut = [];
        output_intensity = [];
    end
    
    methods
        function obj = monochromator(wavelength,diffraction_order,...
                grooves_density,entrance_arm,exit_arm,entrance_slit,...
                exit_slit,angle_between_rays)
            if nargin > 0
                obj.wavelength = wavelength;
                obj.diffraction_order = diffraction_order;
                obj.grooves_density = grooves_density;
                obj.entrance_arm = entrance_arm;
                obj.exit_arm = exit_arm;
                obj.entrance_slit = entrance_slit;
                obj.exit_slit = exit_slit;
                obj.angle_between_rays = angle_between_rays;
            end
        end
             
            function bandwidth = get.bandwidth(obj)
                bandwidth = obj.exit_slit.*(cos(asin((obj.diffraction_order.*obj.grooves_density.*obj.wavelength.*10^(-6))./(2.*cos(obj.angle_between_rays/2)))-obj.angle_between_rays/2).*obj.exit_arm)./(cos(obj.angle_between_rays + asin((obj.diffraction_order.*obj.grooves_density.*obj.wavelength.*10^(-6))./(2.*cos(obj.angle_between_rays/2)))-obj.angle_between_rays/2).*obj.entrance_arm).*(cos(obj.angle_between_rays + asin((obj.diffraction_order.*obj.grooves_density.*obj.wavelength.*10^(-6))./(2.*cos(obj.angle_between_rays/2)))-obj.angle_between_rays/2).*10^6)./(obj.diffraction_order.*obj.grooves_density.*obj.exit_arm);
            end
            
            function ideal_exit_slit = get.ideal_exit_slit(obj)
                ideal_exit_slit = obj.entrance_slit.*(cos(asin((obj.diffraction_order.*obj.grooves_density.*obj.wavelength.*10^(-6))./(2.*cos(obj.angle_between_rays/2)))-obj.angle_between_rays/2).*obj.exit_arm)./(cos(obj.angle_between_rays + asin((obj.diffraction_order.*obj.grooves_density.*obj.wavelength.*10^(-6))./(2.*cos(obj.angle_between_rays/2)))-obj.angle_between_rays/2).*obj.entrance_arm);
            end
            
            function surf(obj,varargin)
                [obj.wavelength,obj.angle_between_rays] = meshgrid(obj.wavelength,obj.angle_between_rays);
                surf(obj.wavelength,obj.angle_between_rays,obj.bandwidth,varargin{:})
                title(['bandwidth/wavelength/angle_between_rays'])
                xlabel('wavelength(nm)')
                ylabel('angle_between_rays(rad))')
                zlabel('bandwidth(nm)')
            end
            
            function [peak_pos, peak_intensity] = search_peak(obj, wavelenghts, spectrum) %store the peak position and intensity in a set...
                [peak_intensity, argmax] = max(spectrum); %...and find the maximum value...
                peak_pos = wavelenghts(argmax); %...and the corresponding wavelength
            end
            
            function exit_status = show_spectra_live(obj) %exit status it's an object that appears and then disappears
                spectrometer = spect(); %here I call the class spect and name the obj as spectrometer
                spectrometer.setintegrationTime(500000);
                previewfig = figure('Name','preview','NumberTitle','off', 'position', [300, 300, 800, 400]);
                while ishandle(previewfig), %while prefig is a object handle...  
                    spectrometer.acquirespectrum(); %...this acquire the spectrum
                    spectrometer.plot(); %...and plot it...
                    pbaspect([1 1 1]); %...with an axis proportion 1:1
                    drawnow %this thing limits the updates to 20 frames per second
                end
                exit_status = 0;
            end
        
            function exit_status = start_calibration(obj, start_wavelength, stop_wavelength)
                search_step = 0.1; %the step it will do to look for the starting wavelength
                servo_monochromator_serial = 83847443;
                servo = servo_thorlabs(servo_monochromator_serial); %I call the servo_thorlabs for the first time and name the obj as servo
                servo.move_abs(obj.min_servo_position); %I tell it to move in the minimum servo position I set at the beginning
                spectrometer = spect(); % I call the spectrometer
                % search for starting point
                for servo_pos = obj.min_servo_position:search_step:obj.max_servo_position %I do steps from the min to max pos
                    disp(servo_pos); % I display it
                    servo.move_abs(servo_pos); % I move absolutely to all position
                    spectrometer.acquirespectrum(); % and I acquire the spectrum
                    spectrometer.plot(); % diagnostica
                    [peak_pos, ~] = obj.search_peak(spectrometer.wavelengths, spectrometer.spectralData); % I store it in a set
%                     if peak_pos > start_wavelength %but if I excede the start wavelength
%                         disp('peak over the max; stop calibratio procedure.'); %I display it
                        start_servo_position = servo_pos-search_step; %and I go one step back
%                         break
%                     end
                end
                % verify if the point will be taken are enough for the fit,
                % if not, refine the step
                % go over the needed range and build the LUT
                obj.spectral_lut = [];
                for servo_pos = start_servo_position:search_step:obj.max_servo_position
                    servo.move_abs(servo_pos); %------------------------------------------------------shouldn't move_rel be used?
                    spectrometer.acquirespectrum();
                    [peak_pos, peak_intensity] = obj.search_peak(spectrometer.wavelengths, spectrometer.spectralData);
                    if peak_pos > stop_wavelength
                        break
                    end
                    obj.spectral_lut = [obj.spectral_lut [servo_pos peak_pos]];
                    obj.output_intensity = [obj.output_intensity [servo_pos peak_intensity]];
                end
                % fit the LUT with a function
                % store the fitting function parameters
                
                % clean
                delete(servo);
                delete(spectrometer);
                exit_status = 1;
            end
            
            function spectral_lut = get_spectral_lut(self) %I call the get funtion in other codes
                spectral_lut = self.spectral_lut; %I call the self.spectral_lut inside this file
            end
            
            function output_intensity = get_intensity(self)
                output_intensity = self.output_intensity;
            end
            
            function exit_status = set_wavelength(obj,wavelength) %no matter if the variable has the same name as before because the last one ha already been closed
                exit_status = 1;
            end            
    end
end  
