// OrbitalMDT :: Solar System Viewer Tab

function build_solarsystem_tab(fig)

    win_w = 1200; win_h = 800;
    try win_w = fig.axes_size(1); win_h = fig.axes_size(2); catch end

    y_base = win_h - 780;
    x_panel = 15;
    pw = 290;

    uicontrol(fig, 'style', 'text', 'string', '[*] SOLAR SYSTEM VIEWER', ..
        'position', [x_panel, y_base+660, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.8, 0.7, 0.1], 'tag', 'content_ss_title');

    uicontrol(fig, 'style', 'text', 'string', 'Date (YYYY MM DD):', ..
        'position', [x_panel, y_base+630, 150, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ss_lbl1');
    uicontrol(fig, 'style', 'edit', 'string', '2026 8 15', ..
        'position', [x_panel+150, y_base+628, 125, 25], 'fontsize', 10, ..
        'tag', 'content_ss_date');

    uicontrol(fig, 'style', 'text', 'string', 'View:', ..
        'position', [x_panel, y_base+598, 50, 20], 'fontsize', 10, ..
        'horizontalalignment', 'left', 'tag', 'content_ss_lbl2');
    uicontrol(fig, 'style', 'popupmenu', ..
        'string', 'Inner Planets (Mer-Mars)|Outer Planets (Jup-Sat)|Full System|Top-Down (2D)', ..
        'position', [x_panel+50, y_base+596, 225, 25], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_ss_view');

    uicontrol(fig, 'style', 'checkbox', 'string', ' Show orbit paths', ..
        'position', [x_panel, y_base+568, 200, 22], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_ss_orbits');
    uicontrol(fig, 'style', 'checkbox', 'string', ' Show planet labels', ..
        'position', [x_panel, y_base+545, 200, 22], 'fontsize', 10, ..
        'value', 1, 'tag', 'content_ss_labels');

    uicontrol(fig, 'style', 'pushbutton', 'string', 'RENDER SOLAR SYSTEM', ..
        'position', [x_panel, y_base+505, pw, 35], ..
        'fontsize', 12, 'fontweight', 'bold', ..
        'background', [0.8, 0.7, 0.1], 'foreground', [0.1, 0.1, 0.1], ..
        'callback', 'cb_render_solar_system()', 'tag', 'content_ss_render');

    uicontrol(fig, 'style', 'text', 'string', '[*] PLANET POSITIONS (AU)', ..
        'position', [x_panel, y_base+475, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.7, 0.6, 0.0], 'tag', 'content_ss_info_title');

    pnames = ['Mercury', 'Venus', 'Earth', 'Mars', 'Jupiter', 'Saturn'];
    for k = 1:6
        uicontrol(fig, 'style', 'text', 'string', pnames(k) + ':  --', ..
            'position', [x_panel, y_base+475-k*25, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_ss_planet_' + string(k));
    end

    uicontrol(fig, 'style', 'text', 'string', '[*] DISTANCES FROM EARTH', ..
        'position', [x_panel, y_base+310, pw, 22], ..
        'fontsize', 11, 'fontweight', 'bold', 'horizontalalignment', 'left', ..
        'foreground', [0.7, 0.6, 0.0], 'tag', 'content_ss_dist_title');

    for k = 1:6
        uicontrol(fig, 'style', 'text', 'string', pnames(k) + ':  --', ..
            'position', [x_panel, y_base+310-k*22, pw, 20], ..
            'fontsize', 9, 'horizontalalignment', 'left', ..
            'fontname', 'Consolas', 'tag', 'content_ss_dist_' + string(k));
    end

    uicontrol(fig, 'style', 'pushbutton', 'string', 'Show Sphere of Influence (SOI)', ..
        'position', [x_panel, y_base+145, pw, 28], 'fontsize', 10, ..
        'callback', 'cb_show_soi()', 'tag', 'content_ss_soi_btn');

    // Model Assumptions Banner
    uicontrol(fig, 'style', 'text', ..
        'string', 'Assumptions: Standish (1992) Analytical Ephemerides, Heliocentric Ecliptic J2000', ..
        'position', [x_panel, y_base+122, pw, 18], 'fontsize', 8, ..
        'horizontalalignment', 'left', 'foreground', [0.5, 0.5, 0.5], ..
        'tag', 'content_ss_assumptions');

    plot_w = max(400, win_w - 330);
    uicontrol(fig, 'style', 'text', ..
        'string', 'Solar system view will appear here', ..
        'position', [310, floor(win_h / 2) - 20, plot_w, 40], 'fontsize', 14, ..
        'horizontalalignment', 'center', 'foreground', [0.5, 0.5, 0.6], ..
        'tag', 'content_ss_plot_placeholder');
endfunction


function cb_render_solar_system()

    const = orbital_constants();

    date_str = get_tag_str('content_ss_date', '2026 8 15');
    [y, m, d, ok, msg] = parse_date_str(date_str);
    if ~ok then
        gui_report_error(msg);
        return;
    end

    JD = date_to_jd(y, m, d);

    try
        positions = solar_system_state(JD);
    catch
        gui_report_error("Failed to compute planetary ephemeris: " + lasterror());
        return;
    end

    AU = const.AU;

    for k = 1:6
        r_au = norm(positions(:, k)) / AU;
        set(findobj('tag', 'content_ss_planet_' + string(k)), 'string', ..
            msprintf('%s: %.3f AU', const.planet_names(k), r_au));
    end

    r_earth = positions(:, 3);
    for k = 1:6
        dist_km = norm(positions(:,k) - r_earth);
        dist_au = dist_km / AU;
        light_min = dist_km / 299792.458 / 60;
        set(findobj('tag', 'content_ss_dist_' + string(k)), 'string', ..
            msprintf('%s: %.3f AU (%.1f lm)', const.planet_names(k), dist_au, light_min));
    end

    ph = findobj('tag', 'content_ss_plot_placeholder');
    if ph <> [] then
        for p_idx = 1:size(ph, "*")
            try delete(ph(p_idx)); catch try set(ph(p_idx), 'visible', 'off'); catch end end
        end
    end

    view_type = get(findobj('tag', 'content_ss_view'), 'value');
    show_orbits = get(findobj('tag', 'content_ss_orbits'), 'value');
    show_labels_val = get(findobj('tag', 'content_ss_labels'), 'value');

    a = gui_create_plot_axes([0.32, 0.10, 0.64, 0.82]);
    a.isoview = 'on';

    p_colors = [0.7,0.7,0.7; 0.9,0.8,0.4; 0.2,0.5,1.0; ..
                0.9,0.3,0.1; 0.8,0.6,0.3; 0.9,0.8,0.5];
    p_sizes = [6, 8, 9, 7, 14, 12];

    select view_type
    case 1, planets = 1:4; max_r = 2.5;
    case 2, planets = 5:6; max_r = 12;
    case 3, planets = 1:6; max_r = 12;
    case 4, planets = 1:4; max_r = 2.5;
    end

    // Sun
    plot(0, 0, 'o', 'MarkerSize', 15, 'MarkerFaceColor', [1, 0.9, 0]);

    // orbit paths
    if show_orbits == 1 then
        theta_orb = linspace(0, 2*%pi, 200);
        orbit_radii_AU = [0.387, 0.723, 1.000, 1.524, 5.203, 9.537];
        for k = planets
            x_orb = orbit_radii_AU(k) * cos(theta_orb);
            y_orb = orbit_radii_AU(k) * sin(theta_orb);
            plot(x_orb, y_orb, '--');
        end
    end

    // planets with staggered label placement
    label_angle_offsets = [0.2, 0.8, 1.4, 2.0, 0.5, 1.1] * %pi;
    for k = planets
        x_p = positions(1, k) / AU;
        y_p = positions(2, k) / AU;
        plot(x_p, y_p, 'o', 'MarkerSize', p_sizes(k), ..
            'MarkerFaceColor', p_colors(k,:), 'MarkerEdgeColor', p_colors(k,:));
        if show_labels_val == 1 then
            dx = 0.04 * max_r * cos(label_angle_offsets(k));
            dy = 0.04 * max_r * sin(label_angle_offsets(k));
            xstring(x_p + dx, y_p + dy, const.planet_names(k));
        end
    end

    gca().data_bounds = [-max_r, -max_r; max_r, max_r];

    [y_d, m_d, d_d] = jd_to_date(JD);
    title(msprintf('Solar System Configuration -- %d-%02d-%02d', y_d, floor(m_d), floor(d_d)));
    xlabel('X [AU]');
    ylabel('Y [AU]');

    update_status(msprintf('Solar system rendered for %d-%02d-%02d', y_d, floor(m_d), floor(d_d)));
endfunction


function cb_show_soi()
    const = orbital_constants();
    orbit_radii = [const.a_Mercury, const.a_Venus, const.a_Earth, ..
                   const.a_Mars, const.a_Jupiter, const.a_Saturn];

    msg = "Sphere of Influence (Laplace SOI) Radii:" + ascii(10) + ascii(10);
    for k = 1:6
        soi = sphere_of_influence(orbit_radii(k), const.mu_planets(k), const.mu_Sun);
        msg = msg + msprintf("%s:  %.0f km  (%.4f AU)" + ascii(10), ..
            const.planet_names(k), soi.r_soi, soi.r_soi_AU);
    end
    messagebox(msg, 'Sphere of Influence Radii', 'info');
endfunction
