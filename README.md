# CPU-Real-Time-Thermal-Monitoring-System
A high-performance MATLAB-based dashboard designed to provide real-time thermal analysis and hardware health monitoring. This application interfaces with the Libre Hardware Monitor web server to visualize CPU metrics through a modern, dark-themed GUI.


## Features:

 - Real-Time Visualization: Live line charts and gauges for instantaneous temperature tracking.
 - Recursive JSON Parsing: Custom-built algorithm to traverse complex hardware data trees and extract specific sensor values.
 - Dynamic Statistics: Automatically calculates session-based Minimum, Maximum, and Average temperatures.
 - Custom Alerts: User-definable thermal thresholds that trigger visual UI changes (color shifts) when the CPU exceeds safe limits.
 - Adjustable Sampling: Real-time control over the data refresh rate (0.1s to 10s).

 ## Prerequisites
To run this application, you need:
  - MATLAB (R2020a or newer recommended).
  - Libre Hardware Monitor: This acts as the data source.
  - Download it [here](https://www.bing.com/search?q=libre%20hardware%20monitor&qs=n&form=QBRE&sp=-1&ghc=1&lq=0&pq=libre%20hardware%20monitor&sc=12-22&sk=&cvid=F5515B9EC69E4EBCA34FA61E450ABA0E).
  - Crucial Step: Once opened, go to Options -> Remote Web Server -> Run.
  - Ensure the server is running on the default port 8085.


 ## Project Structure
 - cpu_monitor.m - The main application logic and UI layout.
 - cpu_info.jpg - Branding/logo asset for the sidebar.
 - Documemtation.pdf - Detailed technical documentation.


  ## Technical Implementation Details
### Data Flow
The system follows a Request-Parse-Visualize pipeline:
  - Request: Uses MATLAB's webread to fetch JSON data from the local REST API provided by Libre Hardware Monitor.
  - Parse: Implements a recursive search function getSpecificTemp to locate the "Core Average" sensor within the nested JSON structure.
  - Visualize: Updates the UIAxes and UIGauge components using a high-frequency timer loop.
```
// Example of the recursive parsing logic used:
function val = getSpecificTemp(node, targetName)
    // Recursively searches the hardware tree
    if strcmp(node.Text, targetName)
        // Logic to extract and convert string value to double
    end
end
```

## How to Run
  - Clone the repository:
   ```git clone https://github.com/yourusername/cpu-thermal-monitor.git ```
  - Open Libre Hardware Monitor and start the Remote Web Server.
  - Open cpu_monitor.m in MATLAB.
  - Run the script and click START in the GUI.

  ## Application Preview
See the CPU Real-Time Thermal Monitoring System in action:
<img width="1644" height="970" alt="preview" src="https://github.com/user-attachments/assets/77230c0f-2b96-432c-8691-aab6541f90b6" />
