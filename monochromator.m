classdef monochromator < handle
    %MONOCHROMATOR Summary of this class goes here
    
    properties
        required_wavelength
    end
    
    properties (Access = private)
        min_servo_position %I scan for a given interval to find the correct lambda I ask for
        max_servo_position
        spectral_lut %lookuptable
        spectral_lut
        output_intensity
    end
    
    methods
        function self = monochromator()
        end
        
        function exit_status = start_calibration(self, start_wavelength, stop_wavelength)
            %start_calibration has to be defined yet
            exit_status = 0;
        end
        
<<<<<<< Updated upstream
        function spectral_lut = get_spectral_lut(self) %I call the get funtion in other codes
            spectral_lut = self.spectral_lut; %I call the self.spectral_lut inside this file
=======
>>>>>>> Stashed changes
        function output_intensity = get_intensity(self)
            output_intensity = self.output_intensity;
        end
        
        function spectral_lut = get_spectral_lut(self)
            spectral_lut = self.spectral_lut;
        end
        
        function exit_status = set_wavelength(self, required_wavelength) %no matter if the variable has the same name as before because the last one ha already been closed
            exit_status = 0;
        end
    end
    
end

