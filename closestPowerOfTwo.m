function pow2 = closestPowerOfTwo(number)
    if number < 1
            error('Number must be greater than or equal to 1');
    end

    pow2 = log2(number);

    pow2 = round(pow2);

    pow2 = 2^pow2;

end