classdef spect < handle %all types of spectrometers from OceanOptics
        
    properties 
        integrationTime
        
        average
        numOfSpectrometer
        spectrometerName
        spectrometerSerialNumber
    end
    
    properties (GetAccess = 'private', SetAccess = 'private')
        spectrometerObj; %which spectrometer
        spectrometerIndex = 0;
        channelIndex = 0;
        wavelengths
        spectralData
    end
    
    methods
        function obj = spect() 
            spectrometerObj = icdevice('OceanOptics_OmniDriver.mdd');
            connect(spectrometerObj);
            disp(spectrometerObj)
             
            obj.numOfSpectrometer = invoke(spectrometerObj, 'getNumberOfSpectrometersFound');
            %disp(['Found ' num2str(obj.numOfSpectrometer) ' Ocean Optics spectrometer(s).'])
            
            
            obj.spectrometerName = invoke(spectrometerObj,'getName',obj.spectrometerIndex);
            %disp(['Model Name : ' obj.spectrometerName])
            
            
            obj.spectrometerSerialNumber = invoke(spectrometerObj,'getSerialNumber',obj.spectrometerIndex);
            %disp(['Model S/N  : ' obj.spectrometerSerialNumber])
            
            obj.integrationTime = invoke(spectrometerObj, 'getIntegrationTime', obj.spectrometerIndex, obj.channelIndex, obj.integrationTime);
            
            obj.wavelengths = invoke(spectrometerObj, 'getWavelengths', obj.spectrometerIndex, obj.channelIndex);
            %[obj.wavelengths] = obj.wavelengths;
            
            
            obj.spectralData = invoke(spectrometerObj, 'getSpectrum', obj.spectrometerIndex);
            %[obj.spectralData] = obj.spectralData;

            plot(obj.wavelengths, obj.spectralData);
            title('Optical Spectrum');
            ylabel('Intensity (counts)');
            xlabel('\lambda (nm)');
            grid on
            axis tight
        end
    end
end
