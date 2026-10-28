# Architecture

> High-level subsystem overview. Replace the placeholder below with the
> real diagram once the project is non-trivial.

```
+------------+        +---------------+        +-----------------+
|  Sensors   | -----> |  Controller   | -----> |  Actuators      |
| (plant/)   |        | (controller/) |        | (plant/)        |
+------------+        +---------------+        +-----------------+
                            |
                            v
                     +-----------------+
                     |   Supervisor    |
                     | (supervisor/)   |
                     +-----------------+
```

## Subsystems

| Subsystem     | Owns                                   | Lives in          |
|---------------|----------------------------------------|-------------------|
| Plant         | Simscape physical model, sensors       | `models/plant/`   |
| Controller    | Continuous & discrete control laws     | `models/controller/` |
| Supervisor    | Mode logic, state machine, safety      | `models/supervisor/` |
| Helpers       | Pure-MATLAB building blocks            | `src/`            |

## Interfaces

Document the input/output contracts of each subsystem here. A common
pattern:

- `controller` takes measurement vector `y` and reference `r`, outputs
  actuation vector `u`. Sample time `T_s`.
- `supervisor` takes telemetry + controller status, outputs mode
  commands + safety flags.

Units, ranges, and update rates belong here, not buried in block
dialoGUI.
