function networkOutput = sigmoid(networkInput) 
    networkOutput = ( exp(-networkInput) + 1).^-1;
end

