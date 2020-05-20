/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.12
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package org.pjsip.pjsua2;

public class OnCreateMediaTransportSrtpParam {
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected OnCreateMediaTransportSrtpParam(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(OnCreateMediaTransportSrtpParam obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        pjsua2JNI.delete_OnCreateMediaTransportSrtpParam(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public void setMediaIdx(long value) {
    pjsua2JNI.OnCreateMediaTransportSrtpParam_mediaIdx_set(swigCPtr, this, value);
  }

  public long getMediaIdx() {
    return pjsua2JNI.OnCreateMediaTransportSrtpParam_mediaIdx_get(swigCPtr, this);
  }

  public void setSrtpUse(int value) {
    pjsua2JNI.OnCreateMediaTransportSrtpParam_srtpUse_set(swigCPtr, this, value);
  }

  public int getSrtpUse() {
    return pjsua2JNI.OnCreateMediaTransportSrtpParam_srtpUse_get(swigCPtr, this);
  }

  public void setCryptos(SrtpCryptoVector value) {
    pjsua2JNI.OnCreateMediaTransportSrtpParam_cryptos_set(swigCPtr, this, SrtpCryptoVector.getCPtr(value), value);
  }

  public SrtpCryptoVector getCryptos() {
    long cPtr = pjsua2JNI.OnCreateMediaTransportSrtpParam_cryptos_get(swigCPtr, this);
    return (cPtr == 0) ? null : new SrtpCryptoVector(cPtr, false);
  }

  public OnCreateMediaTransportSrtpParam() {
    this(pjsua2JNI.new_OnCreateMediaTransportSrtpParam(), true);
  }

}
