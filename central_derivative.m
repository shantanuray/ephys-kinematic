function dydt = central_derivative(y, fs, n, num_points)
    % central_derivative(y, fs, n, num_points)
    % derivative code adapted from
    % https//docs.scipy.org/doc/scipy-0.15.1/reference/generated/scipy.misc.derivative.html
    % --------
    % Find the nth (1nd or 2nd) derivative of time series data wrt time
    % using central weighted derivatives
    % Given data, use 3/5/7/9 points with spacing `dt` to
    % compute the `n`-th derivative at each point
    % Parameters
    % ----------
    % y  Vectors or time series data
    %     Input data.
    % fs  int
    %     Sampling frequency. (dt = 1/fs)
    % n  int, optional
    %     Order of the derivative. Default is 1.
    % num_points  int, optional (3,5,7,9)
    %     Number of points to use, must be odd. Default = 3. (5/7/9/default)
    % --------
    % Examples
    % --------
    % >>> y = np.rand();
    % >>> v = central_derivative(y, 1000, 1, 3);
    % TODO Generalize to nth derivative
    if nargin<4
        num_points = 3;
    end
    if nargin<3
        n = 1;
    end
    if num_points < n + 1
        error("'num_points' (the number of points used to compute the derivative),must be at least the derivative num_points 'n' + 1.");
    end
    if mod(num_points, 2) == 0
        error("'num_points' (the number of points used to compute the derivative) must be odd.");
    end
    % pre-computed for n=1 and 2 and low-num_points for speed.
    if n == 1
        if num_points == 3
            weights = [-1, 0, 1]/2.0;
        elseif num_points == 5
            weights = [1, -8, 0, 8, -1]/12.0;
        elseif num_points == 7
            weights = [-1, 9, -45, 0, 45, -9, 1]/60.0;
        elseif num_points == 9
            weights = [3, -32, 168, -672, 0, 672, -168, 32, -3]/840.0;
        else
            error("Unable to compute for num_points > 9. Use max 9.");
        end
    elseif n == 2
        if num_points == 3
            weights = [1, -2.0, 1];
        elseif num_points == 5
            weights = [-1, 16, -30, 16, -1]/12.0;
        elseif num_points == 7
            weights = [2, -27, 270, -490, 270, -27, 2]/180.0;
        elseif num_points == 9
            weights = [-9, 128, -1008, 8064, -14350, 8064, -1008, 128, -9]/5040.0;
        else
            error("Unable to compute for num_points (the number of points used to compute the derivative) > 9. Use max 9.");
        end
    else
        error("Unable to compute for num_points of derivative > 2. Use max 2.");
    end
    dt = 1/fs;
    ho = floor(bitsra(num_points, 1));
    num = length(y)-num_points+1;
    dydt = zeros(size(y));
    for j = ho:length(y)-num_points+1
        for k = 1:num_points
            dydt(j,:) = (dydt(j,:) + weights(k)*y(j+k-ho, :));
        end
    end

    dydt = dydt(1:num, :)/(dt^n);
end