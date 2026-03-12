# Multivariable PID Control for Nonlinear Systems

## Project Overview
This repository contains my Bachelor's Thesis project, focused on designing and implementing a multivariable PID control system for nonlinear processes. The project addresses the challenges of controlling a multi-tank hydraulic installation (**ASTANK2**) by utilizing advanced system identification and metaheuristic optimization.

## Key Features
* **System Identification:** Developed nonlinear models using **NARX** (Nonlinear AutoRegressive with eXogenous inputs) structures to capture complex dynamics.
* **Controller Optimization:** Implemented the **Grey Wolf Optimizer (GWO)** algorithm to automatically tune PID parameters for optimal performance.
* **Digital Control:** Applied the **Tustin discretization** method to prepare the control law for real-time systems.
* **Simulation & Validation:** Developed complete simulation environments in **MATLAB & Simulink** to validate the robustness of the proposed solution.

## Technologies Used
* **MATLAB / Simulink** (Control System Toolbox, System Identification Toolbox)
* **Optimization Algorithms** (Grey Wolf Optimizer - GWO)
* **Control Theory** (MISO Systems, PID Control, Nonlinear Modeling)

## Documentation
The full thesis (in Romanian) and the technical implementation details are available in the `/docs` folder.
