function [ TEST_RES ] = T_Test_Difference(Difference_matrix)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

% Apply a one-sample t-test to Delta Model;

  n = size(Difference_matrix,1);
  m = size(Difference_matrix,2);
  r = size(Difference_matrix,3);
  
  TEST_RES = zeros(n,m,2);

  if(size(Difference_matrix,3)>=2)
    for i=1:n
      for j=1:m
%         if(i~=1 && j~=1)
        if(any(Difference_matrix(i,j,:)))
          [h, p] = ttest( reshape(Difference_matrix(i,j,:),[1 r]));
          TEST_RES(i,j,1) = h;
          TEST_RES(i,j,2) = p;
        end
      end
    end
  else
    %corrected v1.22
     TEST_RES = []; %zeros(n,m,r);
  end

end