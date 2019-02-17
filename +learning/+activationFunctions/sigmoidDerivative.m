function derivative = sigmoidDerivative(networkInput) 
    networkOutput = learning.activationFunctions.sigmoid(networkInput);
    derivative = networkOutput .* (1 - networkOutput);
end

