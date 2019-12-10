classdef spect < handle %all types of spectrometers from OceanOptics
        
    properties
        integrationTime
    end
    
    properties (GetAccess = 'public', SetAccess = 'private')
        numOfSpectrometer
        spectrometerName
        spectrometerSerialNumber
        wavelengths
        spectralData
        average
    end
    
    properties (GetAccess = 'private', SetAccess = 'private')
        spectrometerObj; %which spectrometer
        spectrometerIndex = 0;
        channelIndex = 0;
    end
    
    methods
        function obj = spect() 
            obj.spectrometerObj = icdevice('OceanOptics_OmniDriver.mdd');
            connect(obj.spectrometerObj);
            disp(obj.spectrometerObj)
             
            obj.numOfSpectrometer = invoke(obj.spectrometerObj, 'getNumberOfSpectrometersFound');
            %disp(['Found ' num2str(obj.numOfSpectrometer) ' Ocean Optics spectrometer(s).'])

            obj.spectrometerName = invoke(obj.spectrometerObj,'getName',obj.spectrometerIndex);
            %disp(['Model Name : ' obj.spectrometerName])
            
            obj.spectrometerSerialNumber = invoke(obj.spectrometerObj,'getSerialNumber',obj.spectrometerIndex);
            %disp(['Model S/N  : ' obj.spectrometerSerialNumber])
            
            obj.integrationTime = invoke(obj.spectrometerObj, 'getIntegrationTime', obj.spectrometerIndex, obj.channelIndex, obj.integrationTime);
%             obj.integrationTime = invoke(obj.spectrometerObj, 'setIntegrationTime', obj.spectrometerIndex, obj.channelIndex, obj.integrationTime);
            
            obj.wavelengths = invoke(obj.spectrometerObj, 'getWavelengths', obj.spectrometerIndex, obj.channelIndex);
            %[obj.wavelengths] = obj.wavelengths;

            obj.spectralData = invoke(obj.spectrometerObj, 'getSpectrum', obj.spectrometerIndex);
            %[obj.spectralData] = obj.spectralData;
            
        end


        function plot(obj)
                 plot(obj.wavelengths, obj.spectralData);
                 title('Optical Spectrum');
                 ylabel('Intensity (counts)');
                 xlabel('\lambda (nm)');
                 grid on
                 axis tight
        end
        
        function setintegrationTime(obj, newintegrationTime)
            if newintegrationTime > 0
                obj.integrationTime = newintegrationTime;
                invoke(obj.spectrometerObj, 'setIntegrationTime', obj.spectrometerIndex, obj.channelIndex, obj.integrationTime);
            else
                error('integrationTime must be positive')
            end
        end
        
        function acquirespectrum(obj)
            obj.wavelengths = invoke(obj.spectrometerObj, 'getWavelengths', obj.spectrometerIndex, obj.channelIndex)
            obj.spectralData = invoke(obj.spectrometerObj, 'getSpectrum', obj.spectrometerIndex);
        end
        
        function delete(obj)
            disconnect(obj.spectrometerObj);
            delete (obj.spectrometerObj);
        end
        
    end

        
end