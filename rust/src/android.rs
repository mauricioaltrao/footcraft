//! Inicialização do contexto Android para o MIDI.
//!
//! O backend Android do `midir` (API `android.media.midi` + AMidi) obtém o
//! JavaVM e o `Context` pelo crate `ndk_context`, que só é preenchido
//! automaticamente em apps 100% Rust. No Flutter a biblioteca é carregada pelo
//! `dart:ffi`, então o `MainActivity` chama esta função no `onCreate`.

use jni::objects::JObject;
use jni::JNIEnv;
use std::sync::Once;

static INIT: Once = Once::new();

#[no_mangle]
pub extern "system" fn Java_com_altrao_footcraft_MainActivity_initMidiNative(
    env: JNIEnv,
    _activity: JObject,
    context: JObject,
) {
    INIT.call_once(|| {
        let (Ok(vm), Ok(ctx)) = (env.get_java_vm(), env.new_global_ref(context)) else {
            return;
        };
        // A referência global precisa viver enquanto o processo existir.
        let raw_ctx = ctx.as_obj().as_raw();
        std::mem::forget(ctx);
        // Safety: ponteiros válidos de JavaVM e de um Context com referência global.
        unsafe { ndk_context::initialize_android_context(vm.get_java_vm_pointer().cast(), raw_ctx.cast()) };
    });
}

/// Liga a thread atual à JVM (o backend Android do midir usa JNI).
pub(crate) fn attach_jvm() {
    let Ok(ctx) = std::panic::catch_unwind(ndk_context::android_context) else {
        return;
    };
    if let Ok(vm) = unsafe { jni::JavaVM::from_raw(ctx.vm().cast()) } {
        let _ = vm.attach_current_thread_permanently();
    }
}
