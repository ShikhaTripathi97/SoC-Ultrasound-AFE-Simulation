# Simulation of Analog Front-End of an SoC-Based Ultrasound System
### Analysis of Grass-Clipping Diodes with Transmit/Receive Switch

**MSc Individual Project — Embedded Systems Engineering**
2024–2025


---

## Overview

This project investigates the analog front-end of a System-on-Chip (SoC) based 
ultrasound system, with a focus on the transmit/receive (T/R) switch and the 
effect of Grass-Clipping Diodes (GCDs) on signal integrity and circuit protection.

The work is primarily simulation-driven, using OrCAD PSpice for circuit modelling 
and MATLAB for post-processing and analysis. A key contribution of this project 
is the development of a custom discrete diode-bridge model to replace the 
vendor-supplied TX810 SPICE macro-model, which is encrypted and unsuitable 
for detailed analysis or modification.

The system targets Non-Destructive Testing (NDT) applications, where waveform 
purity and receiver protection are critical.

---

## System Architecture

The analog front-end consists of three main stages:

- **Transmit Path:** DE1-SoC DAC → ADA4870 High-Voltage Amplifier → T/R Switch → Transducer
- **Receive Path:** Transducer → T/R Switch → AD8331 LNA/VGA → DE1-SoC ADC
- **T/R Switch:** Custom discrete diode-bridge equivalent of the TI TX810, 
  with optional Grass-Clipping Diodes (GCDs)

---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| OrCAD PSpice | Circuit simulation and schematic design |
| MATLAB | Post-processing, FFT analysis, THD and SNDR calculation |
| DE1-SoC (Terasic) | Target SoC platform |
| ADA4870 | High-voltage transmit amplifier |
| AD8331 | Low-noise amplifier with variable gain (LNA/VGA) |
| TX810 (discrete equivalent) | Transmit/receive switch |

---

## Key Findings

### T/R Switch with vs. without Grass-Clipping Diodes

**Waveform Quality**
- Without GCDs: Sharp zero-crossing spikes and ringing caused by diode 
  reverse-recovery and junction capacitance
- With GCDs: Zero-crossing transients almost completely suppressed, producing 
  cleaner and more symmetrical waveforms
- Output swing nearly doubled at 20V input with GCDs present

**SNDR (Signal-to-Noise and Distortion Ratio)**
- At 1V input: ~18 dB with GCDs vs. ~−3 dB without
- GCDs provide the most benefit in the low-to-moderate drive range typical 
  of ultrasound pulses
- Above ~10V, amplifier clipping becomes the dominant limitation

**Total Harmonic Distortion (THD)**
- Without GCDs: THD rises sharply from ~3% at 2.5V to ~22% at 4.5V
- With GCDs: Higher initial THD (~12–13%) due to deliberate hard clipping, 
  but distortion is predictable, symmetric, and easier to filter
- This trade-off is acceptable in protection-critical designs

### ADA4870 Transmit Amplifier
- Linear gain of ~1.9 V/V for inputs between 0.2V and 5V
- Maximum simulated output swing exceeds 200 Vpp before saturation
- Input drive should be kept below saturation threshold to preserve linearity

### AD8331 LNA/VGA
- Gain range confirmed across VGAIN settings: 3.65 dB (0V) to 18.06 dB (0.5V)
- Clean sinusoidal output with no clipping or visible distortion across 
  all gain settings
- Suitable for wide dynamic range echo reception

---

## Notable Technical Contribution

The vendor-supplied TX810 SPICE model is encrypted and causes frequent 
convergence failures, making it a "black box" unsuitable for research. 

This project developed a **custom discrete diode-bridge equivalent** in PSpice, 
enabling full control over component parameters, direct integration of GCDs, 
and transparent analysis of switching behaviour — something not possible 
with the official model.

---

## Hardware Testing

Limited bench testing of the TX810 with and without GCDs was carried out 
to validate simulation trends:
- Without GCDs: Output was a reduced sine wave (~70mV from 2V input), 
  consistent with expected switch losses
- With GCDs: Output dropped to ~2.1mV, confirming strong attenuation 
  and protective clamping behaviour
- Greater attenuation and noise observed in hardware vs. simulation, 
  attributed to diode leakage, parasitic capacitance, and probe loading

---

## Future Work

- Full hardware implementation using the DE1-SoC platform with real 
  ultrasonic transducers
- Validation of simulation results in a practical NDT environment
- Exploration of integrated T/R switch solutions with on-chip GCD equivalents

---

## Project Structure
├── PSpice/          # Schematic and simulation files (.opj, .dsn)
├── MATLAB/          # Post-processing scripts for THD, SNDR, FFT analysis
├── Results/         # Simulation output waveforms and plots
└── Report/          # Final project report (summary)

---

## References

Key components and models used:
- ADA4870: Analog Devices High-Speed, High-Voltage Op-Amp
- AD8331: Analog Devices LNA/VGA for Ultrasound
- TX810: Texas Instruments 8-Channel T/R Switch

---


