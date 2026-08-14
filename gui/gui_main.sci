// ============================================================================
// OrbitalMDT — Main GUI Window & Tab Management
// ============================================================================
// Creates the main application window with tabbed interface.
// ============================================================================

function launch_orbital_mdt()
    // Main entry point for the GUI application
    
    // Close any existing OrbitalMDT windows
    existing = winsid();
    for w = existing
        f = scf(w);
        if isfield(f.user_data, 'app_id') then
            if f.user_data.app_id == 'OrbitalMDT' then
                close(f);
            end
        end
    end
    
    // ---- Create Main Figure ----
    fig = figure(...
        'figure_name', 'OrbitalMDT — Orbital Mechanics Mission Design Toolkit', ...
        'position', [50, 50, 1200, 800], ...
        'background', -2, ...
        'tag', 'main_fig');
    
    fig.user_data = struct('app_id', 'OrbitalMDT', 'current_tab', 1);
    
    // ---- Title Bar ----
    uicontrol(fig, ...
        'style', 'text', ...
        'string', '🚀 OrbitalMDT — Mission Design Toolkit', ...
        'position', [10, 755, 600, 35], ...
        'fontsize', 16, ...
        'fontweight', 'bold', ...
        'horizontalalignment', 'left', ...
        'background', [0.1, 0.1, 0.2], ...
        'foreground', [0.9, 0.9, 1.0]);
    
    uicontrol(fig, ...
        'style', 'text', ...
        'string', 'Professional Orbital Mechanics Analysis Suite', ...
        'position', [620, 755, 570, 35], ...
        'fontsize', 11, ...
        'horizontalalignment', 'right', ...
        'background', [0.1, 0.1, 0.2], ...
        'foreground', [0.6, 0.6, 0.8]);
    
    // Full-width title background
    uicontrol(fig, ...
        'style', 'text', ...
        'string', '', ...
        'position', [0, 750, 1200, 45], ...
        'background', [0.1, 0.1, 0.2]);
    
    // ---- Tab Buttons ----
    tab_names = ['Mission Planner', 'Transfers', 'Lambert Solver', ...
                 'Propagator', 'Solar System', 'Rocket Eq.', 'Re-Entry'];
    tab_colors = [
        0.2, 0.4, 0.8;    // Blue
        0.2, 0.7, 0.3;    // Green
        0.8, 0.4, 0.1;    // Orange
        0.6, 0.2, 0.8;    // Purple
        0.8, 0.7, 0.1;    // Gold
        0.8, 0.2, 0.2;    // Red
        0.2, 0.7, 0.7     // Teal
    ];
    
    tab_width = 160;
    tab_x_start = 15;
    
    for k = 1:7
        x_pos = tab_x_start + (k-1) * (tab_width + 5);
        
        btn = uicontrol(fig, ...
            'style', 'pushbutton', ...
            'string', tab_names(k), ...
            'position', [x_pos, 710, tab_width, 35], ...
            'fontsize', 11, ...
            'fontweight', 'bold', ...
            'tag', 'tab_btn_' + string(k), ...
            'callback', 'switch_tab(' + string(k) + ')');
        
        if k == 1 then
            set(btn, 'background', tab_colors(k,:));
            set(btn, 'foreground', [1, 1, 1]);
        else
            set(btn, 'background', [0.85, 0.85, 0.85]);
            set(btn, 'foreground', [0.3, 0.3, 0.3]);
        end
    end
    
    // ---- Content Frame (placeholder) ----
    uicontrol(fig, ...
        'style', 'frame', ...
        'position', [5, 5, 1190, 700], ...
        'tag', 'content_frame', ...
        'background', [0.95, 0.95, 0.97]);
    
    // ---- Status Bar ----
    uicontrol(fig, ...
        'style', 'text', ...
        'string', ' Ready | Tab: Mission Planner', ...
        'position', [0, 0, 1200, 20], ...
        'fontsize', 9, ...
        'horizontalalignment', 'left', ...
        'background', [0.15, 0.15, 0.25], ...
        'foreground', [0.7, 0.7, 0.9], ...
        'tag', 'status_bar');
    
    // Store tab data
    fig.user_data.tab_colors = tab_colors;
    fig.user_data.tab_names = tab_names;
    
    // Load first tab
    build_mission_planner_tab(fig);
    
endfunction


function switch_tab(tab_id)
    // Switch between tabs
    
    fig = gcf();
    
    // Update tab button colors
    tab_colors = fig.user_data.tab_colors;
    tab_names = fig.user_data.tab_names;
    
    for k = 1:7
        btn = findobj('tag', 'tab_btn_' + string(k));
        if k == tab_id then
            set(btn, 'background', tab_colors(k,:));
            set(btn, 'foreground', [1, 1, 1]);
        else
            set(btn, 'background', [0.85, 0.85, 0.85]);
            set(btn, 'foreground', [0.3, 0.3, 0.3]);
        end
    end
    
    // Clear content area - delete all children with 'content_' tag prefix
    all_children = fig.children;
    for ch = all_children
        if typeof(ch) == 'uicontrol' then
            tag = get(ch, 'tag');
            if length(tag) > 8 & part(tag, 1:8) == 'content_' then
                delete(ch);
            end
        end
    end
    
    // Update status
    status = findobj('tag', 'status_bar');
    set(status, 'string', ' Ready | Tab: ' + tab_names(tab_id));
    
    // Build selected tab
    select tab_id
    case 1
        build_mission_planner_tab(fig);
    case 2
        build_hohmann_tab(fig);
    case 3
        build_lambert_tab(fig);
    case 4
        build_propagator_tab(fig);
    case 5
        build_solarsystem_tab(fig);
    case 6
        build_rocket_tab(fig);
    case 7
        build_reentry_tab(fig);
    end
    
    fig.user_data.current_tab = tab_id;
    
endfunction


function update_status(msg)
    // Update status bar message
    status = findobj('tag', 'status_bar');
    if status <> [] then
        set(status, 'string', ' ' + msg);
    end
endfunction
