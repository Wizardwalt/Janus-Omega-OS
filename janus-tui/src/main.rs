use std::fs;

use janus_core::RuntimeStatus;

fn main() {
    let status = RuntimeStatus::default();
    println!("==============================");
    println!(" JANUS TUI MAINTENANCE MODE");
    println!("==============================");
    println!("Product: {}", status.product_name);
    println!("Hardware Profile: {}", status.hardware_profile);
    println!();
    println!("Plugin tree:");
    if let Ok(entries) = fs::read_dir("plugins") {
        for entry in entries.flatten() {
            println!("- {}", entry.path().display());
        }
    } else {
        println!("No plugins directory found.");
    }
}
