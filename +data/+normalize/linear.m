function normalizedVector = linear(vector)

    linearScaleFunction = data.normalize.linearScaleFactory(vector);

    normalizedVector = linearScaleFunction(vector);
%     maxi = max(vector);
%     mini = min(vector);
% 
%     scale = maxi - mini;
% 
%     normalizedVector = (vector - mini) / scale;
end
