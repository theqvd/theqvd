#include <qvdclient.h>
#include <stdint.h>
#include <stdlib.h>
#include "com_theqvd_client_jni_QvdclientWrapper.h"

static jfieldID qvdclient_fid, host_fid, port_fid, username_fid, password_fid,
  vm_id_fid, vm_name_fid, vm_state_fid, vm_blocked_fid, certificatehandler_fid, progresshandler_fid;
static jmethodID vm_constructor_mid, certificate_verification_mid, print_progress_mid;
static jclass qvdclientwrapper_cls, qvdclient_cls, vm_cls, vm_array_cls, qvdunknowncerthandler_cls,
  qvdprogresshandler_cls;

struct callbackhandler_environment_struct  {
  JavaVM *jvm;
  jobject unknowncertCallbackHandler;
  jobject progressCallbackHandler;
};

/*
 * Static method called once when the QvdclientWrapper class is loaded
 * It caches the fieldids and the class references
 */
int initIds(JNIEnv *env) {
  jclass temp;

  temp = (*env)->FindClass(env, "com/theqvd/client/jni/QvdclientWrapper");
  qvdclientwrapper_cls = (*env)->NewGlobalRef(env, temp);
  (*env)->DeleteLocalRef(env, temp);
  if (qvdclientwrapper_cls == NULL)
    {
      qvd_printf("Error finding class for QvdclientWrapper");
      return -1;
    }

  temp = (*env)->FindClass(env, "com/theqvd/client/jni/Qvdclient");
  qvdclient_cls = (*env)->NewGlobalRef(env, temp);
  (*env)->DeleteLocalRef(env, temp);
  if (qvdclient_cls == NULL)
    {
      qvd_printf("Error finding class for Qvdclient");
      return -1;
    }

  temp = (*env)->FindClass(env, "com/theqvd/client/jni/Vm");
  vm_cls = (*env)->NewGlobalRef(env, temp);
  (*env)->DeleteLocalRef(env, temp);
   if (vm_cls == NULL)
     {
       qvd_printf("Error finding class for Vm");
       return -1;
     }

   temp = (*env)->FindClass(env, "[Lcom/theqvd/client/jni/Vm;");
   vm_array_cls = (*env)->NewGlobalRef(env, temp);
   (*env)->DeleteLocalRef(env, temp);
   if (vm_array_cls == NULL)
    {
      qvd_printf("Error finding class for Vm array");
      return -1;
    }

   host_fid = (*env)->GetFieldID(env, qvdclient_cls, "host", "Ljava/lang/String;");
   if (host_fid == NULL)
     {
       qvd_printf("Error finding field id for host in class Qvdclient");
       return -1;
     }

   qvdclient_fid = (*env)->GetFieldID(env, qvdclientwrapper_cls, "qvdclient", "Lcom/theqvd/client/jni/Qvdclient;");
   if (qvdclient_fid == NULL)
     {
       qvd_printf("Error finding field id for qvdclient member of class QvdclientWrapper");
       return -1;
     }
   certificatehandler_fid = (*env)->GetFieldID(env, qvdclientwrapper_cls, "certificateHandler", "Lcom/theqvd/client/jni/QvdUnknownCertificateHandler;");
   if (certificatehandler_fid == NULL)
     {
       qvd_printf("Error finding field id for interface QvdUnknownCertificateHandler");
       return -1;
     }
   qvd_printf("certificatehandler_fid: %p\n", certificatehandler_fid);

   progresshandler_fid = (*env)->GetFieldID(env, qvdclientwrapper_cls, "progressHandler", "Lcom/theqvd/client/jni/QvdProgressHandler;");
   if (progresshandler_fid == NULL)
     {
       qvd_printf("Error finding field id for interface QvdProgressHandler");
       return -1;
     }
   qvd_printf("progresshandler_fid: %p\n", progresshandler_fid);


   port_fid = (*env)->GetFieldID(env, qvdclient_cls, "port", "I");
   if (port_fid == NULL)
     {
       qvd_printf("Error finding field id for port in class Qvdclient");
       return -1;
     }

   username_fid = (*env)->GetFieldID(env, qvdclient_cls, "username", "Ljava/lang/String;");
   if (username_fid == NULL)
     {
       qvd_printf("Error finding field id for username in class Qvdclient");
       return -1;
     }

   password_fid = (*env)->GetFieldID(env, qvdclient_cls, "password", "Ljava/lang/String;");
   if (password_fid == NULL)
     {
       qvd_printf("Error finding field id for password in class Qvdclient");
       return -1;
     }

   vm_id_fid = (*env)->GetFieldID(env, vm_cls, "id", "I");
   if (vm_id_fid == NULL)
     {
       qvd_printf("Error finding field id in class Vm");
       return -1;
     }

   vm_name_fid = (*env)->GetFieldID(env, vm_cls, "name", "Ljava/lang/String;");
   if (vm_name_fid == NULL)
     {
       qvd_printf("Error finding field id for name in class Vm");
       return -1;
     }

   vm_state_fid = (*env)->GetFieldID(env, vm_cls, "state", "Ljava/lang/String;");
   if (vm_state_fid == NULL)
     {
       qvd_printf("Error finding field id for state in class Vm");
       return -1;
     }

   vm_blocked_fid = (*env)->GetFieldID(env, vm_cls, "blocked", "I");
   if (vm_blocked_fid == NULL)
     {
      qvd_printf("Error finding field blocked in class Vm");
      return -1;
     }

   vm_constructor_mid = (*env)->GetMethodID(env, vm_cls, "<init>", "(ILjava/lang/String;Ljava/lang/String;I)V");
   if (vm_constructor_mid == NULL)
     {
       qvd_printf("Error finding constructor for class Vm");
       return -1;
     }

   return 0;
}


