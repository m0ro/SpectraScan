function vector=correlation_function_average(matrix3D,L,time,bandwidth) 
n=size(matrix3D); 
C=zeros(n(3)*(n(3)+1)/2,2); 
i=0; 
for k=1:1:n(3) % loop on the differents omega of the 3Dmatrix 
    for q=1:1:n(3)-k % loop on the different steps between different omegas 
        i=i+1; 
        if abs(time(k)-time(k+q)) < bandwidth
            C(i,1)=corr2(matrix3D(:,:,k),matrix3D(:,:,k+q));  % finally we have dim1*dim2 (corresponded at the number of pixels of the camera) correlation function 
            C(i,2)=abs(L(k)-L(k+q));
            C(i,3)=abs(time(k)-time(k+q))/2+min([time(k),time(k+q)]);
        end    
    end 
end 
% for k=n(3):-1:1 % loop on the differents omega of the 3Dmatrix 
%     for q=1:1:n(3)-k % loop on the different steps between different omegas 
%         i=i+1; 
%         if abs(time(k)-time(k-q)) < bandwidth
%             C(i,1)=corr2(matrix3D(:,:,k),matrix3D(:,:,k-q));  % finally we have dim1*dim2 (corresponded at the number of pixels of the camera) correlation function 
%             C(i,2)=abs(L(k)-L(k-q));
%             C(i,3)=abs(time(k)-time(k-q))/2+min([time(k),time(k-q)]);
%         end    
%     end 
% end 

C=sortrows(C,2); % select the matrix on increasing q 
% average on the same q of the correlation coefficients 
% cat=unique(C(:,3)); 
% A=zeros(numel(cat),2); 
% for i=1:numel(cat) 
%    A(i,1)=mean(C(C(:,2)==cat(i),1)); 
%    A(i,2)=std(C(C(:,2)==cat(i),1)); 
%    A(i,3)=cat(i); 
% end 
vector=C; 
end