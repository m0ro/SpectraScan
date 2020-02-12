classdef speckle_processing < handle
    
    properties
        hp = 5;
        lp = 200;
        shape
        fft_mask
    end
    
    methods
        
        function self = speckle_processing(shape)
            self.shape = shape;
        end
        
        function prepare_donut(self, high_pass, low_pass)
            if (nargin == 3)
                self.hp = high_pass;
                self.lp = low_pass;
            end
            [XX,YY] = meshgrid(1:self.shape(2),1:self.shape(1));
            XX = XX-self.shape(2)/2; YY = YY-self.shape(1)/2; 
            self.fft_mask = exp(-((XX/self.lp).^2+(YY/self.lp).^2 )/2)- ...
                exp(-((XX/self.hp).^2+(YY/self.hp).^2 )/2);
        end
        
        function dataout = apply_donut(self, datain)
            fourier_domain = fft2(datain).*fftshift(self.fft_mask);
            dataout = real(ifft2(fourier_domain));
        end
        
        function contrast = get_contrast(self, datain)
            contrast = std(datain(:))/mean(datain(:));
        end
        
        function cc = auto_correlation(self, datain)
%             fft_product = np.fft.fft2(cropped_data) * np.fft.fft2(cropped_data).conj()
%             cc_data = np.abs(np.fft.fftshift(np.fft.ifft2(fft_product)))**2
            fft_product = fft2(datain).*conj(fft2(datain));
            cc = abs(fftshift(ifft2(fft_product))).^2;
        end
        
        function dataout = crop(self, datain)
            % output must be the cropped image where the contrast of the
            % speckle is still good...with one spot is the center, with
            % multiple spot maybe is not so straightforward...
            dataout = datain;
        end
        
    end
    
end