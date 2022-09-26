function out = padZeros(in, numrows)
	% Pad numrows of zeros at start of `in`
	% out = padZeros(in, numrows);
	padZeroSize = size(in);
    padZeroSize(1) = numrows;
	out = cat(1, in, zeros(padZeroSize));