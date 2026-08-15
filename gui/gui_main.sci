// OrbitalMDT :: Main GUI Window & Tab Management

function launch_orbital_mdt()

    // close any existing OrbitalMDT windows
    existing = winsid();
    for w = existing
        try
            f = scf(w);
            if isfield(f.user_data, 'app_id') then
                if f.user_data.app_id == 'OrbitalMDT' then
                    close(f);
                end
            end
        catch
        end
    end

    fig = figure( ..
        'figure_name', 'OrbitalMDT -- Orbital Mechanics Mission Design Toolkit', ..
        'position', [50, 50, 1200, 800], ..
        'background', -2, ..
        'tag', 'main_fig');

    fig.user_data = struct('app_id', 'OrbitalMDT', 'current_tab', 1);

    // --- Title bar (background first, then text on top) ---
    uicontrol(fig, ..
        'style', 'text', ..
        'string', '', ..
        'position', [0, 750, 1200, 45], ..
        'background', [0.1, 0.1, 0.2], ..
        'tag', 'title_bg');

    uicontrol(fig, ..
        'style', 'text', ..
        'string', '[OrbitalMDT] -- Mission Design Toolkit', ..
        'position', [10, 755, 600, 35], ..
        'fontsize', 16, ..
        'fontweight', 'bold', ..
        'horizontalalignment', 'left', ..
        'background', [0.1, 0.1, 0.2], ..
        'foreground', [0.9, 0.9, 1.0], ..
        'tag', 'title_text');

    uicontrol(fig, ..
        'style', 'text', ..
        'string', 'Professional Orbital Mechanics Analysis Suite', ..
        'position', [620, 755, 570, 35], ..
        'fontsize', 11, ..
        'horizontalalignment', 'right', ..
        'background', [0.1, 0.1, 0.2], ..
        'foreground', [0.6, 0.6, 0.8], ..
        'tag', 'title_sub');

    // --- Tab buttons ---
    tab_names = ['Mission Planner', 'Transfers', 'Lambert Solver', ..
                 'Propagator', 'Solar System', 'Rocket Eq.', 'Re-Entry'];
    tab_colors = [
        0.2, 0.4, 0.8;
        0.2, 0.7, 0.3;
        0.8, 0.4, 0.1;
        0.6, 0.2, 0.8;
        0.8, 0.7, 0.1;
        0.8, 0.2, 0.2;
        0.2, 0.7, 0.7
    ];

    tab_width = 160;
    tab_x0 = 15;

    for k = 1:7
        x_pos = tab_x0 + (k - 1) * (tab_width + 5);
        btn = uicontrol(fig, ..
            'style', 'pushbutton', ..
            'string', tab_names(k), ..
            'position', [x_pos, 710, tab_width, 35], ..
            'fontsize', 11, ..
            'fontweight', 'bold', ..
            'tag', 'tab_btn_' + string(k), ..
            'callback', 'switch_tab(' + string(k) + ')');

        if k == 1 then
            set(btn, 'backgroundcolor', tab_colors(k,:));
            set(btn, 'foregroundcolor', [1, 1, 1]);
        else
            set(btn, 'backgroundcolor', [0.85, 0.85, 0.85]);
            set(btn, 'foregroundcolor', [0.3, 0.3, 0.3]);
        end
    end

    // --- Content frame ---
    uicontrol(fig, ..
        'style', 'frame', ..
        'position', [5, 5, 1190, 700], ..
        'tag', 'content_frame', ..
        'background', [0.95, 0.95, 0.97]);

    // --- Status bar ---
    uicontrol(fig, ..
        'style', 'text', ..
        'string', ' Ready | Tab: Mission Planner', ..
        'position', [0, 0, 1200, 20], ..
        'fontsize', 9, ..
        'horizontalalignment', 'left', ..
        'background', [0.15, 0.15, 0.25], ..
        'foreground', [0.7, 0.7, 0.9], ..
        'tag', 'status_bar');

    fig.user_data.tab_colors = tab_colors;
    fig.user_data.tab_names  = tab_names;

    build_mission_planner_tab(fig);
endfunction


function switch_tab(tab_id)

    fig = gcf();
    tab_colors = fig.user_data.tab_colors;
    tab_names  = fig.user_data.tab_names;

    for k = 1:7
        btn = findobj('tag', 'tab_btn_' + string(k));
        if btn <> [] then
            if k == tab_id then
                set(btn, 'backgroundcolor', tab_colors(k,:));
                set(btn, 'foregroundcolor', [1, 1, 1]);
            else
                set(btn, 'backgroundcolor', [0.85, 0.85, 0.85]);
                set(btn, 'foregroundcolor', [0.3, 0.3, 0.3]);
            end
        end
    end

    // delete content_ tagged children and axes
    all_children = fig.children;
    del_list = [];
    for idx = 1:length(all_children)
        ch = all_children(idx);
        try
            if typeof(ch) == 'uicontrol' then
                tg = get(ch, 'tag');
                if length(tg) > 8 then
                    if part(tg, 1:8) == 'content_' then
                        del_list = [del_list, idx];
                    end
                end
            elseif typeof(ch) == 'Axes' then
                del_list = [del_list, idx];
            end
        catch
        end
    end
    for idx = del_list($:-1:1)
        delete(all_children(idx));
    end

    status = findobj('tag', 'status_bar');
    if status <> [] then
        set(status, 'string', ' Ready | Tab: ' + tab_names(tab_id));
    end

    select tab_id
    case 1, build_mission_planner_tab(fig);
    case 2, build_hohmann_tab(fig);
    case 3, build_lambert_tab(fig);
    case 4, build_propagator_tab(fig);
    case 5, build_solarsystem_tab(fig);
    case 6, build_rocket_tab(fig);
    case 7, build_reentry_tab(fig);
    end

    fig.user_data.current_tab = tab_id;
endfunction


function update_status(msg)
    status = findobj('tag', 'status_bar');
    if status <> [] then
        set(status, 'string', ' ' + msg);
    end
endfunction
