function dydt = forward_derivative(y, fs, n, num_points)
    % forward_derivative(y, fs, n, num_points)
    % --------
    % Find the nth (1nd or 2nd) derivative of time series data wrt time
    % using forward weighted derivatives
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
    % >>> v = forward_derivative(y, 1000, 1, 3);
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
    w = forward_diff_weights(num_points, n);
    dt = 1/fs;
    ho = double(bitsra(int8(num_points), 1))+1;
    num = size(y, 1)-num_points+1;
    dydt = zeros(size(y));
    for j = ho:num+ho-1
        for k = 1:num_points
            dydt(j-ho+1,:) = (dydt(j-ho+1,:) + w(k)*y(j+k-ho, :));
        end
    end

    dydt = dydt(1:num, :)/(dt^n);
end


function w = forward_diff_weights(num_points, ndiv)
    % Return weights for an num_points forward derivative.
    % Assumes equally-spaced function points.
    % If weights are in the vector w, then
    % derivative is w[0] * f(x-ho*dx) + ... + w[-1] * f(x+h0*dx)
    % Parameters
    % ----------
    % num_points : int
    %     Number of points for the forward derivative.
    % ndiv : int, optional
    %     Number of divisions (order of derivative). Default is 1.
    % Returns
    % -------
    % w : ndarray
    %     Weights for an num_points forward derivative. Its size is `num_points`.
    % Notes
    % -----
    % Can be inaccurate for a large number of points.
    % References
    % ----------
    % .. [1] https://en.wikipedia.org/wiki/Finite_difference
    if num_points < ndiv + 1
        error("Number of points must be at least the derivative order + 1.");
    end
    if mod(num_points, 2) == 0
        error("The number of points must be odd.");
    end
    w = [];
    ho = 1:num_points;
    for i = 1:num_points
        w = [w, ((-1)^(ndiv-i))*nchoosek(ndiv,i)];
    end
end