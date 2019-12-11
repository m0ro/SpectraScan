classdef servo_thorlabs < handle
    % manage servos from thorlabs
    % use the APT GUI https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0
    % https://www.thorlabs.com/Software/Motion%20Control/APT_Communications_Protocol.pdf
    

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
            % serial_n = 83843398;
            % serial_n = 83847443; % serial from the monocromator servo controller
            set(self.servox, 'HWSerialNum', serial_n);
            % Indentify the device
            self.servox.Identify;
            pause(0.5); 
            self.servox.MoveAbsolute(0,false);  %--------------------------------------------------------???What does it mean here???         
        end
        
        % move with absolute values
        function move_abs(self, pos)
            % absolute positioning
            self.servox.SetAbsMovePos(0,pos);
            self.servox.MoveAbsolute(0,false); %------------------------------------------------------------the same here
            self.position = self.servox.GetPosition_Position(0);
            % wait until stop move (once implemented, remove the pause)
            pause(0.5);
        end
        
        % move with relative values
        function move_rel(self, pos)
            % relative positioning
            self.servox.SetRelMoveDist(0,pos);
            self.servox.MoveRelative(0,false); %--------------------------------------------------------------the same here
            self.position = self.servox.GetPosition_Position(0);
            % wait until stop move
            pause(0.5);
        end
        
        % delete the handle
        function delete(self)
            self.servox.delete();
            close(self.servofig);
        end
        
        
        
    end
    
end