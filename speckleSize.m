function [B,C,size1,size2] = speckleSize(videomatrix, pixelSize)


A = (mycrop(videomatrix));

size1 = [];
size2 = [];

for k = 1:size(videomatrix,3)
    
    B = normxcorr2(A(:,:,k),A(:,:,k));
    [row, col] = find(ismember(B, max(B(:))));
    
    C = B(row-15:row+15,col-15:col+15);
    M = 1:size(C,1);
    N = 1:size(C,2);
    
    [xData, yData, zData] = prepareSurfaceData( M, N, C );

    % Set up fittype and options.
    ft = fittype( '(1-a)*exp(-0.5*(((x-b)/c)^2 + ((y-d)/e)^2)) + a', 'independent', {'x', 'y'}, 'dependent', 'z' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [0.1 15 5 15 5];

    % Fit model to data.
    [fitresult, gof] = fit( [xData, yData], zData, ft, opts );

%     % Plot fit with data.
%     figure( 'Name', 'untitled fit 1' );
%     h = plot( fitresult, [xData, yData], zData );
%     legend( h, 'untitled fit 1', 'C vs. M, N', 'Location', 'NorthEast', 'Interpreter', 'none' );
%     % Label axes
%     xlabel( 'M', 'Interpreter', 'none' );
%     ylabel( 'N', 'Interpreter', 'none' );
%     zlabel( 'C', 'Interpreter', 'none' );
%     grid on
%     view( 91.6, 1.6 );

    width1 = 2.35482*abs(fitresult.c);
    width2 = 2.35482*abs(fitresult.e);
    
    size1 = [size1 width1*pixelSize];
    size2 = [size2 width2*pixelSize];
end

% figure()
% plot(1:size(videomatrix,3),size1,'b',1:size(videomatrix,3),size2,'r')
end