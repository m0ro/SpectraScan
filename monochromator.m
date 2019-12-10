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
        min_servo_position
        max_servo_position
        spectral_lut
        output_intensity
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
        
            function exit_status = start_calibration(obj, start_wavelength, stop_wavelength)
                %start_calibration has to be defined yet
                exit_status = 0;
            end
            
            function spectral_lut = get_spectral_lut(self) %I call the get funtion in other codes
                spectral_lut = self.spectral_lut; %I call the self.spectral_lut inside this file
            end
            
            function output_intensity = get_intensity(self)
                output_intensity = self.output_intensity;
            end
            
            function exit_status = set_wavelength(obj, obj.wavelength) %no matter if the variable has the same name as before because the last one ha already been closed
                exit_status = 0;
            end            
    end
end  
