clear all;
close all;
clc;
format long;

k = 1;
n = 300;
Win = 0.004;
Lb = 150 ;
La = 50;

   lambda = [500 550 600 650 700 750];
%     dlambda = 1;
%     lambda = (500:dlambda:1000)';
    dD = pi/500;
    D = (0:dD:pi/2)';
    
    alpha = @(D) asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2;
    alpha1 = (alpha(D)).*180./pi
    
    beta = @(D) D + asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2 ;
    beta1 = beta(D).*180./pi
    
    lindisp = @(D) (cos(D + asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2).*10^6)./(k.*n.*Lb);
    lindisp1 = lindisp(D)
    
    Wex = @(D) Win.*(cos(asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2).*Lb)./(cos(D + asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2).*La)
    Wextry = 0.010;
    Wex1 = Wex
    BP = @(D) 0.010.*(cos(asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2).*Lb)./(cos(D + asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2).*La).*(cos(D + asin((k.*n.*lambda.*10^(-6))./(2.*cos(D/2)))-D/2).*10^6)./(k.*n.*Lb)
    BP1 = BP
    
    figure()
    plot(D,Wex1(D))
    figure()
    plot(D,BP1(D))




