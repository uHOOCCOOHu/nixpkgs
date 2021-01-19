addSgxSdkPath () {
    export SGX_SDK="@out@/share/sgxsdk"
}

addEnvHooks "$hostOffset" addSgxSdkPath
