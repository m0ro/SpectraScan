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
        %%%%%%%%%% those two parameters depends on the optical configuration
        min_servo_position = 6.70;
        max_servo_position = 12.40;
        %%%%%%%%%% this depend on the driver used (assumed to be a thorlabs
        %%%%%%%%%% dc servo motor
        servo_monochromator_serial = 83847443;
        
        integrationTime = 100000;
        spectral_lut = [];
        output_intensity = [];
        spectrometer;
        servo;
    end
    
    methods
        % it's neede to declare the construction function with all these
        % variables?
        function obj = monochromator()
            obj.spectrometer = spect();
            obj.servo = servo_thorlabs(obj.servo_monochromator_serial);
            % pause a little until the driver is ready`
            pause(5);
            % move to a kind of central position, where we hope to have
            % some signal
            obj.servo.move_abs(mean([obj.min_servo_position obj.max_servo_position]));
        end
        
        function delete(obj)
            delete(obj.servo);
            delete(obj.spectrometer);
        end
        
        function set_hw_parameters(wavelength,diffraction_order,...
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
            % or we should just measure it with the fit?
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

        function [peak_pos, peak_intensity, peak_width, off_set, rsquare] = search_peak(obj, wavelengths, spectrum) %store the peak position and intensity in a set...
            verbosity = false;
            [peak_intensity, argmax] = max(spectrum); % find the maximum value in the array
            peak_pos = wavelengths(argmax); %...and the corresponding wavelength

            [xData, yData] = prepareCurveData( wavelengths, spectrum );
            % Set up fittype and options.
            ft = fittype( 'a*exp(-((x-b)/c)^2)+d', 'independent', 'x', 'dependent', 'y' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
            opts.Display = 'Off';
            peak_width = 2;
            opts.StartPoint = [peak_intensity peak_pos peak_width mean(spectrum)];
            % Fit model to data.
            [fitresult, gof] = fit( xData, yData, ft, opts );

            peak_pos = fitresult.b;
            peak_intensity = fitresult.a;
            peak_width = fitresult.c;
            off_set = fitresult.d;
            rsquare = gof.rsquare;
            if verbosity                
                % Plot fit with data.
                figure( 'Name', 'fitting stuff' );
                h = plot( fitresult, xData, yData );
                legend( h, 'spec vs. wave', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
                % Label axes
                xlabel( 'wave', 'Interpreter', 'none' );
                ylabel( 'spec', 'Interpreter', 'none' );
                grid on
            end

        end

        function go_somewhere_in_the_middle(obj)
            obj.servo.move_abs(mean([obj.min_servo_position obj.max_servo_position]));
        end
        
        function exit_status = start_calibration(obj, start_wavelength, stop_wavelength, search_step)
            verbosity = false;

            obj.servo.move_abs(obj.min_servo_position); %I tell it to move in the minimum servo position I set at the beginning
            obj.spectrometer.setintegrationTime(obj.integrationTime);
            % search for starting point
            start_servo_position = 0;
            last_detected = false;
            pause(7); % must be checked. if not needed, remove; if needed, comment on why is needed
            for servo_pos = obj.min_servo_position:search_step:obj.max_servo_position %I do steps from the min to max pos
                if verbosity
                    disp(servo_pos); % I display it
                end
                obj.servo.move_abs(servo_pos); % I move absolutely to all position
                obj.spectrometer.acquirespectrum(); % and I acquire the spectrum
                obj.spectrometer.plot(); % diagnostica
                [peak_pos, peak_intensity, peak_width, off_set, rsquare] = obj.search_peak(obj.spectrometer.wavelengths, obj.spectrometer.spectralData); % I store it in a set
                if rsquare < 0.5
                    if verbosity
                        disp(rsquare);
                        disp('r too square low');
                    end
                    last_detected = false;
                    continue
                end
                if (0.6 > peak_width) && (peak_width > 5)
                    if verbosity
                        disp('bad width');
                    end
                    last_detected = false;
                    continue
                end

                if peak_pos < start_wavelength %but if I excede the start wavelength
                    last_detected = true;
                    continue
                end   

                if peak_pos > start_wavelength %but if I excede the start wavelength
                    if last_detected == true
                        disp('starting position detected!');
                        start_servo_position = servo_pos-search_step;
                        break
                    end
                    start_servo_position = 0;
                    disp('first detected peak over the nedeed start wavelength; stop calibration procedure.'); %I display it
                    break
                end

            end
            if start_servo_position == 0
                disp('something went wrong on guessing the initial position');
                disp('quitting calibration procedure...');
                go_somewhere_in_the_middle();
                exit_status = 1;
                return
            end
            % if everything went well now, go on with the calibration from
            % the starting point
            
            % go over the needed range and build the LUT which will be used
            % to calculate the relationship between position and wavelength
            obj.spectral_lut = [];
            obj.output_intensity = [];
            
            for servo_pos = start_servo_position:search_step:obj.max_servo_position
                obj.servo.move_abs(servo_pos);
                obj.spectrometer.acquirespectrum();
                [peak_pos, peak_intensity, peak_width, off_set, rsquare] = obj.search_peak(obj.spectrometer.wavelengths, obj.spectrometer.spectralData);
                if peak_pos > stop_wavelength
                    break
                end
                if (0.6 < peak_width) && (peak_width < 5)
                    if verbosity
                            disp('recording data');
                    end
                    obj.spectral_lut = [obj.spectral_lut; [servo_pos peak_pos]];
                    obj.output_intensity = [obj.output_intensity; [servo_pos peak_intensity]];
                end
            end
            % fit the LUT with a function
            % store the fitting function parameters
            disp('calibration ended successfully');
            exit_status = 0;
            return
        end

        function exit_status = show_spectra_live(obj) %exit status it's an object that appears and then disappears
            obj.spectrometer.setintegrationTime(obj.integrationTime); 
            previewfig = figure('Name','Spectrometer','NumberTitle','off', 'position', [300, 300, 800, 400]);
            while ishandle(previewfig), %while prefig is a object handle...  
                obj.spectrometer.acquirespectrum(); %...this acquire the spectrum
                [peak_pos, peak_intensity, peak_width, off_set, rsquare] = obj.search_peak(obj.spectrometer.wavelengths, obj.spectrometer.spectralData);
                stt = strcat(num2str(peak_pos), ' nm : ', num2str(peak_width), ' nm');
                xminn = min(obj.spectrometer.wavelengths)+20;
                yminn = max(obj.spectrometer.spectralData)-std(obj.spectrometer.spectralData);
                
                plot(obj.spectrometer.wavelengths, obj.spectrometer.spectralData);
                text(xminn, yminn, stt);
                
                title('Optical Spectrum');
                ylabel('Intensity (a.u.)');
                xlabel('\lambda (nm)');
                grid on
                axis tight
                pbaspect([1 1 1]); %...with an axis proportion 1:1
                drawnow %this thing limits the updates to 20 frames per second
            end
            exit_status = 0;
        end

        function spectral_lut = get_spectral_lut(obj)
            % return the lut
            spectral_lut = obj.spectral_lut; %I call the self.spectral_lut inside this file
        end
        
        function set_spectral_lut(obj, lut)
            % load a saved spectral lut
            obj.spectral_lut = lut;
        end

        function output_intensity = get_intensity(self)
            output_intensity = self.output_intensity;
        end

        function measured_wavength = set_wavelength(obj, wavelength, PID) %no matter if the variable has the same name as before because the last one ha already been closed
            if nargin < 3
                PID = 0;
            end
            servo_pos = obj.spectral_lut(:,1);
            wavelegths = obj.spectral_lut(:,2);

            [xData, yData] = prepareCurveData( servo_pos, wavelegths );
            ft = fittype( 'poly1' ); 
            [fitresult, gof] = fit( xData, yData, ft );
            needed_servo_pos = (wavelength - fitresult.p2)/fitresult.p1;
            obj.servo.move_abs(needed_servo_pos);
            
            obj.spectrometer.acquirespectrum();
            [peak_pos, peak_intensity, peak_width, off_set, rsquare] = ...
                obj.search_peak(obj.spectrometer.wavelengths, obj.spectrometer.spectralData);
            obj.wavelength = peak_pos;
            measured_wavength = obj.wavelength;
            % end the wavelength search if no extra precision is needed
            if PID == 0
                return
            end
            % if PID (
            % https://en.wikipedia.org/wiki/PID_controller
            % ) is set, the monochromator will try to get closer to the 
            % needed wavelentgh
            p = 0;
            i = 0;
            d = 0;
        end    


%         function [spectrum, wavelengths] = acquirespectrum(obj) %exit status it's an object that appears and then disappears
%             obj.spectrometer.setintegrationTime(obj.integrationTime);
%             obj.spectrometer.acquirespectrum(); %...this acquire the spectrum
%             spectrum = obj.spectrometer.spectralData;
%             wavelengths = obj.spectrometer.wavelengths;
%         end
    end
end  
