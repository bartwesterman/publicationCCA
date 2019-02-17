function normalizedVector = logarithmic(vector)
    scaleFunction = data.normalize.logarithmicScaleFactory(vector);
    normalizedVector = scaleFunction(vector);
end