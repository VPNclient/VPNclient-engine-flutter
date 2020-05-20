/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.12
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package org.pjsip.pjsua2;

public class BuddyVector2 {
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected BuddyVector2(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(BuddyVector2 obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        pjsua2JNI.delete_BuddyVector2(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public BuddyVector2() {
    this(pjsua2JNI.new_BuddyVector2__SWIG_0(), true);
  }

  public BuddyVector2(long n) {
    this(pjsua2JNI.new_BuddyVector2__SWIG_1(n), true);
  }

  public long size() {
    return pjsua2JNI.BuddyVector2_size(swigCPtr, this);
  }

  public long capacity() {
    return pjsua2JNI.BuddyVector2_capacity(swigCPtr, this);
  }

  public void reserve(long n) {
    pjsua2JNI.BuddyVector2_reserve(swigCPtr, this, n);
  }

  public boolean isEmpty() {
    return pjsua2JNI.BuddyVector2_isEmpty(swigCPtr, this);
  }

  public void clear() {
    pjsua2JNI.BuddyVector2_clear(swigCPtr, this);
  }

  public void add(Buddy x) {
    pjsua2JNI.BuddyVector2_add(swigCPtr, this, Buddy.getCPtr(x), x);
  }

  public Buddy get(int i) {
    return new Buddy(pjsua2JNI.BuddyVector2_get(swigCPtr, this, i), false);
  }

  public void set(int i, Buddy val) {
    pjsua2JNI.BuddyVector2_set(swigCPtr, this, i, Buddy.getCPtr(val), val);
  }

}
