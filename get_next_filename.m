function filename = get_next_filename(root_folder, seed_name)
    disp(nargin);
    if nargin < 2
        seed_name = '';
    end
%     Defaults = {A,B,C...};
%     Defaults(1:nargin) = varargin;

    % search for an available filename
    for ii = 1:1000
        if seed_name ~= ""
            seed_name = strcat(seed_name, '_');
        end
        tmpst = strcat(root_folder,'data_',datestr(now,'ddmmyyyy'),'_',seed_name, sprintf('%03d',ii) ,'.mat');
        if (exist(tmpst, 'file')~=2)
    %         tiff_file = tmpst;
            filename = tmpst;
            break;
        end
    end
    if ii==1000
        error('More than 1000 files today, please backup and empty %s',root_folder);
        filename = '';
    end
end

