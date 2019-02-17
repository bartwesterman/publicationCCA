function normalizedVector = rank(vector)

    scaleFunction = data.normalize.rankScaleFactory(vector);
    normalizedVector = scaleFunction(vector);
    return;
end
