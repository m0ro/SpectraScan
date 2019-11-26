classdef servo_thorlabs < handle
    % manage the shutters trough an arduino board and servos for RCs
    % the arduino code is written at the end of this code

    properties (Access = private)
        position
        servofig
        servox
    end

    methods
        % constructor
        function self = servo_thorlabs(serial_n)
            % should be cool to hide the window from the user
            % global servox; % make servo a global variable so it can be used outside the main
            self.servofig = figure('Position', [0 0 650 450],'Menu','None','Name','APT GUI');
            % Create ActiveX Controller
            self.servox = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400], self.servofig);
            % Initialize
            % Start Control
            self.servox.StartCtrl;
            % Set the Serial Number
            %serial_n = 83843398;
            set(self.servox,'HWSerialNum', serial_n);
            % Indentify the device
            self.servox.Identify;
            pause(0.5); 
        end
        % move with absolute values
        function move_abs(self, pos)
            % absolute positioning
            self.servox.SetAbsMovePos(0,pos);
            self.servox.MoveAbsolute(0,false);
            self.position = self.servox.GetPosition_Position(0);
        end
        % move with relative values
        function move_rel(self, pos)
            % relative positioning
            self.servox.SetRelMoveDist(0,pos);
            self.servox.MoveRelative(0,false);
            self.position = self.servox.GetPosition_Position(0);
        end
        % delete the handle
        function delete(self)
            self.servox.delete();
            close(self.servofig);
        end
        
    end
    
end