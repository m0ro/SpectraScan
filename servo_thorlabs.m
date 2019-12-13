classdef servo_thorlabs < handle
    % manage servos from thorlabs
    % use the APT GUI https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0
    % https://www.thorlabs.com/Software/Motion%20Control/APT_Communications_Protocol.pdf
    

    properties% (Access = private)
        position
        servofig
        servo
    end

    methods
        % constructor
        function self = servo_thorlabs(serial_n)
            % should be cool to hide the window from the user
            % global servo; % make servo a global variable so it can be used outside the main
            self.servofig = figure('Name','ThorlabsServo','Position', [50 50 300 150],'Menu','None','Name','APT GUI');
            % Create ActiveX Controller
            self.servo = actxcontrol('MGMOTOR.MGMotorCtrl.1',[0 0 300 150], self.servofig);
            % Initialize
            % Start Control
            self.servo.StartCtrl;
            % Set the Serial Number
            % serial_n = 83843398;
            % serial_n = 83847443; % serial from the monocromator servo controller
            set(self.servo, 'HWSerialNum', serial_n);
            % Indentify the device
            self.servo.Identify;
            pause(0.5); 
            self.servo.MoveAbsolute(0,false);  
        end
        
        % move with absolute values
        function move_abs(self, pos)
            % absolute positioning
            self.servo.SetAbsMovePos(0,pos);
            self.servo.MoveAbsolute(0,false);
            self.position = self.servo.GetPosition_Position(0);
            % wait until reached exactly the position
            % ( I assume the error is taken in account in the driver, 
            % so asking the EXACT position )
            for i = 1:10000
                if self.servo.GetPosition_Position(0) == pos
                    break
                end
                pause(0.001);
            end
        end
        
        % move with relative values
        function move_rel(self, pos)
            % relative positioning
            prev_pos = self.servo.GetPosition_Position(0);
            self.servo.SetRelMoveDist(0,pos);
            self.servo.MoveRelative(0,false);
            self.position = self.servo.GetPosition_Position(0);
            % wait until reached exactly the position
            % ( I assume the error is taken in account in the driver, 
            % so asking the EXACT position )
            for i = 1:10000
                if self.servo.GetPosition_Position(0) == prev_pos+pos
                    break
                end
                pause(0.001);
            end
        end
        
        % delete the handle
        function delete(self)
            self.servo.delete();
            close(self.servofig);
        end
        
        
        
    end
    
end