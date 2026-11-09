package com.altrao.footcraft

import android.content.Context
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // A biblioteca Rust acessa o MIDI do Android via JNI e precisa do
        // JavaVM/Context, que o carregamento pelo dart:ffi não fornece.
        try {
            System.loadLibrary("rust_lib_footcraft")
            initMidiNative(applicationContext)
        } catch (e: Throwable) {
            Log.w("FootCraft", "Falha ao inicializar o MIDI nativo", e)
        }
    }

    private external fun initMidiNative(context: Context)
}
