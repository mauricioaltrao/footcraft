//! Diagnóstico: manda um .syx pelo mesmo caminho do app (midir) e confere o
//! eco que volta pelo MIDI Merge da FCB (precisa estar fora da configuração).
//! Uso: cargo run --example echo -- <arquivo.syx> <trecho do nome da porta> [bytes por pedaço] [pausa ms]
use midir::{Ignore, MidiInput, MidiOutput};
use std::sync::{Arc, Mutex};
use std::time::Duration;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let data = std::fs::read(&args[1]).unwrap();
    let hint = args[2].to_lowercase();
    let chunk: usize = args.get(3).map(|s| s.parse().unwrap()).unwrap_or(0);
    let pause: u64 = args.get(4).map(|s| s.parse().unwrap()).unwrap_or(0);

    let mut input = MidiInput::new("footcraft-echo-in").unwrap();
    input.ignore(Ignore::None);
    let in_port = input.ports().into_iter().find(|p| input.port_name(p).unwrap().to_lowercase().contains(&hint)).unwrap();
    let got = Arc::new(Mutex::new(Vec::<u8>::new()));
    let g = got.clone();
    let _conn_in = input
        .connect(&in_port, "echo", move |_, b, _| {
            if !(b.len() == 1 && b[0] >= 0xF8) {
                g.lock().unwrap().extend_from_slice(b)
            }
        }, ())
        .unwrap();

    let output = MidiOutput::new("footcraft-echo-out").unwrap();
    let out_port = output.ports().into_iter().find(|p| output.port_name(p).unwrap().to_lowercase().contains(&hint)).unwrap();
    let mut out = output.connect(&out_port, "echo").unwrap();

    if chunk == 0 {
        out.send(&data).unwrap();
    } else {
        for c in data.chunks(chunk) {
            if let Err(e) = out.send(c) {
                println!("pedaço recusado: {e}");
                return;
            }
            std::thread::sleep(Duration::from_millis(pause));
        }
    }
    std::thread::sleep(Duration::from_secs(3));
    let got = got.lock().unwrap();
    let diffs = got.iter().zip(data.iter()).filter(|(a, b)| a != b).count();
    println!("enviados {} | voltaram {} | iguais: {} | bytes diferentes: {}", data.len(), got.len(), *got == data, diffs);
}
