function matrice = mycrop(video_data_D)
Iy =[];
    for i = 1:size(video_data_D,1)
        Iy = [Iy mean(video_data_D(i,:,end))];
    end
%     figure()
%     hold on
%     plot(1:size(video_data_D,1),Iy)

    [peak_intensityy, argmaxy] = max(Iy);
    peak_posy = argmaxy;
    [xDatay, yDatay] = prepareCurveData( 1:size(video_data_D,1), Iy );
    fty = fittype( 'a2*exp(-0.5*((x-b2)/c2)^2)+d2', 'independent', 'x', 'dependent', 'y' );
    optsy = fitoptions( 'Method', 'NonlinearLeastSquares' );
    optsy.Display = 'Off';
    peak_widthy = 500;
    optsy.StartPoint = [peak_intensityy peak_posy peak_widthy 100];
    [fitresulty, gof] = fit( xDatay, yDatay, fty, optsy );

%     plot(fitresulty)
    peak_posy = fitresulty.b2;
    peak_intensityy = fitresulty.a2;
    peak_widthy = 2.35482*abs(fitresulty.c2);
    off_sety = fitresulty.d2;

    %second axis

    Ix = [];
    for u = 1:size(video_data_D,2)
        Ix = [Ix mean(video_data_D(:,u,end))];
    end
%     figure()
%     hold on
%     plot(1:size(video_data_D,2),Ix)

    [peak_intensityx, argmaxx] = max(Ix);
    peak_posx = argmaxx;
    [xDatax, yDatax] = prepareCurveData( 1:size(video_data_D,2), Ix );
    ftx = fittype( 'a1*exp(-0.5*((x-b1)/c1)^2)+d1', 'independent', 'x', 'dependent', 'y' );
    optsx = fitoptions( 'Method', 'NonlinearLeastSquares' );
    optsx.Display = 'Off';
    peak_widthx = 350;
    optsx.StartPoint = [peak_intensityx peak_posx peak_widthx 100];
    [fitresultx, gof] = fit( xDatax, yDatax, ftx, optsx );

%     plot(fitresultx)
    peak_posx = fitresultx.b1;
    peak_intensityx = fitresultx.a1;
    peak_widthx = 2.35482*abs(fitresultx.c1);
    off_setx = fitresultx.d1;
    %end of the fit
    matrice = video_data_D((peak_posy-(peak_widthy)/2):(peak_posy+(peak_widthy)/2),...
                 (peak_posx-(peak_widthx)/2):(peak_posx+(peak_widthx)/2),:);
   
   
end