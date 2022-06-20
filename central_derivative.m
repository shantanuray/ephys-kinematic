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
    %     num_points must be > n+1
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
            w = [-1, 0, 1]/2.0;
        elseif num_points == 5
            w = [1, -8, 0, 8, -1]/12.0;
        elseif num_points == 7
            w = [-1, 9, -45, 0, 45, -9, 1]/60.0;
        elseif num_points == 9
            w = [3, -32, 168, -672, 0, 672, -168, 32, -3]/840.0;
        else
            error("Unable to compute for num_points > 9. Use max 9.");
        end
    elseif n == 2
        if num_points == 3
            w = [1, -2.0, 1];
        elseif num_points == 5
            w = [-1, 16, -30, 16, -1]/12.0;
        elseif num_points == 7
            w = [2, -27, 270, -490, 270, -27, 2]/180.0;
        elseif num_points == 9
            w = [-9, 128, -1008, 8064, -14350, 8064, -1008, 128, -9]/5040.0;
        else
            error("Unable to compute for num_points (the number of points used to compute the derivative) > 9. Use max 9.");
        end
    else
         w = central_diff_weights(num_points, n);
    end
    dt = 1/fs;
    ho = double(bitsra(int8(num_points), 1));
    num = size(y, 1)-num_points+1;
    dydt = zeros(size(y));
    for j = ho:num
        for k = 1:num_points
            dydt(j,:) = (dydt(j,:) + w(k)*y(j+k-ho, :));
        end
    end

    dydt = dydt(1:num, :)/(dt^n);
end


function w = central_diff_weights(num_points, ndiv)
    % Return weights for an num_points central derivative.
    % Assumes equally-spaced function points.
    % If weights are in the vector w, then
    % derivative is w[0] * f(x-ho*dx) + ... + w[-1] * f(x+h0*dx)
    % Parameters
    % ----------
    % num_points : int
    %     Number of points for the central derivative.
    % ndiv : int, optional
    %     Number of divisions (order of derivative). Default is 1.
    % Returns
    % -------
    % w : ndarray
    %     Weights for an num_points central derivative. Its size is `num_points`.
    % Notes
    % -----
    % Can be inaccurate for a large number of points.
    % References
    % ----------
    % .. [1] https://en.wikipedia.org/wiki/Finite_difference
    % Code from https://github.com/scipy/scipy/blob/v1.8.1/scipy/misc/_common.py#L75-L145
    if num_points < ndiv + 1
        error("Number of points must be at least the derivative order + 1.");
    end
    if mod(num_points, 2) == 0
        error("The number of points must be odd.");
    end
    ho = double(bitsra(int8(num_points), 1));
    x = [-ho:ho]';
    X = x.^0;
    for k = [1:num_points-1]
        X = [X, x.^k];
    end
    W = prod([1:ndiv], 'all')*inv(X);
    w = W[ndiv+1, :];
end