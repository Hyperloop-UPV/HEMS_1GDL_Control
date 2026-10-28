# config/

Tunables, calibration constants, hardware map definitions, and other
non-source data the controllers and plant models depend on at runtime.

Anything in here should be **plain MATLAB code** (structs, function
handles, parameter tables). `.mat` files belong here too, but only if
they cannot reasonably be expressed as code — `.mat` is opaque and does
not diff well.

## Convention

- One file per topic, e.g. `controller_gains.m`, `sensor_calibration.m`.
- Each file returns a struct so callers can write
  `gains = controller_gains();` and benefit from code-completion.
- Document units in field names where ambiguous (`kp_speed_rpm_per_v`,
  not just `kp`).
