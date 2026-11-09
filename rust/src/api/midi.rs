//! Portas MIDI (entrada e saída) para conversar com a controladora: listar,
//! abrir, mandar bytes e receber tudo o que chega (inclusive SysEx).

use crate::frb_generated::StreamSink;
use anyhow::{anyhow, Result};
use midir::{Ignore, MidiInput, MidiInputConnection, MidiOutput, MidiOutputConnection};
use parking_lot::Mutex;

struct Connection {
    input: Option<(String, MidiInputConnection<()>)>,
    output: Option<(String, MidiOutputConnection)>,
}

static CONNECTION: Mutex<Connection> = Mutex::new(Connection { input: None, output: None });
static SINK: Mutex<Option<StreamSink<Vec<u8>>>> = Mutex::new(None);

fn attach() {
    #[cfg(target_os = "android")]
    crate::android::attach_jvm();
}

/// Portas disponíveis, pelo nome.
pub struct MidiPorts {
    pub inputs: Vec<String>,
    pub outputs: Vec<String>,
}

pub fn midi_list_ports() -> Result<MidiPorts> {
    attach();
    let input = MidiInput::new("footcraft-scan-in")?;
    let output = MidiOutput::new("footcraft-scan-out")?;
    // Nossas próprias portas (ALSA) não interessam.
    let own = |n: &String| !n.to_lowercase().contains("footcraft");
    Ok(MidiPorts {
        inputs: input.ports().iter().filter_map(|p| input.port_name(p).ok()).filter(own).collect(),
        outputs: output.ports().iter().filter_map(|p| output.port_name(p).ok()).filter(own).collect(),
    })
}

/// Bytes recebidos pela entrada aberta, do jeito que chegam (um SysEx longo
/// pode vir em pedaços; quem monta é o app).
pub fn midi_input_stream(sink: StreamSink<Vec<u8>>) {
    *SINK.lock() = Some(sink);
}

/// Abre a entrada e a saída pelos nomes (nulo = não abrir). Fecha as anteriores.
pub fn midi_open(input: Option<String>, output: Option<String>) -> Result<()> {
    attach();
    midi_close();
    let mut conn = CONNECTION.lock();
    if let Some(name) = input {
        let mut midi_in = MidiInput::new("footcraft-in")?;
        midi_in.ignore(Ignore::None);
        let port = midi_in
            .ports()
            .into_iter()
            .find(|p| midi_in.port_name(p).ok().as_deref() == Some(name.as_str()))
            .ok_or_else(|| anyhow!("entrada MIDI não encontrada: {name}"))?;
        let c = midi_in
            .connect(
                &port,
                "footcraft-in",
                |_ts, bytes, _| {
                    // Clock e Active Sensing não interessam e lotariam o app.
                    if bytes.len() == 1 && bytes[0] >= 0xF8 {
                        return;
                    }
                    if let Some(sink) = SINK.lock().as_ref() {
                        let _ = sink.add(bytes.to_vec());
                    }
                },
                (),
            )
            .map_err(|e| anyhow!("falha ao abrir a entrada MIDI: {e}"))?;
        conn.input = Some((name, c));
    }
    if let Some(name) = output {
        let midi_out = MidiOutput::new("footcraft-out")?;
        let port = midi_out
            .ports()
            .into_iter()
            .find(|p| midi_out.port_name(p).ok().as_deref() == Some(name.as_str()))
            .ok_or_else(|| anyhow!("saída MIDI não encontrada: {name}"))?;
        let c = midi_out
            .connect(&port, "footcraft-out")
            .map_err(|e| anyhow!("falha ao abrir a saída MIDI: {e}"))?;
        conn.output = Some((name, c));
    }
    Ok(())
}

pub fn midi_close() {
    let mut conn = CONNECTION.lock();
    if let Some((_, c)) = conn.input.take() {
        c.close();
    }
    if let Some((_, c)) = conn.output.take() {
        c.close();
    }
}

/// Nomes da entrada e da saída abertas (vazio = fechada).
pub struct MidiOpenPorts {
    pub input: Option<String>,
    pub output: Option<String>,
}

#[flutter_rust_bridge::frb(sync)]
pub fn midi_open_ports() -> MidiOpenPorts {
    let conn = CONNECTION.lock();
    MidiOpenPorts {
        input: conn.input.as_ref().map(|(n, _)| n.clone()),
        output: conn.output.as_ref().map(|(n, _)| n.clone()),
    }
}

/// Bytes por pedaço e pausa entre eles ao mandar um SysEx longo: ~1300
/// bytes/s, abaixo dos ~3100 do cabo MIDI. Interfaces USB-MIDI baratas perdem
/// quase tudo se o SysEx inteiro chega de uma vez (conferido com uma FCB1010:
/// de 2352 bytes voltaram 8; em pedaços, todos).
const CHUNK: usize = 32;
const PAUSE: std::time::Duration = std::time::Duration::from_millis(25);

/// Manda uma mensagem completa; um SysEx longo vai em pedaços, devagar.
pub fn midi_send(bytes: Vec<u8>) -> Result<()> {
    attach();
    for (i, part) in bytes.chunks(CHUNK).enumerate() {
        if i > 0 {
            std::thread::sleep(PAUSE);
        }
        let mut conn = CONNECTION.lock();
        let (_, out) = conn.output.as_mut().ok_or_else(|| anyhow!("nenhuma saída MIDI aberta"))?;
        out.send(part).map_err(|e| anyhow!("falha ao enviar: {e}"))?;
    }
    Ok(())
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
