function [SubMatrix] = ExtractSubMatrix(Raw_matrix, x_coor, y_coor, x_range, y_range)
    % Find clostest value to each limit given
    ranges = [];
    % find lower limit of amplitude 
    [m,i] = min(abs(x_coor-x_range(1)));
    ranges(1) = i;
    % find upper limit of amplitude
    [m,i] = min(abs(x_coor-x_range(2)));
    ranges(2) = i;
    % find lower limit of phase
    [m,i] = min(abs(y_coor-y_range(1)));
    ranges(3) = i;
    % find upper limit of phase
    [m,i] = min(abs(y_coor-y_range(2)));
    ranges(4) = i;

    % Extract subMatrix
    fprintf('Amplitude cutting from %d to %d\n',x_coor(ranges(1)),x_coor(ranges(2)));
    fprintf('Phase cutting from %d to %d',y_coor(ranges(3)),y_coor(ranges(4)));
    disp(' ');
    SubMatrix = Raw_matrix(ranges(1):ranges(2), ranges(3):ranges(4));
end