// OrbitalMDT :: Hohmann & Bi-Elliptic Transfer Tab

function build_hohmann_tab(fig)

    win_w = 1200; win_h = 800;
    try win_w = fig.axes_size(1); win_h = fig.axes_size(2); catch end

    y_base = win_h - 780;
    x_panel = 15;
    pw = 290;

    uicontrol(fig, 'style', 'text', 'string', '[*] ORBITAL TRANSFERS', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.2, 0.7, 0.3], 'tag', 'content_ht_title');

    uicontrol(fig, 'style', 'text', 'string', 'Transfer Type:', ..
        'position', [x_panel, y_base+632, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl0');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Hohmann (2-burn)|Bi-Elliptic (3-burn)', ..
        'position', [x_panel+120, y_base+630, 155, 25], 'fontsize', 10, ..
        'tag', 'content_ht_type', 'callback', 'cb_transfer_type_changed()');

    uicontrol(fig, 'style', 'text', 'string', 'Orbit System:', ..
        'position', [x_panel, y_base+600, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl00');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Earth Orbit (km)|Heliocentric (AU)|Custom mu (km)', ..
        'position', [x_panel+120, y_base+598, 155, 25], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_ht_system');

    uicontrol(fig, 'style', 'text', 'string', 'Initial Orbit Radius:', ..
        'position', [x_panel, y_base+565, 150, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl1');
    uicontrol(fig, 'style', 'edit', 'string', '6571', ..
        'position', [x_panel+150, y_base+563, 125, 25], 'fontsize', 10, ..
        'tag', 'content_ht_r1');

    uicontrol(fig, 'style', 'text', 'string', 'Final Orbit Radius:', ..
        'position', [x_panel, y_base+535, 150, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl2');
    uicontrol(fig, 'style', 'edit', 'string', '42164', ..
        'position', [x_panel+150, y_base+533, 125, 25], 'fontsize', 10, ..
        'tag', 'content_ht_r2');

    uicontrol(fig, 'style', 'text', 'string', 'Intermediate Radius:', ..
        'position', [x_panel, y_base+505, 150, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl3', 'visible', 'off');
    uicontrol(fig, 'style', 'edit', 'string', '100000', ..
        'position', [x_panel+150, y_base+503, 125, 25], 'fontsize', 10, ..
        'tag', 'content_ht_r_int', 'visible', 'off');

    uicontrol(fig, 'style', 'text', 'string', 'Quick Presets:', ..
        'position', [x_panel, y_base+470, 120, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ht_lbl4');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Custom|LEO->GEO|LEO->MEO|LEO->Moon|Earth->Mars|Earth->Jupiter', ..
        'position', [x_panel+110, y_base+468, 165, 25], 'fontsize', 10, ..
        'tag', 'content_ht_presets', 'callback', 'cb_hohmann_preset()');

    uicontrol(fig, 'style', 'pushbutton', 'string', 'CALCULATE TRANSFER', ..
        'position', [x_panel, y_base+425, pw, 35], ..
        'fontsize', 12, 'fontweight', 'bold', ..
        'background', [0.2, 0.7, 0.3], 'foreground', [1, 1, 1], ..
        'callback', 'cb_calculate_transfer()', 'tag', 'content_ht_calculate');

    uicontrol(fig, 'style', 'text', 'string', '[*] RESULTS', ..
        'position', [x_panel, y_base+395, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.1, 0.5, 0.1], 'tag', 'content_ht_res_title');

    rl = ['Delta-V1 (1st burn):  --'; ..
          'Delta-V2 (2nd burn):  --'; ..
          'Delta-V3 (3rd burn):  --'; ..
          'Delta-V Total:        --'; ..
          'Transfer Time:       --'; ..
          'Transfer SMA:        --'; ..
          'Transfer Ecc:        --'; ..
          'Phase Angle:         --'; ..
          'Transfer Energy:     --'; ..
          'Comparison:          --'];

    for k = 1:10
        uicontrol(fig, 'style', 'text', 'string', rl(k,:), ..
            'position', [x_panel, y_base+395-k*23, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_ht_result_' + string(k));
    end

    // Model Assumptions Banner
    uicontrol(fig, 'style', 'text', ..
        'string', 'Assumptions: Coplanar, Circular Co-axial, 2-Body Impulsive', ..
        'position', [x_panel, y_base+140, pw, 18], 'fontsize', 8, ..
        'horizontalalignment', 'left', 'foreground', [0.5, 0.5, 0.5], ..
        'tag', 'content_ht_assumptions');

    plot_w = max(400, win_w - 330);
    uicontrol(fig, 'style', 'text', ..
        'string', 'Transfer orbit diagram will appear here', ..
        'position', [310, floor(win_h / 2) - 20, plot_w, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_ht_plot_placeholder');
endfunction


function cb_transfer_type_changed()
    type_val = get(findobj('tag', 'content_ht_type'), 'value');
    vis = 'off';
    if type_val == 2 then vis = 'on'; end
    set(findobj('tag', 'content_ht_lbl3'), 'visible', vis);
    set(findobj('tag', 'content_ht_r_int'), 'visible', vis);
endfunction


function cb_hohmann_preset()
    preset = get(findobj('tag', 'content_ht_presets'), 'value');
    select preset
    case 2
        set(findobj('tag', 'content_ht_r1'), 'string', '6571');
        set(findobj('tag', 'content_ht_r2'), 'string', '42164');
        set(findobj('tag', 'content_ht_system'), 'value', 1);
    case 3
        set(findobj('tag', 'content_ht_r1'), 'string', '6571');
        set(findobj('tag', 'content_ht_r2'), 'string', '26561');
        set(findobj('tag', 'content_ht_system'), 'value', 1);
    case 4
        set(findobj('tag', 'content_ht_r1'), 'string', '6571');
        set(findobj('tag', 'content_ht_r2'), 'string', '384400');
        set(findobj('tag', 'content_ht_system'), 'value', 1);
    case 5
        set(findobj('tag', 'content_ht_r1'), 'string', '1.0');
        set(findobj('tag', 'content_ht_r2'), 'string', '1.524');
        set(findobj('tag', 'content_ht_system'), 'value', 2);
    case 6
        set(findobj('tag', 'content_ht_r1'), 'string', '1.0');
        set(findobj('tag', 'content_ht_r2'), 'string', '5.203');
        set(findobj('tag', 'content_ht_system'), 'value', 2);
    end
endfunction


function cb_calculate_transfer()
    const = orbital_constants();

    [r1, ok1, m1] = gui_get_positive_num('content_ht_r1', 'Initial Orbit Radius');
    if ~ok1 then gui_report_error(m1); return; end

    [r2, ok2, m2] = gui_get_positive_num('content_ht_r2', 'Final Orbit Radius');
    if ~ok2 then gui_report_error(m2); return; end

    sys = get(findobj('tag', 'content_ht_system'), 'value');

    select sys
    case 1, mu = const.mu_Earth;
    case 2, mu = const.mu_Sun; r1 = r1 * const.AU; r2 = r2 * const.AU;
    case 3, mu = const.mu_Earth;
    end

    transfer_type = get(findobj('tag', 'content_ht_type'), 'value');

    if transfer_type == 1 then
        try
            result = hohmann_transfer(r1, r2, mu);
        catch
            gui_report_error("Failed to compute Hohmann transfer: " + lasterror());
            return;
        end

        set(findobj('tag', 'content_ht_result_1'), 'string', ..
            msprintf('Delta-V1 (1st burn): %.4f km/s', result.dv1));
        set(findobj('tag', 'content_ht_result_2'), 'string', ..
            msprintf('Delta-V2 (2nd burn): %.4f km/s', result.dv2));
        set(findobj('tag', 'content_ht_result_3'), 'string', ..
            'Delta-V3 (3rd burn): N/A (2-burn)');
        set(findobj('tag', 'content_ht_result_4'), 'string', ..
            msprintf('Delta-V Total:       %.4f km/s', result.dv_total));

        t_hrs = result.t_transfer / 3600;
        if t_hrs > 24 then
            t_str = msprintf('%.2f days', t_hrs/24);
        else
            t_str = msprintf('%.2f hours', t_hrs);
        end
        set(findobj('tag', 'content_ht_result_5'), 'string', 'Transfer Time:   ' + t_str);

        if sys == 2 then
            set(findobj('tag', 'content_ht_result_6'), 'string', ..
                msprintf('Transfer SMA:    %.4f AU', result.a_transfer/const.AU));
        else
            set(findobj('tag', 'content_ht_result_6'), 'string', ..
                msprintf('Transfer SMA:    %.1f km', result.a_transfer));
        end
        set(findobj('tag', 'content_ht_result_7'), 'string', ..
            msprintf('Transfer Ecc:    %.6f', result.e_transfer));
        set(findobj('tag', 'content_ht_result_8'), 'string', ..
            msprintf('Phase Angle:     %.2f deg', result.phase_angle_deg));
        set(findobj('tag', 'content_ht_result_9'), 'string', ..
            msprintf('Transfer Energy: %.2f km^2/s^2', result.energy_transfer));
        set(findobj('tag', 'content_ht_result_10'), 'string', 'Type: Optimal 2-Impulse');

        ph = findobj('tag', 'content_ht_plot_placeholder');
        if ph <> [] then
            for p_idx = 1:size(ph, "*")
                try delete(ph(p_idx)); catch try set(ph(p_idx), 'visible', 'off'); catch end end
            end
        end
        plot_hohmann_orbit(r1, r2, result);

    else
        [r_int, oki, mi] = gui_get_positive_num('content_ht_r_int', 'Intermediate Radius');
        if ~oki then gui_report_error(mi); return; end

        if sys == 2 then r_int = r_int * const.AU; end

        if r_int < max(r1, r2) then
            gui_report_error(msprintf("Intermediate radius (%g) must be >= max(r1, r2) = %g.", r_int, max(r1, r2)));
            return;
        end

        try
            result = bielliptic_transfer(r1, r2, r_int, mu);
        catch
            gui_report_error("Failed to compute Bi-Elliptic transfer: " + lasterror());
            return;
        end

        set(findobj('tag', 'content_ht_result_1'), 'string', ..
            msprintf('Delta-V1 (1st burn): %.4f km/s', result.dv1));
        set(findobj('tag', 'content_ht_result_2'), 'string', ..
            msprintf('Delta-V2 (2nd burn): %.4f km/s', result.dv2));
        set(findobj('tag', 'content_ht_result_3'), 'string', ..
            msprintf('Delta-V3 (3rd burn): %.4f km/s', result.dv3));
        set(findobj('tag', 'content_ht_result_4'), 'string', ..
            msprintf('Delta-V Total:       %.4f km/s', result.dv_total));

        t_hrs = result.t_total / 3600;
        if t_hrs > 24 then
            t_str = msprintf('%.2f days', t_hrs/24);
        else
            t_str = msprintf('%.2f hours', t_hrs);
        end
        set(findobj('tag', 'content_ht_result_5'), 'string', 'Transfer Time:   ' + t_str);
        set(findobj('tag', 'content_ht_result_6'), 'string', ..
            msprintf('SMA1: %.0f, SMA2: %.0f', result.a1, result.a2));
        set(findobj('tag', 'content_ht_result_7'), 'string', ..
            msprintf('Ratio r2/r1:     %.2f', result.ratio));
        set(findobj('tag', 'content_ht_result_8'), 'string', ..
            msprintf('Hohmann Delta-V: %.4f km/s', result.dv_hohmann));
        set(findobj('tag', 'content_ht_result_9'), 'string', ..
            msprintf('Delta-V Savings: %.4f km/s', result.dv_savings));

        if result.is_better then
            set(findobj('tag', 'content_ht_result_10'), 'string', ..
                '[OK] Bi-elliptic is MORE efficient!');
        else
            set(findobj('tag', 'content_ht_result_10'), 'string', ..
                '[NO] Hohmann is more efficient');
        end

        ph = findobj('tag', 'content_ht_plot_placeholder');
        if ph <> [] then
            for p_idx = 1:size(ph, "*")
                try delete(ph(p_idx)); catch try set(ph(p_idx), 'visible', 'off'); catch end end
            end
        end
        plot_bielliptic_orbit(r1, r2, r_int, result);
    end

    update_status('Transfer calculation completed successfully.');
endfunction


function plot_hohmann_orbit(r1, r2, result)
    a = gui_create_plot_axes([0.32, 0.10, 0.64, 0.82]);
    a.isoview = 'on';

    theta = linspace(0, 2*%pi, 200);

    plot(r1 * cos(theta), r1 * sin(theta), 'b-', 'LineWidth', 1.5);
    plot(r2 * cos(theta), r2 * sin(theta), 'r-', 'LineWidth', 1.5);

    a_t = result.a_transfer;
    e_t = result.e_transfer;
    theta_t = linspace(0, %pi, 200);
    r_t = a_t * (1 - e_t^2) ./ (1 + e_t * cos(theta_t));
    plot(r_t .* cos(theta_t), r_t .* sin(theta_t), 'g--', 'LineWidth', 2.5);

    // central body
    plot(0, 0, 'yo', 'MarkerSize', 12, 'MarkerFaceColor', [1, 0.8, 0]);

    // burn points: departure at (r_smaller, 0), arrival at (-r_larger, 0)
    r_small = min(r1, r2);
    r_large = max(r1, r2);
    plot(r_small, 0, 'b^', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    plot(-r_large, 0, 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

    legend(['Initial Orbit', 'Final Orbit', 'Transfer Orbit'], 'in_upper_left');
    title('Hohmann Transfer Orbit Diagram (2-Burn)');
    xlabel('x [km]');
    ylabel('y [km]');
endfunction


function plot_bielliptic_orbit(r1, r2, r_int, result)
    a = gui_create_plot_axes([0.32, 0.10, 0.64, 0.82]);
    a.isoview = 'on';

    theta = linspace(0, 2*%pi, 200);

    // Initial and final circular orbits
    plot(r1 * cos(theta), r1 * sin(theta), 'b-', 'LineWidth', 1.5);
    plot(r2 * cos(theta), r2 * sin(theta), 'r-', 'LineWidth', 1.5);

    // Transfer ellipse 1: periapsis at r1, apoapsis at r_int
    a1 = result.a1;
    e1 = (r_int - r1) / (r_int + r1);
    theta_t1 = linspace(0, %pi, 200);
    r_t1 = a1 * (1 - e1^2) ./ (1 + e1 * cos(theta_t1));
    plot(r_t1 .* cos(theta_t1), r_t1 .* sin(theta_t1), 'g--', 'LineWidth', 2.0);

    // Transfer ellipse 2: apoapsis at r_int, periapsis at r2
    a2 = result.a2;
    e2 = (r_int - r2) / (r_int + r2);
    theta_t2 = linspace(%pi, 2*%pi, 200);
    r_t2 = a2 * (1 - e2^2) ./ (1 + e2 * cos(theta_t2));
    plot(r_t2 .* cos(theta_t2), r_t2 .* sin(theta_t2), 'm--', 'LineWidth', 2.0);

    // Central body
    plot(0, 0, 'yo', 'MarkerSize', 12, 'MarkerFaceColor', [1, 0.8, 0]);

    // Burn markers
    plot(r1, 0, 'b^', 'MarkerSize', 9, 'MarkerFaceColor', 'b');        // Burn 1
    plot(-r_int, 0, 'kd', 'MarkerSize', 10, 'MarkerFaceColor', [0.8, 0.5, 0]); // Burn 2 (Apoapsis)
    plot(r2, 0, 'rv', 'MarkerSize', 9, 'MarkerFaceColor', 'r');        // Burn 3

    legend(['Initial Orbit', 'Final Orbit', 'Transfer Ellipse 1', 'Transfer Ellipse 2'], 'in_upper_left');
    title(msprintf('Bi-Elliptic Transfer: r1=%.0f, r2=%.0f, r_int=%.0f km', r1, r2, r_int));
    xlabel('x [km]');
    ylabel('y [km]');
endfunction
