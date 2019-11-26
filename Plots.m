clear all;
close all;
clc;
format long;

spectrum = [500 550 600 650 700 750];
D = pi./2;
k = 1;
n = 300;
Win = 0.004;
Lb = 150 ;
La = 50;

dlambda = 10;
lambda = (500:dlambda:1000)';
dD = pi./100;
D = (0:dD:pi/2)';

[xx,yy] = meshgrid(lambda,D);

Wex = Win.*(cos(asin((k.*n.*xx.*10^(-6))./(2.*cos(yy/2)))-yy/2)...
    .*Lb)./(cos(yy + asin((k.*n.*xx.*10^(-6))./(2.*cos(yy/2)))-yy/2).*La);
BP = Wex.*(cos(asin((k.*n.*xx.*10^(-6))./(2.*cos(yy/2)))-yy/2).*Lb)...
    ./(cos(yy + asin((k.*n.*xx.*10^(-6))./(2.*cos(yy/2)))-yy/2).*La)...
    .*(cos(yy + asin((k.*n.*xx.*10^(-6))./(2.*cos(yy/2)))-yy/2).*10^6)./(k.*n.*Lb)

figure()
surf(xx,yy,Wex)
xlabel('wavelength')
ylabel('angle')
zlabel('exit slit ideal dimension')
figure()
surf(xx,yy,BP)
xlabel('wavelength')
ylabel('angle')
zlabel('bandpass')