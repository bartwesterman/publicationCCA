function sumError2 = error(normalizedVector)
    sortedVector = sort(normalizedVector);

    vectorCount = length(normalizedVector);

    slope     = 1 / (vectorCount - 1);

    sumError2 = 0;
    for i = 1:vectorCount
        x = i - 1;
        targetY = slope * x;

        error = targetY - sortedVector(i);

        sumError2 = sumError2 + error * error;
    end
end
