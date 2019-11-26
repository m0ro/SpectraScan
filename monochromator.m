classdef monochromator < handle
    %MONOCHROMATOR Summary of this class goes here
    
    properties
        required_wavelength
    end
    
    properties (Access = private)
        min_servo_position
        max_servo_position
        spectral_lut
    end
    
    methods
        function self = monochromator()
        end
        
        function exit_status = start_calibration(self, start_wavelength, stop_wavelength)
            exit_status = 0;
        end
        
        function spectral_lut = get_spectral_lut(self)
            spectral_lut = self.spectral_lut;
        end
        
        function exit_status = set_wavelength(self, required_wavelength)
            exit_status = 0;
        end
    end
    
end