JNINativeMethod methods[] = {
  {
    "qvd_c_get_version_text",
    "()Ljava/lang/String;",
    Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1get_1version_1text
  },
  {
    "qvd_c_get_version",
    "()I",
    Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1get_1version
  },
  {
    "qvd_c_init",
    "(Lcom/theqvd/client/jni/Qvdclient;)J",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1init
  },
  {
    "qvd_c_free",
    "(J)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1free
  },
  {
    "qvd_c_connect_to_vm",
    "(JI)I",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1connect_1to_1vm
  },
  {
    "qvd_c_list_of_vm",
    "(J)[Lcom/theqvd/client/jni/Vm;",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1list_1of_1vm
  },
  {
    "qvd_c_stop_vm",
    "(JI)I",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1stop_1vm
  },
  {
    "qvd_c_set_geometry",
    "(JII)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1geometry
  },
  {
    "qvd_c_set_fullscreen",
    "(J)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1fullscreen
  },
  {
    "qvd_c_set_nofullscreen",
    "(J)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1nofullscreen
  },
  {
    "qvd_c_set_debug",
    "()V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1debug
  },
  {
    "qvd_c_set_display",
    "(JLjava/lang/String;)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1display
  },
  {
    "qvd_c_get_last_error_message",
    "(J)Ljava/lang/String;",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1get_1last_1error_1message
  },
  {
    "qvd_c_set_home",
    "(JLjava/lang/String;)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1home
  },
  {
    "qvd_c_set_useragent",
    "(JLjava/lang/String;)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1useragent
  },
  {
    "qvd_c_set_os",
    "(JLjava/lang/String;)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1os
  },
  {
    "qvd_c_set_link",
    "(JLjava/lang/String;)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1link
  },
  {
    "qvd_c_set_no_cert_check",
    "(J)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1no_1cert_1check
  },
  {
    "qvd_c_set_strict_cert_check",
    "(J)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1strict_1cert_1check
  },
  {
    "qvd_c_set_progress_callback",
    "(J)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1progress_1callback
  },
  {
    "qvd_c_set_no_progress_callback",
    "(J)V",
    (void *) Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1no_1progress_1callback
  },
};

jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
    JNIEnv* env;
    jclass temp;

    if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK) {
      qvd_printf("Failed to get the environment using GetEnv\n");
      return -1;
    }

    // Get jclass with env->FindClass.
    if (initIds(env) < 0) {
      qvd_printf("Failed to register methods\n");
      return -1;
    }
    // Register methods with env->RegisterNatives.
    (*env)->RegisterNatives(env, qvdclientwrapper_cls, methods, sizeof(methods)/sizeof(methods[0]));

    return JNI_VERSION_1_6;
}


