function normalizedVector = optimal(vector)
    normalizedLogarithmically = data.normalize.logarithmic(vector);
    normalizedLinearly = data.normalize.linear(vector);

    linearError = data.normalize.error(normalizedLinearly); 
    logarithmicError = data.normalize.error(normalizedLogarithmically); 

    if (logarithmicError > linearError)
        normalizedVector = normalizedLinearly;
        return;
    end

    normalizedVector = normalizedLogarithmically;
    return;
end
