classdef spectrometer < handle
    % spectrometer
    % connect with a spectrometer and manage interfacing
    % works with OceanOptics/OceanInsight FLAME spectrometer, 
    % probably works with many other sppectrometer of the saame brand, as
    % the USB2000, USB4000, etc...
    % based on OceanOptics code (see ... for details)
    
    properties
        exposure_time
        average
    end
    
    methods
        % constructor
        function self = spectrometer()
        end
        
        % set exposure and average
        function set_exposure(self, exposure_time, average)
            self.exposure_time = exposure_time;
            self.average = average;
        end
        
        % acquire spectra
        function spectra = get_spectra(self)
            return 0;
        end
        
        % destructor: delete the handle
        function delete(self)
            % do what is needed to delete the used stuffs, and close the
            % connection with the hardware
        end
    end
    
end