inline jlong _set_c_pointer(qvdclient *qvd)
{
  jlong qvd_c_pointer = 0L;
#if UINTPTR_MAX == 0xffffffff
/* 32-bit */
  qvd_c_pointer += (jint) qvd;
#elif UINTPTR_MAX == 0xffffffffffffffff
/* 64-bit */
  qvd_c_pointer += (jlong) qvd;
#else
/* wtf */
#error Not a 32 bit or 64 bit architecture
#endif
  return qvd_c_pointer;
}

inline qvdclient *_set_qvdclient(jlong qvd_c_pointer)
{
  qvdclient *qvd;

#if UINTPTR_MAX == 0xffffffff
/* 32-bit */
  qvd = (qvdclient *) (jint)qvd_c_pointer;
#elif UINTPTR_MAX == 0xffffffffffffffff
/* 64-bit */
  qvd = (qvdclient *) qvd_c_pointer;
#else
/* wtf */
#error Not a 32 bit or 64 bit architecture
#endif

  return qvd;
}


/*
 * Sets callback to call the java method certificate_verification from the object
 * certificateHandler of the class QvdClientWrapper
 * It gets from the qvd->userdata which points to a struct of callbackhandler_environment_struct
 * A pointer to the jvm and one to the QvdclientWrapper->unknowncertCallbackHandler object
 * From there we get the class of the certifcateHandler and the
 * method certificate_verification, which we invoke, and return the result.
 */
