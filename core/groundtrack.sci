// OrbitalMDT :: Ground Track Computation
// Sub-satellite ground track (latitude, longitude) from ECI states.

function [lat, lon] = compute_ground_track(states, t_vec, omega_earth)
    // Vectorized sub-satellite ground track calculation (latitude, longitude) from ECI states.
    r_vec = states(1:3, :);
    r = sqrt(sum(r_vec.^2, "r"));
    r(r < 1e-10) = 1e-10;

    lat = asin(max(-1, min(1, r_vec(3, :) ./ r))) * 180 / %pi;

    ra = atan(r_vec(2, :), r_vec(1, :));
    theta = omega_earth * t_vec(:)';
    lon_rad = ra - theta;

    lon = pmodulo(lon_rad * 180 / %pi + 180, 360) - 180;
endfunction


function plot_ground_track(lat, lon, title_str)
    // Plot ground track on a lat/lon grid.

    if ~exists('title_str', 'local') then
        title_str = "Satellite Ground Track";
    end

    // Safe figure/axes initialization: do not clear the whole GUI if invoked within OrbitalMDT
    is_gui = %F;
    try
        f_cur = gcf();
        if is_valid_handle(f_cur) then
            if f_cur.tag == 'main_fig' then
                is_gui = %T;
            end
        end
    catch
    end

    if is_gui then
        clear_plot_axes();
        newaxes();
        gca().axes_bounds = [0.31, 0.08, 0.65, 0.84];
    else
        clf();
    end

    // grid lines first so they appear behind the track
    for lat_grid = -60:30:60
        plot([-180, 180], [lat_grid, lat_grid], 'k:');
    end
    for lon_grid = -120:60:120
        plot([lon_grid, lon_grid], [-90, 90], 'k:');
    end

    // plot track with discontinuity handling at date line
    seg_start = 1;
    for k = 2:size(lon, "*")
        if abs(lon(k) - lon(k-1)) > 180 then
            plot(lon(seg_start:k-1), lat(seg_start:k-1), 'b-', 'LineWidth', 2);
            seg_start = k;
        end
    end
    plot(lon(seg_start:$), lat(seg_start:$), 'b-', 'LineWidth', 2);

    plot(lon(1), lat(1), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    plot(lon($), lat($), 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

    xlabel("Longitude [deg]");
    ylabel("Latitude [deg]");
    title(title_str);
    gca().data_bounds = [-180, -90; 180, 90];
endfunction
