/// GPIO Blink example — toggles an LED on a GPIO pin every second.
///
/// ESP32-C3 Super Mini: onboard LED is GPIO 8, active LOW (0 = on, 1 = off).
/// Other boards: change `LED_PIN` and set `active_low = false` if needed.
///
/// No WiFi or Bluetooth required — works on any ESP32 target.
const std = @import("std");
const builtin = @import("builtin");

const idf = @import("esp_idf");
pub const panic = idf.esp_panic.panic;

const log = std.log.scoped(.blink);

const LED_PIN: idf.gpio.Num() = .@"8";
const active_low = true;

export fn app_main() callconv(.c) void {
    log.info("GPIO Blink — GPIO{d} (active_low={})", .{ @intFromEnum(LED_PIN), active_low });

    idf.gpio.Direction.set(LED_PIN, .output) catch |err| {
        log.err("GPIO direction set failed: {s}", .{@errorName(err)});
        return;
    };

    var led_on: u1 = 0;
    while (true) {
        led_on ^= 1;
        const level: u1 = if (active_low) @truncate(1 - led_on) else led_on;
        idf.gpio.Level.set(LED_PIN, level) catch {};
        log.info("LED: {s}", .{if (led_on == 1) "ON" else "OFF"});
        idf.rtos.Task.delayMs(2000);
    }
}

pub const std_options: std.Options = .{
    .log_level = switch (builtin.mode) {
        .Debug => .debug,
        else => .info,
    },
    .logFn = idf.log.espLogFn,
};