int accept_unknown_cert_callback(qvdclient *qvd, const char *cert_pem_str, const char *cert_pem_data)
{
  jstring jcert_pem_str, jcert_pem_data;
  jboolean response;
  struct callbackhandler_environment_struct *callbackhandler_env;
  JNIEnv *env;
  jclass temp;

  qvd_printf("accept_unknown_cert_callback\n");
  callbackhandler_env = (struct callbackhandler_environment_struct *) qvd->userdata;
  qvd_printf("accept_unknown_cert_callback:certificateHandler: %p, jvm: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm);
  (*(callbackhandler_env->jvm))->AttachCurrentThread(callbackhandler_env->jvm, (void **)&env, NULL);
  qvd_printf("accept_unknown_cert_callback:certificateHandler: %p, jvm: %p, env: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm, env);
  if (env == NULL)
    {
      qvd_error(qvd, "Error obtaining JNIEnv * from jvm\n");
      return 0;
    }

  /* Might be null if object is not defined */
  if (!callbackhandler_env->unknowncertCallbackHandler)
    {
      qvd_printf("certificateHandler object is null, returning false (certificate rejected)\n");
      return 0;
    }
  qvd_printf("certhandler is non null\n");

  jcert_pem_str = (*env)->NewStringUTF(env, cert_pem_str);
  if (jcert_pem_str == NULL)
    {
      qvd_error(qvd, "Error allocating memory for jcert_pem_str\n");
      return 0;
    }
  qvd_printf("jcert_pem_str is non null\n");

  jcert_pem_data = (*env)->NewStringUTF(env, cert_pem_data);
  if (jcert_pem_data == NULL)
    {
      qvd_error(qvd, "Error allocating memory for jcert_pem_data\n");
      return 0;
    }
  qvd_printf("jcert_pem_data is non null\n");


   temp = (*env)->GetObjectClass(env, callbackhandler_env->unknowncertCallbackHandler);
   qvdunknowncerthandler_cls = (*env)->NewGlobalRef(env, temp);
   (*env)->DeleteLocalRef(env, temp);
   if (qvdunknowncerthandler_cls == NULL)
    {
      qvd_error(qvd, "Error finding class for QvdUnknownCertificateHandler interface");
      return -1;
    }


  certificate_verification_mid = (*env)->GetMethodID(env, qvdunknowncerthandler_cls, "certificate_verification", "(Ljava/lang/String;Ljava/lang/String;)Z");
  if (certificate_verification_mid == NULL)
    {
      qvd_error(qvd, "Error finding method for interface QvdUnknownCertificateHandler certicate_verification\n");
      return 0;
    }

  response = (*env)->CallBooleanMethod(env, callbackhandler_env->unknowncertCallbackHandler, certificate_verification_mid, jcert_pem_str, jcert_pem_data);
  qvd_printf("After CallBooleanMethod\n");
  qvd_printf("After CallBooleanMethod response, %d\n", response);
  (*env)->DeleteLocalRef(env, jcert_pem_str);
  (*env)->DeleteLocalRef(env, jcert_pem_data);

  return response;

}


/*
 * Sets callback to call the java method print_progress from the object
 * progressHandler of the class QvdClientWrapper
 */
int progress_callback(qvdclient *qvd, const char *message)
{
  /* TODO rename callbackhandler_environment_struct and reuse it for this case */
  jstring message_str;
  struct callbackhandler_environment_struct *callbackhandler_env;
  JNIEnv *env;
  jclass temp;

  qvd_printf("progress_callback\n");
  callbackhandler_env = (struct callbackhandler_environment_struct *) qvd->userdata;
  qvd_printf("progress_callback:progressHandler: %p, jvm: %p\n", callbackhandler_env->progressCallbackHandler, callbackhandler_env->jvm);
  (*(callbackhandler_env->jvm))->AttachCurrentThread(callbackhandler_env->jvm, (void **)&env, NULL);
  qvd_printf("progress_callback:progressHandler: %p, jvm: %p, env: %p\n", callbackhandler_env->progressCallbackHandler, callbackhandler_env->jvm, env);
  if (env == NULL)
    {
      qvd_error(qvd, "Error obtaining JNIEnv * from jvm\n");
      return 0;
    }

  /* Might be null if object is not defined */
  if (!callbackhandler_env->progressCallbackHandler)
    {
      qvd_printf("progressCallbackHandler object is null, returning 0\n");
      return 0;
    }
  qvd_printf("progressCallbackHandler is non null\n");

  message_str = (*env)->NewStringUTF(env, message);
  if (message_str == NULL)
    {
      qvd_error(qvd, "Error allocating memory for message_str\n");
      return 0;
    }
  qvd_printf("message_str is non null");

   temp = (*env)->GetObjectClass(env, callbackhandler_env->progressCallbackHandler);
   qvdprogresshandler_cls = (*env)->NewGlobalRef(env, temp);
   (*env)->DeleteLocalRef(env, temp);
   if (qvdprogresshandler_cls == NULL)
    {
      qvd_error(qvd, "Error finding class for QvdProgressHandler interface");
      return 0;
    }

   print_progress_mid = (*env)->GetMethodID(env, qvdprogresshandler_cls, "print_progress", "(Ljava/lang/String;)V");
  if (print_progress_mid == NULL)
    {
      qvd_error(qvd, "Error finding method for interface QvdProgressHandler print_progress\n");
      return 0;
    }

  (*env)->CallVoidMethod(env, callbackhandler_env->progressCallbackHandler, print_progress_mid, message_str);
  qvd_printf("After CallVoidMethod\n");
  (*env)->DeleteLocalRef(env, message_str);

  return 1;
}



/*
 * Class:     com_theqvd_client_jni_QvdclientWrapper
 * Method:    qvd_c_get_version_text
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1get_1version_1text
(JNIEnv *env, jclass class) {
  const char *version = qvd_get_version_text();
  return (*env)->NewStringUTF(env, version);
}

/*
 * Class:     com_theqvd_client_jni_QvdclientWrapper
 * Method:    qvd_c_get_version
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1get_1version
(JNIEnv *env, jclass class) {
  jint version;
  version = qvd_get_version();
  return version;
}




/**
 * Initializes the qvdclient structure invoking qvd_init
 * The parameters host, port, username and password are fetched
 * from the Java object passed
 */
JNIEXPORT jlong JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1init (JNIEnv *env, jobject obj, jobject qvdclnt)
{
  qvdclient *qvd;
  jlong qvd_c_pointer;
  jstring username, password, host;
  jint port;
  const char *username_c, *password_c, *host_c;
  int port_c;

  qvd_printf("qvd_c_init\n");

  host = (*env)->GetObjectField(env, qvdclnt, host_fid);
  host_c = (*env)->GetStringUTFChars(env, host, NULL);
  if (host_c == NULL)
    {
      qvd_printf("out of memory allocating host");
      return 0; /* out of memory */
    }

  port_c = (*env)->GetIntField(env, qvdclnt, port_fid);

  username = (*env)->GetObjectField(env, qvdclnt, username_fid);
  username_c = (*env)->GetStringUTFChars(env, username, NULL);
  if (username_c == NULL)
    {
      qvd_printf("out of memory allocating username");
      (*env)->ReleaseStringUTFChars(env, host, host_c);
      return 0; /* out of memory */
    }

  password = (*env)->GetObjectField(env, qvdclnt, password_fid);
  password_c = (*env)->GetStringUTFChars(env, password, NULL);
  if (password_c == NULL)
    {
      qvd_printf("out of memory allocating password");
      (*env)->ReleaseStringUTFChars(env, host, host_c);
      (*env)->ReleaseStringUTFChars(env, username, username_c);
      return 0; /* out of memory */
    }

  qvd_printf("Calling qvd_init with host=%s,port=%d,username=%s,password=****\n", host_c, port_c, username_c);
  qvd = qvd_init(host_c, port_c, username_c, password_c);

  qvd_c_pointer = _set_c_pointer(qvd);

  return qvd_c_pointer;
}

/**
 * Invokes qvd_free releasing the memory allocated in qvd_init
 */
JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1free
(JNIEnv *env, jobject obj, jlong qvd_c_pointer) {
  qvdclient *qvd;

  qvd_printf("qvd_c_free\n");
  qvd=_set_qvdclient(qvd_c_pointer);
  free(qvd->userdata);
  qvd_free(qvd);
  qvd=NULL;
}


/*
 * Creates a Vm object with the parameters id, name, state and blocked
 * It calls the Java constructor of Vm(id, name, state, blocked) for that
 */
jobject _construct_vm(JNIEnv *env, vm *data)
{
  jint id, blocked;
  jstring name, state;
  jobject vm;

  id = data->id;
  name = (*env)->NewStringUTF(env, data->name);
  if (name == NULL)
    {
      qvd_printf("Error allocating memory for Vm name");
      return NULL;
    }
  state = (*env)->NewStringUTF(env, data->state);
  if (state == NULL)
    {
      qvd_printf("Error allocating memory for Vm state");
      (*env)->DeleteLocalRef(env, name);
      return NULL;
    }
  blocked = data->blocked;
  qvd_printf("id=%d,name=%s,state=%s,blocked=%d\n",data->id, data->name, data->state, data->blocked);
  vm = (*env)->NewObject(env, vm_cls, vm_constructor_mid, id, name, state, blocked);
  (*env)->DeleteLocalRef(env, name);
  (*env)->DeleteLocalRef(env, state);
  if (vm == NULL)
    {
      qvd_printf("Error creating Vm object\n");
      return NULL;
    }
  return vm;
}

/*
 * Returns an array of VMs after calling qvd_list_of_vm
 */
JNIEXPORT jobjectArray JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1list_1of_1vm
(JNIEnv *env, jobject obj, jlong qvd_c_pointer)
{
  qvdclient *qvd;
  vmlist *vms, *ptr;
  jobjectArray jarray_of_vms;
  jobject vm;
  struct callbackhandler_environment_struct *callbackhandler_env = NULL;
  int i;
  /* JavaVM **vm; */

  qvd_printf("c_qvd_list_of_vm\n");
  qvd = _set_qvdclient(qvd_c_pointer);

  /* Set the certificate handler here */
  /*  memory leak handling if the list_of_vm is called twice, should be NULL
   *  if not allocated before
   */
  free(qvd->userdata);
  callbackhandler_env = malloc(sizeof(struct callbackhandler_environment_struct));
  /* Might be null if the object has not been asigned */
  callbackhandler_env->unknowncertCallbackHandler = (*env)->GetObjectField(env, obj, certificatehandler_fid);
  qvd_printf("certificateHandler: %p, jvm: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm);
  callbackhandler_env->progressCallbackHandler = (*env)->GetObjectField(env, obj, progresshandler_fid);
  qvd_printf("progressCallbackHandler: %p, jvm: %p\n", callbackhandler_env->progressCallbackHandler, callbackhandler_env->jvm);
  if ((*env)->GetJavaVM(env, &(callbackhandler_env->jvm)) < 0) {
    qvd_error(qvd, "Error obtaining the JavaVM pointer\n");
    return NULL;
  }
  qvd->userdata = (void *) callbackhandler_env;
  qvd_printf("certificateHandler: %p, jvm: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm);
  qvd_set_unknown_cert_callback(qvd, accept_unknown_cert_callback);

  vms = qvd_list_of_vm(qvd);
  if (vms == NULL)
    {
      qvd_printf("c_qvd_list_of_vm returned an error\n");
      return NULL;
    }
  qvd_printf("c_qvd_list_of_vm returned %d elements\n", qvd->numvms);

  jarray_of_vms = (*env)->NewObjectArray(env, qvd->numvms, vm_cls, NULL);
  if (jarray_of_vms == NULL)
    {
      qvd_error(qvd, "Error allocating memory for Vm[%d]\n", qvd->numvms);
      return NULL; /* out of memory error thrown */
    }
  qvd_printf("Before loop\n");

  /* Numer of vms qvd->numvms see qvdclient.h */

  for (i = 0, ptr = vms; i < qvd->numvms; ++i, ptr = ptr->next)
    {
      qvd_printf("iterator i=%d\n", i);
      if (ptr == NULL)
	{
	  qvd_error(qvd, "Error initializing array, the size reported was %d, but only %d elements were found\n", qvd->numvms, i - 1);
	  return NULL;
	}
      if (ptr->data == NULL)
	{
	  qvd_error(qvd, "Internal error the vm->data is NULL, this should not happen\n");
	  return NULL;
	}
      vm = _construct_vm(env, ptr->data);
      (*env)->SetObjectArrayElement(env, jarray_of_vms, i, vm);
      (*env)->DeleteLocalRef(env, vm);
    }
  qvd_printf("End of loop iterator i=%d, jarray=%p\n", i, jarray_of_vms);

  return jarray_of_vms;
}

/*
 * Calls qvd_connect_to_vm
 */
JNIEXPORT jint JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1connect_1to_1vm
(JNIEnv *env, jobject obj, jlong qvd_c_pointer, jint vm_id)
{
  qvdclient *qvd;
  int vm_id_int;
  jobject vm;
  struct callbackhandler_environment_struct *callbackhandler_env = NULL;

  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("c_qvd_connect_to_vm(%p,%d)\n", qvd, vm_id);

  /* Set the certificate handler here */
  /*  memory leak handling if the list_of_vm is called twice, should be NULL
   *  if not allocated before
   */
  free(qvd->userdata);
  callbackhandler_env = malloc(sizeof(struct callbackhandler_environment_struct));
  /* Might be null if the object has not been asigned */
  callbackhandler_env->unknowncertCallbackHandler = (*env)->GetObjectField(env, obj, certificatehandler_fid);
  qvd_printf("certificateHandler: %p, jvm: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm);
  callbackhandler_env->progressCallbackHandler = (*env)->GetObjectField(env, obj, progresshandler_fid);
  qvd_printf("progressCallbackHandler: %p, jvm: %p\n", callbackhandler_env->progressCallbackHandler, callbackhandler_env->jvm);
  if ((*env)->GetJavaVM(env, &(callbackhandler_env->jvm)) < 0) {
    qvd_error(qvd, "Error obtaining the JavaVM pointer\n");
    return 7;
  }
  qvd->userdata = (void *) callbackhandler_env;
  qvd_printf("progressCallbackHandler: %p, jvm: %p\n", callbackhandler_env->progressCallbackHandler, callbackhandler_env->jvm);
  qvd_printf("certificateHandler: %p, jvm: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm);
  qvd_set_unknown_cert_callback(qvd, accept_unknown_cert_callback);

  vm_id_int = vm_id;
  jint result = qvd_connect_to_vm(qvd, vm_id);
  return result;
}

/*
 * Calls qvd_stop_vm
 */
JNIEXPORT jint JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1stop_1vm
(JNIEnv *env, jobject obj, jlong qvd_c_pointer, jint vm_id)
{
  qvdclient *qvd;
  int vm_id_int;
  jobject vm;
  struct callbackhandler_environment_struct *callbackhandler_env = NULL;

  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("c_qvd_connect_to_vm(%p,%d)\n", qvd, vm_id);

  /* Set the certificate handler here */
  /*  memory leak handling if the list_of_vm is called twice, should be NULL
   *  if not allocated before
   */
  free(qvd->userdata);
  callbackhandler_env = malloc(sizeof(struct callbackhandler_environment_struct));
  /* Might be null if the object has not been asigned */
  callbackhandler_env->unknowncertCallbackHandler = (*env)->GetObjectField(env, obj, certificatehandler_fid);
  qvd_printf("certificateHandler: %p, jvm: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm);
  callbackhandler_env->progressCallbackHandler = (*env)->GetObjectField(env, obj, progresshandler_fid);
  qvd_printf("progressCallbackHandler: %p, jvm: %p\n", callbackhandler_env->progressCallbackHandler, callbackhandler_env->jvm);
  if ((*env)->GetJavaVM(env, &(callbackhandler_env->jvm)) < 0) {
    qvd_error(qvd, "Error obtaining the JavaVM pointer\n");
    return 7;
  }
  qvd->userdata = (void *) callbackhandler_env;
  qvd_printf("progressCallbackHandler: %p, jvm: %p\n", callbackhandler_env->progressCallbackHandler, callbackhandler_env->jvm);
  qvd_printf("certificateHandler: %p, jvm: %p\n", callbackhandler_env->unknowncertCallbackHandler, callbackhandler_env->jvm);
  qvd_set_unknown_cert_callback(qvd, accept_unknown_cert_callback);

  vm_id_int = vm_id;
  jint result = qvd_stop_vm(qvd, vm_id);
  return result;
}


/*
 * set geometry
 */
static char qvd_geometry_string[16]; /* see MAX_GEOMETRY in the java class*/
JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1geometry
(JNIEnv *env, jobject obj, jlong qvd_c_pointer, jint width, jint height)
{
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("c_qvd_set_geometry(%p,%d,%d)\n", qvd,width,height);
  sprintf(qvd_geometry_string, "%dx%d", width, height);
  qvd_set_geometry(qvd, qvd_geometry_string);
}

/* set fullscreen */
JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1fullscreen
(JNIEnv *env, jobject obj, jlong qvd_c_pointer)
{
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("c_qvd_set_fullscreen(%p)\n", qvd);
  qvd_set_fullscreen(qvd);
}

/* unset fullscreen */
JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1nofullscreen
  (JNIEnv *env, jobject obj, jlong qvd_c_pointer)
{
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("c_qvd_set_nofullscreen(%p)\n", qvd);
  qvd_set_nofullscreen(qvd);
}
/* set debug */
/* TODO it doesn't seem to work at least from jqvdclient */
JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1debug
(JNIEnv *env, jobject obj)
{
  qvd_printf("Message before setting debug\n");
  qvd_set_debug();
  qvd_printf("Message after setting debug\n");
}
/* set display */
JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1display
  (JNIEnv *env, jobject obj, jlong qvd_c_pointer, jstring display)
{
  qvdclient *qvd;
  const jbyte *str;

  qvd=_set_qvdclient(qvd_c_pointer);

  str = (*env)->GetStringUTFChars(env, display, NULL);
  if (str == NULL) {
    return ; /* OutOfMemoryError already thrown */
  }
  qvd_printf("%s", str);
  qvd_set_display(qvd, str);
  (*env)->ReleaseStringUTFChars(env, display, str);
}

JNIEXPORT jstring JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1get_1last_1error_1message
(JNIEnv *env, jobject obj, jlong qvd_c_pointer)
{
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  return (*env)->NewStringUTF(env, qvd_get_last_error(qvd));
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1home
(JNIEnv *env, jobject obj, jlong qvd_c_pointer, jstring home)
{
  qvdclient *qvd;
  const jbyte *str;

  qvd=_set_qvdclient(qvd_c_pointer);

  str = (*env)->GetStringUTFChars(env, home, NULL);
  if (str == NULL) {
    return ; /* OutOfMemoryError already thrown */
  }
  qvd_printf("Setting home %s\n", str);
  qvd_set_home(qvd, str);
  (*env)->ReleaseStringUTFChars(env, home, str);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1useragent
  (JNIEnv *env, jobject obj, jlong qvd_c_pointer, jstring useragent)
{
  qvdclient *qvd;
  const jbyte *str;

  qvd=_set_qvdclient(qvd_c_pointer);

  str = (*env)->GetStringUTFChars(env, useragent, NULL);
  if (str == NULL) {
    return ; /* OutOfMemoryError already thrown */
  }
  qvd_printf("Setting useragent %s\n", str);
  qvd_set_useragent(qvd, str);
  (*env)->ReleaseStringUTFChars(env, useragent, str);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1os
(JNIEnv *env, jobject obj, jlong qvd_c_pointer, jstring os) {
  qvdclient *qvd;
  const jbyte *str;

  qvd=_set_qvdclient(qvd_c_pointer);

  str = (*env)->GetStringUTFChars(env, os, NULL);
  if (str == NULL) {
    return ; /* OutOfMemoryError already thrown */
  }
  qvd_printf("Setting os %s\n", os);
  qvd_set_os(qvd, str);
  (*env)->ReleaseStringUTFChars(env, os, str);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1no_1cert_1check
(JNIEnv *env, jobject obj, jlong qvd_c_pointer) {
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("Setting no certificate check\n");
  qvd_set_no_cert_check(qvd);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1strict_1cert_1check
(JNIEnv *env, jobject obj, jlong qvd_c_pointer) {
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("Setting strict certificate check\n");
  qvd_set_strict_cert_check(qvd);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1progress_1callback
(JNIEnv *env, jobject obj, jlong qvd_c_pointer) {
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("Setting progress callback\n");
  qvd_set_progress_callback(qvd, progress_callback);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1no_1progress_1callback
(JNIEnv *env, jobject obj, jlong qvd_c_pointer) {
  qvdclient *qvd;
  qvd=_set_qvdclient(qvd_c_pointer);
  qvd_printf("Setting no progress callback\n");
  qvd_set_progress_callback(qvd, NULL);
}


JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1link
(JNIEnv *env, jobject obj, jlong qvd_c_pointer, jstring link) {
  qvdclient *qvd;
  const jbyte *str;

  qvd=_set_qvdclient(qvd_c_pointer);

  str = (*env)->GetStringUTFChars(env, link, NULL);
  if (str == NULL) {
    return ; /* OutOfMemoryError already thrown */
  }
  qvd_printf("Setting link %s\n", link);
  qvd_set_link(qvd, str);
  (*env)->ReleaseStringUTFChars(env, link, str);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1nx_1options
  (JNIEnv *env, jobject obj, jlong qvd_c_pointer, jstring nx_options)
{
  qvdclient *qvd;
  const jbyte *str;

  qvd=_set_qvdclient(qvd_c_pointer);

  str = (*env)->GetStringUTFChars(env, nx_options, NULL);
  if (str == NULL) {
    return ; /* OutOfMemoryError already thrown */
  }
  qvd_printf("Setting nx_options\n");
  qvd_set_nx_options(qvd, str);
  (*env)->ReleaseStringUTFChars(env, nx_options, str);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1set_1cert_1files
  (JNIEnv *env, jobject obj, jlong qvd_c_pointer, jstring client_cert, jstring client_key)
{
  qvdclient *qvd;
  const jbyte *client_cert_c, *client_key_c;

  qvd=_set_qvdclient(qvd_c_pointer);

  client_cert_c = (*env)->GetStringUTFChars(env, client_cert, NULL);
  if (client_cert == NULL) {
    return ; /* OutOfMemoryError already thrown */
  }
  client_key_c = (*env)->GetStringUTFChars(env, client_key, NULL);
  if (client_key == NULL) {
    (*env)->ReleaseStringUTFChars(env, client_cert, client_cert_c);
    return ; /* OutOfMemoryError already thrown */
  }

  qvd_set_cert_files(qvd, client_cert_c, client_key_c);

  (*env)->ReleaseStringUTFChars(env, client_cert, client_cert_c);
  (*env)->ReleaseStringUTFChars(env, client_key, client_key_c);
}

JNIEXPORT void JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1end_1connection
  (JNIEnv *env, jobject obj, jlong qvd_c_pointer)
{
  qvdclient *qvd;

  qvd=_set_qvdclient(qvd_c_pointer);

  qvd_end_connection(qvd);
}

JNIEXPORT jint JNICALL Java_com_theqvd_client_jni_QvdclientWrapper_qvd_1c_1payment_1required
  (JNIEnv *env, jobject obj, jlong qvd_c_pointer)
{
  qvdclient *qvd;

  qvd=_set_qvdclient(qvd_c_pointer);

  return qvd_payment_required(qvd);
}
