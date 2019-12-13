classdef servo_thorlabs < handle
    % manage servos from thorlabs
    % use the APT GUI https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0
    % https://www.thorlabs.com/Software/Motion%20Control/APT_Communications_Protocol.pdf
    

    properties% (Access = private)
        position
        servofig
        servo
        precision = 0.001
    end

    methods
        % constructor
        function obj = servo_thorlabs(serial_n)
            % should be cool to hide the window from the user
            % global servo; % make servo a global variable so it can be used outside the main
            obj.servofig = figure('Name','ThorlabsServo','Position', [0 50 300 150],'Menu','None','Name','APT GUI');
            % Create ActiveX Controller
            obj.servo = actxcontrol('MGMOTOR.MGMotorCtrl.1',[0 0 300 150], obj.servofig);
            % Initialize
            % Start Control
            obj.servo.StartCtrl;
            % Set the Serial Number
            % serial_n = 83843398;
            % serial_n = 83847443; % serial from the monocromator servo controller
            set(obj.servo, 'HWSerialNum', serial_n);
            % Indentify the device
            obj.servo.Identify;
            pause(0.5); 
            obj.servo.MoveAbsolute(0,false);  
        end
        
        % move with absolute values
        function move_abs(obj, pos)
            % absolute positioning
            obj.servo.SetAbsMovePos(0,pos);
            obj.servo.MoveAbsolute(0,false);
            obj.position = obj.servo.GetPosition_Position(0);
            % wait until reached exactly the position
            % ( I assume the error is taken in account in the driver, 
            % so asking the position, pm 0.001)
            % with a timeout of 10s
            for i = 1:10000
                if ( (obj.servo.GetPosition_Position(0) > pos-obj.precision) && (obj.servo.GetPosition_Position(0) < pos+obj.precision) )
                    break
                end
                pause(0.001);
            end
        end
        
        % move with relative values
        function move_rel(obj, pos)
            % relative positioning
            prev_pos = obj.servo.GetPosition_Position(0);
            obj.servo.SetRelMoveDist(0,pos);
            obj.servo.MoveRelative(0,false);
            obj.position = obj.servo.GetPosition_Position(0);
            % wait until reached exactly the position
            % ( I assume the error is taken in account in the driver, 
            % so asking the EXACT position )
            for i = 1:10000
                if (obj.servo.GetPosition_Position(0) > prev_pos+pos-obj.precision) && (obj.servo.GetPosition_Position(0) < prev_pos+pos+obj.precision)
                    break
                end
                pause(0.001);
            end
        end
        
        % delete the handle
        function delete(obj)
            obj.servo.delete();
            close(obj.servofig);
        end
        
        
        
    end
    
end