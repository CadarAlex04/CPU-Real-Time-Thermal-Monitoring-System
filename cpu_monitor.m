function cpu_monitor()
    % --- GUI WINDOW CONFIGURATION ---
    % Initializes the main application window with a dark theme
    fig = uifigure('Name', 'CPU Real-Time Thermal Monitoring System ', 'Color', [0.1 0.1 0.12], 'Position', [100 100 1100 650]);
    
    % --- UI LAYOUT PANELS ---
    % Sidebar for user inputs and control buttons
    sidePanel = uipanel(fig, 'Title', 'CONTROL', 'BackgroundColor', [0.18 0.18 0.22], 'ForegroundColor', 'w', 'Position', [20 20 180 610]);
    % Right panel for displaying real-time aggregated metrics
    statsPanel = uipanel(fig, 'Title', 'STATISTICS', 'BackgroundColor', [0.18 0.18 0.22], 'ForegroundColor', 'w', 'Position', [890 20 190 610]);
    
    % --- IMAGE COMPONENT (JPG LOGO) ---
    % Displays a hardware-related image to enhance the visual interface
    axImg = uiaxes(sidePanel, 'Position', [5 470 175 110], 'BackgroundColor', [0.18 0.18 0.22]);
    try
        img = imread('cpu_info.jpg'); 
        imshow(img, 'Parent', axImg);
        axis(axImg, 'tight'); 
    catch
        % Fallback title if image file is missing
        title(axImg, 'System Active', 'Color', [0.4 0.4 0.4]);
    end
    axis(axImg, 'off');

    % --- INTERACTIVE PARAMETERS (USER MODIFIABLE) ---
    % Thermal Alert Threshold: Triggers visual changes when reached
    uilabel(sidePanel, 'Text', 'Alert Limit (°C):', 'Position', [10 240 160 20], 'FontColor', 'w');
    editLimit = uieditfield(sidePanel, 'numeric', 'Position', [10 215 160 25], 'Value', 85, 'BackgroundColor', [0.25 0.25 0.3], 'FontColor', 'w');

    % Data Refresh Rate: Controls the sampling frequency of the JSON feed
    uilabel(sidePanel, 'Text', 'Refresh Rate (sec):', 'Position', [10 170 160 20], 'FontColor', 'w');
    editSpeed = uieditfield(sidePanel, 'numeric', 'Position', [10 145 160 25], 'Value', 0.5, 'Limits', [0.1 10], 'BackgroundColor', [0.25 0.25 0.3], 'FontColor', 'w');

    % --- MAIN DISPLAY COMPONENTS ---
    % Dynamic Title showing the current temperature
    lblTitle = uilabel(fig, 'Text', 'CPU Temperature: -- °C', 'Position', [220 580 650 50], 'FontSize', 28, 'FontWeight', 'bold', 'FontColor', [0 0.8 1], 'HorizontalAlignment', 'center');
    
    % Linear Gauge for a quick visual status check
    gauge = uigauge(fig, 'linear', 'Position', [220 20 650 70], 'BackgroundColor', [0.1 0.1 0.12], 'FontColor', 'w');
    gauge.Limits = [30 100];
    gauge.ScaleColors = {'#00FF00', '#FFA500', '#FF0000'};
    gauge.ScaleColorLimits = [30 60; 60 85; 85 100];

    % --- STATISTICS LABELS ---
    % Displays peak, lowest, and mean temperatures during the session
    valMax = uilabel(statsPanel, 'Text', '-- °C', 'Position', [10 480 150 50], 'FontSize', 24, 'FontColor', 'w', 'HorizontalAlignment', 'center');
    uilabel(statsPanel, 'Text', 'MAXIMUM', 'Position', [10 530 150 20], 'FontColor', [1 0.3 0.3], 'HorizontalAlignment', 'center');
    
    valMin = uilabel(statsPanel, 'Text', '-- °C', 'Position', [10 350 150 50], 'FontSize', 24, 'FontColor', 'w', 'HorizontalAlignment', 'center');
    uilabel(statsPanel, 'Text', 'MINIMUM', 'Position', [10 400 150 20], 'FontColor', [0.3 1 0.3], 'HorizontalAlignment', 'center');
    
    valAvg = uilabel(statsPanel, 'Text', '-- °C', 'Position', [10 220 150 50], 'FontSize', 24, 'FontColor', 'w', 'HorizontalAlignment', 'center');
    uilabel(statsPanel, 'Text', 'AVERAGE', 'Position', [10 270 150 20], 'FontColor', [0.3 0.7 1], 'HorizontalAlignment', 'center');

    % --- MAIN REAL-TIME GRAPH ---
    % Plotting area for the thermal evolution over time
    ax = uiaxes(fig, 'Position', [220 120 650 450], 'BackgroundColor', [0.12 0.12 0.15], 'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6]);
    grid(ax, 'on'); hold(ax, 'on');
    hLine = plot(ax, 0, 0, 'Color', [0 0.8 1], 'LineWidth', 2.5);

    % --- CONTROL BUTTONS ---
    btnStart = uibutton(sidePanel, 'text', '▶ START', 'Position', [10 400 160 40], 'BackgroundColor', [0.2 0.6 0.2], 'FontColor', 'w');
    btnDoc   = uibutton(sidePanel, 'text', 'DOCUMENTATION', 'Position', [10 350 160 40], 'BackgroundColor', [0.3 0.3 0.35], 'FontColor', 'w');
    btnExit  = uibutton(sidePanel, 'text', '✖ EXIT', 'Position', [10 20 160 40], 'BackgroundColor', [0.7 0.2 0.2], 'FontColor', 'w');

    % --- STATE VARIABLES ---
    isRunning = false; % Tracks monitoring status
    allTemps = [];    % Buffer to store all historical readings

    % --- CALLBACK ASSIGNMENTS ---
    btnExit.ButtonPushedFcn = @(src, event) delete(fig);
    btnDoc.ButtonPushedFcn = @(src, event) showDoc();
    btnStart.ButtonPushedFcn = @(src, event) toggleStart();

  function showDoc()
        % Defines the name of the documentation file
        pdfFileName = 'Documentatie_CadarAlexDumitru.pdf'; 
        
        % Checks if the file exists in the current folder before trying to open it
        if exist(pdfFileName, 'file')
            % Opens the PDF with the system's default viewer (e.g., Adobe, Edge, etc.)
            winopen(pdfFileName); 
        else
            % Shows an error message if the file is missing
            uialert(fig, 'Docum entation file not found in the project folder.', ...
                'File Error', 'Icon', 'error');
        end
    end

    function toggleStart()
        % Manages the Start/Stop toggle logic and UI feedback
        if isRunning
            isRunning = false;
            btnStart.Text = '▶ RESTART';
            btnStart.BackgroundColor = [0.2 0.6 0.2];
        else
            isRunning = true;
            btnStart.Text = '⬛ STOP';
            btnStart.BackgroundColor = [0.6 0.4 0.2];
            allTemps = []; % Clear history on new run
            set(hLine, 'XData', [], 'YData', []);
            startMonitoring();
        end
    end

    function startMonitoring()
        % Main loop for fetching and processing thermal data
        url = 'http://127.0.0.1:8085/data.json';
        opt = weboptions('Timeout', 2);
        t_start = datetime('now');
        
        while isRunning && ishandle(fig)
            try
                % Fetch data from Libre Hardware Monitor
                data = webread(url, opt);
                tempVal = getSpecificTemp(data, 'Core Average');
                
                if ~isempty(tempVal)
                    t_now = datetime('now');
                    elapsed = seconds(t_now - t_start);
                    allTemps(end+1) = tempVal;
                    
                    % Update Graph (Plot)
                    set(hLine, 'XData', [hLine.XData, elapsed], 'YData', [hLine.YData, tempVal]);
                    % Automatic X-axis sliding window (last 60 seconds)
                    if elapsed > 60, ax.XLim = [elapsed-60, elapsed]; end
                    
                    % Update Statistics (Calculated Values)
                    valMax.Text = sprintf('%.1f °C', max(allTemps));
                    valMin.Text = sprintf('%.1f °C', min(allTemps));
                    valAvg.Text = sprintf('%.1f °C', mean(allTemps));
                    
                    % Update Header and Gauge display
                    lblTitle.Text = sprintf('CPU Temperature: %.1f °C', tempVal);
                    gauge.Value = tempVal;
                    
                    % THRESHOLD CHECK (Safety Index Logic)
                    % Visual alert triggers if temperature exceeds user-defined limit
                    if tempVal >= editLimit.Value
                        lblTitle.FontColor = [1 0.3 0.3]; % Red alert
                        hLine.Color = [1 0.3 0.3];
                    else
                        lblTitle.FontColor = [0 0.8 1]; % Cool blue status
                        hLine.Color = [0 0.8 1];
                    end
                end
            catch
                % Silently catch connection drops to prevent script crashing
            end
            drawnow;
            % Wait for the next sampling cycle (Adjustable via GUI)
            pause(editSpeed.Value); 
        end
    end
end

% --- RECURSIVE DATA PARSING FUNCTION ---
function val = getSpecificTemp(node, targetName)
    % Recursively searches through the JSON tree to find hardware sensor values
    val = [];
    % Base case: Check if current node is the target sensor
    if isfield(node, 'Text') && isfield(node, 'Value')
        if strcmp(node.Text, targetName) && contains(node.Value, '°C')
            str = extractBefore(node.Value, " ");
            val = str2double(strrep(str, ',', '.'));
            return;
        end
    end
    % Recursive case: Traverse child nodes in the JSON structure
    if isfield(node, 'Children')
        c = node.Children;
        if iscell(c)
            for i = 1:length(c)
                val = getSpecificTemp(c{i}, targetName);
                if ~isempty(val), return; end
            end
        elseif isstruct(c)
            for i = 1:length(c)
                val = getSpecificTemp(c(i), targetName);
                if ~isempty(val), return; end
            end
        end
    end
end