function ellipse_t = fit_ellipse(x, y)
% Geometric fit of an axis-aligned ellipse
% Uses centroid and spread of selected points

% Ensure column vectors
x = x(:);
y = y(:);

% Check input
if length(x) < 5
    error('fit_ellipse: At least 5 points are recommended for a robust fit.');
end

% Compute centroid
ellipse_t.X0_in = mean(x);
ellipse_t.Y0_in = mean(y);

% Compute approximate axes (scaled std deviations)
ellipse_t.a = std(x) * sqrt(2);
ellipse_t.b = std(y) * sqrt(2);

% No rotation for now (axis-aligned ellipse)
ellipse_t.phi = 0;

end