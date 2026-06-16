
---

# High-Fidelity FCHEV Energy Management and Data-Driven SOH Prediction

## 📖 Project Overview
This repository contains a full-stack simulation and deep learning framework for Fuel Cell Hybrid Electric Vehicles (FCHEV). It bridges the gap between **high-fidelity multi-physics mechanistic modeling (MATLAB/Simulink)** and **data-driven prognostics (Python/PyTorch)**. 

The project aims to develop a health-conscious Energy Management System (EMS) and precisely predict the State of Health (SOH) degradation under realistic driving cycles (e.g., WLTC, FTP-75).

## ⚙️ System Architecture
The project is divided into three main phases:
1. **High-Fidelity Plant Modeling**: Electrochemical, thermodynamic, and degradation modeling.
2. **Hierarchical Control Strategy**: Fuzzy Logic EMS + Hysteresis Safety Override + PI Inner-loop.
3. **Data-Driven Prognostics**: LSTM-based time-series forecasting using difference prediction ($\Delta$SOH).

---

## 🛠️ Phase 1: High-Fidelity Plant Modeling (Simulink)
Unlike simplified first-order delay models, this plant model incorporates real-world physical constraints and multi-time scale dynamics.

*   **Electrochemical Polarization Model**: 
    Based on the Amphlett semi-empirical equations. It computes the real-time stack voltage by subtracting activation, ohmic, and concentration overvoltages from the open-circuit voltage (OCV). Safety saturation limits are implemented to prevent algebraic singularities at high currents.
*   **Air Compressor Dynamics & Parasitic Power (BOP)**: 
    A second-order polynomial is used to model the steady-state parasitic power of the compressor. A continuous transfer function $G(s) = \frac{1}{\tau_c s + 1}$ is applied to replicate the mechanical rotor inertia. This successfully reproduces the **"Oxygen Starvation (Power Sag)"** effect during severe transient load changes.
*   **Empirical Degradation Model**: 
    The SOH degradation rate ($\dot{D}$) is evaluated considering both steady-state deviation and transient stress:
    $$ \dot{D} = [k_0 + k_1(I - I_{opt})^2] + k_{trans} \left| \frac{dI}{dt} \right| $$
    A low-pass filter is applied to the derivative term to eliminate non-physical Dirac impulses during step changes.

---

## 🧠 Phase 2: Hierarchical Control Strategy (Simulink)
To manage power split and prolong stack lifetime, a dual-loop control architecture is designed.

### Upper-Level EMS: Fuzzy Logic + Hysteresis
*   **Fuzzy Logic Controller (FLC)**: Replaces hard rule-based strategies. It uses Battery SOC and Vehicle Power Demand ($P_{req}$) as inputs to generate smoothed Fuel Cell Power Commands ($P_{cmd}$), significantly reducing high-frequency current steps and mitigating transient degradation.
*   **Hysteresis Safety Override**: A state-machine logic (Memory-based) is added to enforce a hard shutdown when SOC exceeds 0.85 and restart below 0.80 during idling. This prevents battery overcharging and eliminates zero-crossing chattering in the solver.

### Inner-Level FCU: PI Tracking Control
*   A PI controller tracks the net power command by adjusting the extracted stack current.
*   **Algebraic Loop Decoupling**: A fast continuous low-pass filter (LPF, $\tau=0.05s$) is inserted in the feedback loop to break algebraic loops and eliminate high-frequency numerical chattering caused by saturation limits.

---

## 📈 Phase 3: Data-Driven SOH Prediction (PyTorch)
Using the WLTC driving cycle, real-time operating data (Current, Voltage, Net Power) and SOH degradation curves were generated and exported to Python for deep learning prognostics.

### LSTM Architecture & Difference Prediction Strategy
*   **Addressing Domain Shift**: Traditional absolute-value predictions often fail (extrapolation failure) when the test set SOH values are lower than the training set. 
*   **Delta SOH ($\Delta$SOH)**: The model is refactored to predict the *degradation rate* (single-step difference of SOH) rather than the absolute SOH. 
*   **Network Design**: A 2-layer Long Short-Term Memory (LSTM) network with Dropout and L2 Regularization (Weight Decay) to prevent overfitting. `StandardScaler` (Z-score normalization) is used for feature scaling.
*   **Results**: The absolute SOH trajectory is reconstructed via cumulative summation (`np.cumsum`) of the predicted $\Delta$SOH. The model achieves high-fidelity tracking on the unseen test dataset with negligible cumulative drift.

---

## 📁 Repository Structure
```text
├── Simulink_Model/
│   ├── FCHEV_ClosedLoop_Main.slx    # Main closed-loop simulation model
│   ├── Fuzzy_EMS.fis                # Fuzzy Logic Controller parameters
│   └── Export_Data.m                # MATLAB script to export Workspace data to CSV
├── Python_Prediction/
│   ├── FC_Degradation_WLTC.csv      # Dataset generated from Simulink
│   └── lstm_soh_prediction.py       # PyTorch LSTM training and evaluation script
├── Images/
│   ├── simulink_architecture.png    # Screenshot of the Simulink system
│   ├── wltc_dynamic_response.png    # 5-plot scope showing P_net, SOC, and SOH
│   └── lstm_prediction_result.png   # Red vs Blue SOH prediction curve
└── README.md
```

---

## 🚀 How to Run

### 1. Run Simulink Simulation
1. Open MATLAB and ensure Powertrain Blockset and Fuzzy Logic Toolbox are installed.
2. Load `Fuzzy_EMS.fis` into the workspace.
3. Open `FCHEV_ClosedLoop_Main.slx`.
4. Set the simulation stop time to 1800s (for WLTC cycle) and click **Run**.
5. Run `Export_Data.m` to generate the `.csv` dataset.

### 2. Run Python SOH Prediction
1. Ensure you have a Python 3.10+ virtual environment.
2. Install dependencies:
   ```bash
   pip install pandas numpy matplotlib scikit-learn torch
   ```
3. Execute the prediction script:
   ```bash
   python Python_Prediction/lstm_soh_prediction.py
   ```
4. A Matplotlib window will pop up showing the comparison between the Simulink Physical SOH and the LSTM Predicted SOH.

---

## 📚 References
*   Amphlett, J. C., et al. (1995). Performance modeling of the Ballard Mark IV solid polymer electrolyte fuel cell. *Journal of the Electrochemical Society*.
*   Pukrushpan, J. T., et al. (2004). Control of fuel cell breathing. *IEEE Control Systems Magazine*.
*   Fletcher, T., et al. (2016). An Energy Management Strategy to concurrently optimise fuel consumption and PEM fuel cell degradation in a hybrid vehicle. *International Journal of Hydrogen Energy*.

---
*Developed by [Your Name/GitHub Handle]. Contact: [Your Email] for academic discussions or collaborations.*

---
